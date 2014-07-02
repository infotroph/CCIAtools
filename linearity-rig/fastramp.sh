#!/bin/bash

# A = air, full flow = 5 lpm
# B = CO2, full flow = 10 ccm
# C = reference tank, full flow = 1 lpm

CR=$(printf '\r')


# [1250 ccm air] / [1e6 ppm] * [x ppm CO2] =  y ccm CO2
# [y ccm CO2]/ [10 ccm max] * 64000 = setpoint
# ==> setpoint = 1250/1e6/10*64000*x = 8.0*x 

FLOWCOEF=8

echo "Reference gas"
screen -S mfc -p 0 -X stuff "$CR"a0"$CR"b0"$CR"c64000$CR
sleep 300

echo "Zero air @ 1250 mL/min"
screen -S mfc -p 0 -X stuff "$CR"a16000"$CR"b0"$CR"c0$CR
sleep 300

co2val=$(seq 0 50 2000)

for i in $co2val; do 
	echo "Target: $i"
	i=$(echo "$i*$FLOWCOEF/1"|bc)
	screen -S mfc -p 0 -X stuff "$CR"b$i"$CR" 
	echo "Setpoint: $i"
	sleep 30
done

sleep 300

co2val=$(seq 2000 -50 200)

for i in $co2val; do 
	echo "Target: $i"
	i=$(echo "$i*$FLOWCOEF/1"|bc)
	screen -S mfc -p 0 -X stuff b$i$CR 
	echo "Setpoint: $i"
	sleep 30
done

 sleep 300

# Reference gas
screen -S mfc -p 0 -X stuff a0"$CR"b0"$CR"c64000$CR
sleep 300

# all off
screen -S mfc -p 0 -X stuff a0"$CR"b0"$CR"c0$CR
