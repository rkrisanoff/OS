#!/bin/sh

PID="${1}"
RAW_RESULT_DIR="${2}"
NUMBER_OF_MEASUREMENTS="${3}"

ps huH -p "${PID}" | wc > "${RAW_RESULT_DIR}"/threads_count.log &

pmap -x "${PID}" > "${RAW_RESULT_DIR}"/memory_map.log &

top -b -H -n$(("${NUMBER_OF_MEASUREMENTS}"/3)) -p "${PID}" > "${RAW_RESULT_DIR}"/threads.log &

pidstat -p "${PID}" 1 "${NUMBER_OF_MEASUREMENTS}" > "${RAW_RESULT_DIR}"/cpu.log &

pidstat -p "${PID}" -d 1 "${NUMBER_OF_MEASUREMENTS}" > "${RAW_RESULT_DIR}"/io.log &

echo "rx tx" > "${RAW_RESULT_DIR}"/network.log

bmon -r 1 -p wlan0 -o format:fmt='$(attr:rxrate:bytes) $(attr:txrate:bytes)\n' >> "${RAW_RESULT_DIR}"/network.log &

for network_port in $(sudo netstat -ltup | grep "${PID}" | awk '{split($4,port_parts,":"); print port_parts[2]}' | grep '^[0-9][0-9]*$')
do
    sudo tcpdump -i any port "${network_port}" | cat > "${RAW_RESULT_DIR}"/networks/"${network_port}".log &
done

lsof -p "${PID}" > "${RAW_RESULT_DIR}"/file_networks_list.log
sleep "${NUMBER_OF_MEASUREMENTS}" && sudo killall bmon && sudo killall tcpdump > /dev/null

