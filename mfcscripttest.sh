#!/bin/bash

# A = air, full flow = 5 lpm
# B = CO2, full flow = 10 ccm
# C = reference tank, full flow = 1 lpm

CR=$(printf '\r')

# # warm-up:  10 min reference @ 1250 ccm
# screen -S mfc -p 0 -X stuff a0"$CR"b0"$CR"c57600
# sleep 60

# # 200 ppm CO2, 5 min
# screen -S mfc -p 0 -X stuff a16000"$CR"b1152"$CR"c0$CR
#screen -S mfc -p 0 -X stuff "$CR"a16000"$CR"b1152$CR
#sleep 300

# [1250 ccm air] / [1e6 ppm] * [x ppm CO2] =  y ccm CO2
# [y ccm CO2]/ [10 ccm max] * 64000 = setpoint
# ==> setpoint = 1250/1e6/10*64000*x = 8.0*x 

FLOWCOEF=8

# 2500/1e6/10*64000 = 16.0*x
# FLOWCOEF=16.0

# co2val=$(seq 0 50 200)

# for i in $co2val; do 
# 	echo "Target: $i"
# 	i=$(echo "$i*$FLOWCOEF/1"|bc)
# 	screen -S mfc -p 0 -X stuff "$CR"b$i"$CR" 
# 	echo "Setpoint: $i"
# 	sleep 300
# done

# sleep 300

 co2val=$(seq 200 10 2000)

for i in $co2val; do 
	echo "Target: $i"
	i=$(echo "$i*$FLOWCOEF/1"|bc)
	screen -S mfc -p 0 -X stuff b$i$CR 
	echo "Setpoint: $i"
	sleep 420
done

sleep 300

co2val=$(seq 2000 -10 200)

for i in $co2val; do 
	echo "Target: $i"
	i=$(echo "$i*$FLOWCOEF/1"|bc)
	screen -S mfc -p 0 -X stuff b$i$CR 
	echo "Setpoint: $i"
	sleep 420
done

 sleep 300

# co2val=$(seq 200 50 5000)

# for i in $co2val; do 
# 	echo "Target: $i"
# 	i=$(echo "$i*$FLOWCOEF/1"|bc)
# 	screen -S mfc -p 0 -X stuff b$i$CR 
# 	echo "Setpoint: $i"
# 	sleep 60
# done

# sleep 300

# co2val=$(seq 5000 -50 200)

# for i in $co2val; do 
# 	echo "Target: $i"
# 	i=$(echo "$i*$FLOWCOEF/1"|bc)
# 	screen -S mfc -p 0 -X stuff b$i$CR 
# 	echo "Setpoint: $i"
# 	sleep 60
# done

i=300
echo "Target: $i"
i=$(echo "$i*$FLOWCOEF/1"|bc)
screen -S mfc -p 0 -X stuff b$i$CR 
echo "Setpoint: $i"
sleep 420

i=500
echo "Target: $i"
i=$(echo "$i*$FLOWCOEF/1"|bc)
screen -S mfc -p 0 -X stuff b$i$CR 
echo "Setpoint: $i"
sleep 420

i=1000
echo "Target: $i"
i=$(echo "$i*$FLOWCOEF/1"|bc)
screen -S mfc -p 0 -X stuff b$i$CR 
echo "Setpoint: $i"
sleep 420

i=300
echo "Target: $i"
i=$(echo "$i*$FLOWCOEF/1"|bc)
screen -S mfc -p 0 -X stuff b$i$CR 
echo "Setpoint: $i"
sleep 420

i=500
echo "Target: $i"
i=$(echo "$i*$FLOWCOEF/1"|bc)
screen -S mfc -p 0 -X stuff b$i$CR 
echo "Setpoint: $i"
sleep 420

# done, cut all flows
 screen -S mfc -p 0 -X stuff a0"$CR"b0"$CR"c0$CR

