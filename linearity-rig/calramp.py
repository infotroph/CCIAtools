#!/usr/bin/env python3

'''
Drive a set of Alicat gas flow controllers to produce arbitrary 
mixtures of gases. Original application: Mixing CO2 and air for linearity 
testing of an LGR ccia-36EP CO2 isotope analyzer.

Usage: python3 [-u] calramp.py >> logfile.txt
Use -u for unbuffered output to the log file, e.g. if watching 
it with $(tail -f logfile.txt).
'''

## Import modules. 

# schedule: https://github.com/dbader/schedule
# serial: http://pyserial.sourceforge.net/
# io, datetime, time are all documented in the Python3 module index:
# https://docs.python.org/3/py-modindex.html
import serial, io, schedule
from datetime import datetime, timezone, timedelta
from time import sleep


## Experiment-specific variables. 

# Serial device name: 
# I'm connecting through an FTDI USB-serial cable. 
# Change to match your hardware.
devname = '/dev/cu.usbserial-FTDEIXNY'

# Concentration ramp settings: 
# Controllers will step from ppmlow to ppmhigh and back again, 
# nramps times.
ppmlow = 200 		# lowest ppm desired
ppmhigh = 5000	# highest ppm desired
ppmstep = 50	# change concentration by this many ppm per step
nramps = 3 		# How many times to ramp up and down?
steptime = 3 	# minutes at each concentration.

# Seconds between controller log entries. 
# Changing this interval does not change controller performance 
# at all, just sets how often we check in on them.
pollinterval = 1	

# Desired flow rate of mixture, in sccm
totalflowccm = 350	

# Known [CO2] in spike tank, ppm. 
# The more precisely this value is known,
# the closer each step will be to requested target ppm.
spiketankppm = 5000 

# Minutes to purge system with bulk air at script start
zeropurge = 5 

# Controller IDs: 
# I'm using a set of four Alicat MC-series mass flow controllers, each with 
# a different max flow rate (sccm) and each answering to a different 
# one-letter identifier: 
controllerMaxRates = {'a': 5000, 'b': 1000, 'c': 200, 'd': 10}
# All four units are mounted to one baseplate and connected through a serial 
# multiplexer box that sends all RS232 traffic to all 4 units; each unit 
# ignores any message that doesn't begin with its ID. Let's set some 
# mnemonic aliases for the controllers we're using (Controllers C and D 
# are idle or powered off for this experiment):
bulk = 'a'
spike = 'b'

# Timezone for log datestamps: 
# UTC-6 (central standard time, no DST) to match other equipment in shed
tz = timezone(timedelta(hours=-6))


## Functions. 

def ts(): 
	# Make timestamps for the log
	return(datetime.now(tz).isoformat())

def conc2flows(ppmtarget, spikeppm, totccm):
	# pick flow rates for two airstreams to make desired CO2 concentration 
	# from two airstreams with known [CO2], 
	# while maintaining set total flow.
	# Returns a tuple of ccm for spike and bulk controllers respectively.
	if ppmtarget > spikeppm:
		return((totccm, 0))
	spikeccm = ppmtarget/spikeppm * totccm
	return((spikeccm, totccm-spikeccm))

def flow2steps(ccm, maxccm):
	# Controller takes setpoints NOT in ccm, but in steps from 0 (off) 
	# to 64000 = full-scale flow of that controller.
	# Controller will ignore values over 65535 (2% overrange) --
	# we send max so it goes to max instead of ignoring completely.
	return(min(round(ccm * 64000 / maxccm), 65535))

def poll(con, id):
	# Get current status from controller `id` on connection `con`.
	# Reply line contains seven space-separated fields:
	# controller ID, 
	# pressure (psia), 
	# temperature (C),
	# current volumetric flow (ccm or slpm, depending on controller),
	# current mass flow (ccm or slpm, depending on controller),
	# current setpoint (ccm or slpm, depending on controller),
	# current gas calibration.
	# Sample response: "A +014.32 +022.81 +00.509 +00.500 00.500     Air"
	# TODO: return the response instead of printing it straight to the log.
	con.write("\r" + id + "\r")
	con.flush()
	print(ts() + " " + con.read(), end='')

def sendflow(con, id, val):
	# Send new setpoint `val` to controller `id` on connection `con`,
	# and capture its response (same format as when polling).
	# TODO: return instead of print, write a proper controller class instead
	# of passing connection objects everywhere.
	val = flow2steps(val, controllerMaxRates[id])
	con.write("\r" + id + str(val) + "\r")
	con.flush()
	print(ts() + " " + con.read(), end='')

def setnextppm(ppms):
	# Move to the next scheduled [CO2] value,
	# update controllers to produce it, 
	# or stop polling if done.
	try: 
		ppm=next(ppms)
	except StopIteration:
		return(schedule.CancelJob())
	spikeccm, bulkccm = conc2flows(ppm, spiketankppm, totalflowccm)
	sendflow(sio, spike, spikeccm)
	sendflow(sio, bulk, bulkccm)


## And we're ready to go. 

# Set up connections
s = serial.Serial(devname, baudrate=19200, timeout=0.1)
sio = io.TextIOWrapper(io.BufferedRWPair(s, s))

try: 
	# Set up controller polling schedule
	pollbulk = schedule.every(pollinterval).seconds.do(poll, con=sio, id=bulk)
	pollspike = schedule.every(pollinterval).seconds.do(poll, con=sio, id=spike)

	# Flush LGR with zero air and wait to obtain stable concentration
	sendflow(sio, bulk, totalflowccm)
	sendflow(sio, spike, 0)
	sleep(zeropurge*60)

	for i in range(nramps):
		rampup = iter(range(ppmlow, ppmhigh+1, ppmstep))
		nextspike = schedule.every(steptime).minutes.do(setnextppm, rampup)

		# Loop until we we've used all the values in rampup, at which time
		# nextspike will remove itself from the job list.
		while nextspike in schedule.jobs:
			schedule.run_pending()
			sleep(0.5)

		# Now ramp back down.
		rampdown = iter(reversed(range(ppmlow, ppmhigh+1, ppmstep)))
		nextspike = schedule.every(steptime).minutes.do(setnextppm, rampdown)

		while nextspike in schedule.jobs:
			schedule.run_pending()
			sleep(0.5)
except:
	# if anything goes wrong, including a keyboard interrupt, 
	# bail from loop and go on to the end-of-script shutdown
	pass

#Done. Shut everything down.
sendflow(sio, spike, 0)
sendflow(sio, bulk, 0)
schedule.clear()

# One last reading to be sure setpoints dropped to 0. 
# TODO: Should throw error if not.
poll(sio, bulk)
poll(sio, spike)

s.close()


