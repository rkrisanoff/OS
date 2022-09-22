#!/bin/sh

rawResultDir="data/raw"
proccessedResultDir="data/processed"
numberOfMeasurements=100

cat "$rawResultDir"/cpu.log  | tail -n $(("$numberOfMeasurements"+2)) | head -n $(("$numberOfMeasurements"+1)) > "$proccessedResultDir"/cpu.log

cat "$rawResultDir"/io.log  | tail -n $(("$numberOfMeasurements"+2)) | head -n $(("$numberOfMeasurements"+1)) > "$proccessedResultDir"/io.log

cp "$rawResultDir"/network.log "$proccessedResultDir"/network.log