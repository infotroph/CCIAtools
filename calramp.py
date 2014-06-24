#!/usr/bin/env python3

'''
Drive a set of Alicat gas flow controllers to produce arbitrary 
mixtures of gases. Original application: Mixing CO2 and air for linearity 
testing of an LGR ccia-36EP CO2 isotope analyzer.

Usage: python3 [-u] calramp.py >> logfile.txt
Use -u for unbuffered output to the log file, e.g. if watching 
it with $(tail -f logfile.txt).
'''

import serial, io, schedule
from datetime import datetime, timezone, timedelta
from time import sleep


## Experiment-specific variables. 

# Serial device name: 
# I'm connecting through an FTDI USB-serial cable. 
# Change to match your hardware.
devname = '/dev/cu.usbserial-FTDEIXNY'

# Timezone for log datestamps: 
# all equipment in shed is set to UTC-6 (central standard time, no DST)
tz = timezone(timedelta(hours=-6))

# Controller IDs: 
# Using a set of four Alicat MC-series mass flow 
# controllers, all mounted to one baseplate and connected through a serial 
# multiplexer box. All RS232 signals are sent to all 4 units, so 
# to message one unit, must send the correct one-letter identifier. 
# Max flow (sccm) of each controller: 
controllerMaxRates = {'a': 5000, 'b': 1000, 'c': 200, 'd': 10}
# Mnemonic aliases for the controllers we're using
# (Controllers C and D are idle or powered off for this experiment):
bulk = 'a'
spike = 'b'

# Concentration ramp settings: 
# Step up and down a given range of concentrations
# TODO: Document how to change number/direction of ramps
steptime = 30 	# minutes at each concentration.
ppmlow = 200 		# don't mix below this
ppmhigh = 1000	# don't mix above this
ppmstep = 200	# change concentration by this much per step

pollinterval = 1
totalflowccm = 500
spiketankppm = 5000



''' Functions. 
'''
def ts():
	return(datetime.now(tz).isoformat())

def conc2flows(ppmtarget, spikeppm, totccm):
	# pick flow rates to make desired CO2 concentration from 
	# two airstreams, maintaining constant total flow.
	# Returns a tuple of ccm for spike and bulk controllers respectively.
	if ppmtarget > spikeppm:
		return((totccm, 0))
	spikeccm = ppmtarget/spikeppm * totccm
	return((spikeccm, totccm-spikeccm))

def flow2steps(ccm, maxccm):
	# 64000 steps = full-scale flow.
	# controller will ignore values over 65535 (2% overrange).
	return(min(round(ccm * 64000 / maxccm), 65535))

def poll(con, id):
	con.write("\r" + id + "\r")
	con.flush()
	print(ts() + " " + con.read(), end='')

def sendflow(con, id, val):
	val = flow2steps(val, controllerMaxRates[id])
	con.write("\r" + id + str(val) + "\r")
	con.flush()
	print(ts() + " " + con.read(), end='')

def setnextppm(ppms):
	try: 
		ppm=next(ppms)
	except StopIteration:
		return(schedule.CancelJob())
	spikeccm, bulkccm = conc2flows(ppm, spiketankppm, totalflowccm)
	sendflow(sio, spike, spikeccm)
	sendflow(sio, bulk, bulkccm)

''' And go. 
'''

s = serial.Serial(devname, baudrate=19200, timeout=0.1)
sio = io.TextIOWrapper(io.BufferedRWPair(s, s))

rampup = iter(range(ppmlow, ppmhigh, ppmstep))
doneramping = False

pollbulk = schedule.every(pollinterval).seconds.do(poll, con=sio, id=bulk)
pollspike = schedule.every(pollinterval).seconds.do(poll, con=sio, id=spike)
nextspike = schedule.every(steptime).seconds.do(setnextppm, rampup)

# Flush LGR and wait to obtain stable concentration
sendflow(sio, bulk, totalflowccm)
sendflow(sio, spike, 0)
sleep(10)

# Loop until we we've used all the values in rampup, at which time
# nextspike will remove itself from the job list.
while nextspike in schedule.jobs:
	schedule.run_pending()
	sleep(0.5)

sendflow(sio, spike, 0)
sendflow(sio, bulk, 0)

schedule.clear()

poll(sio, bulk)
poll(sio, spike)

s.close()


