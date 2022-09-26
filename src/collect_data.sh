#!/bin/sh

PID=$(pidof "${1}")
RAW_RESULT_DIR="${2}"
NUMBER_OF_MEASUREMENTS="${3}"


ps -o pid,thcount > "${RAW_RESULT_DIR}"/thCount.log &

lsof -p "${PID}" > "${RAW_RESULT_DIR}"/listOfFileAndNetworks.log &

pmap -x "${PID}" > "${RAW_RESULT_DIR}"/memory_map.log &

top -b -H -n$(("${NUMBER_OF_MEASUREMENTS}"/3)) -p "${PID}" > "${RAW_RESULT_DIR}"/threads.log &

pidstat -p "${PID}" 1 "${NUMBER_OF_MEASUREMENTS}" > "${RAW_RESULT_DIR}"/cpu.log &

pidstat -p "${PID}" -d 1 "${NUMBER_OF_MEASUREMENTS}" > "${RAW_RESULT_DIR}"/io.log &

echo "rx tx" > "${RAW_RESULT_DIR}"/network.log

bmon -r 1 -p wlan0 -o format:fmt='$(attr:rxrate:bytes) $(attr:txrate:bytes)\n' >> "${RAW_RESULT_DIR}"/network.log &

sleep "${NUMBER_OF_MEASUREMENTS}" && kill $(pidof bmon)

lsof -p "${PID}" >> "${RAW_RESULT_DIR}"/listOfFileAndNetworks.log 