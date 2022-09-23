#!/bin/sh

rawResultDir="data/raw"
proccessedResultDir="data/processed"
numberOfMeasurements=1000

cat "$rawResultDir"/cpu.log  | tail -n $(("$numberOfMeasurements"+2)) | head -n $(("$numberOfMeasurements"+1)) > "$proccessedResultDir"/cpu.log

echo "11:11:09 AM   UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s iodelay  Command" > "$proccessedResultDir"/io.log


cat "$rawResultDir"/io.log  | tail -n $(("$numberOfMeasurements"+2)) | head -n $(("$numberOfMeasurements"+1)) >> "$proccessedResultDir"/io.log

cp "$rawResultDir"/network.log "$proccessedResultDir"/network.log

echo "total running sleeping stopped zombie" >"$proccessedResultDir"/threads.log

cat "$rawResultDir"/threads.log | grep Threads | awk '{print $2,$4,$6,$8,$10}' >> "$proccessedResultDir"/threads.log