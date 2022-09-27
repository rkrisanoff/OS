#!/bin/sh

goal="${1}"
workScriptsDir="${2}"
NUMBER_OF_MEASUREMENTS="${3}"
if [ -d "${workScriptsDir}"/data ]; then
    rm -rf "${workScriptsDir}"/data
fi

mkdir "${workScriptsDir}"/data
mkdir "${workScriptsDir}"/data/raw
mkdir "${workScriptsDir}"/data/raw/networks
mkdir "${workScriptsDir}"/data/processed

sudo killall "${goal}" > /dev/null

"${goal}" &

PID=$(pidof "${goal}")

sudo "${workScriptsDir}"/src/collect_data.sh "${PID}" "${workScriptsDir}/data/raw" "${NUMBER_OF_MEASUREMENTS}"
sudo killall "${goal}" > /dev/null
sudo "${workScriptsDir}"/src/preprocess_data.sh "${workScriptsDir}/data/raw" "${workScriptsDir}/data/processed" "${NUMBER_OF_MEASUREMENTS}"
