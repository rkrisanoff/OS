#!/bin/sh

rawResultDir="data/raw"
numberOfMeasurements=100


PID=$(pidof "$1")

ps -o pid,thcount > "$rawResultDir"/thCount.log &

lsof -p "$PID" > "$rawResultDir"/listOfFileAndNetworks.log &

pmap -x "$PID" > "$rawResultDir"/memory_map.log &

# strace -f -e trace=network -s 100 -p "$PID" > "$resultDir"/networkPackages &
top -b -H -n$(("$numberOfMeasurements"/3)) -p "$PID" > "$rawResultDir"/threads.log &

pidstat -p "$PID" 1 "$numberOfMeasurements" > "$rawResultDir"/cpu.log &

pidstat -p "$PID" -d 1 "$numberOfMeasurements" > "$rawResultDir"/io.log &

echo "rx tx" > "$rawResultDir"/network.log

bmon -p wlan0 -o format:fmt='$(attr:rxrate:bytes) $(attr:txrate:bytes)\n' >> "$rawResultDir"/network.log &

sleep "$numberOfMeasurements" && kill $(pidof bmon)