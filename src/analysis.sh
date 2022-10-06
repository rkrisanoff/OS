#!/bin/sh

target_flag=''
target=''
work_dir_flag=''
work_dir=''
number_of_measurements_flag=''
number_of_measurements=''
flameOpts=''
flame_graph_flag=''
flame_graph_dir=''

while getopts 't:d:n:f:h' flag; do
    case "${flag}" in
    h) echo "Usage: analysis
                -t path to the target program
                -d path to the working directory
                -n numbers of measurements (in seconds)
                -f path to the FlameGraph directory"
                exit
    ;;
    t)
        target_flag='true'
        target_path="${OPTARG}"
        if [ -f "${target_path}" ]; then
            target=$(readlink -f "${target_path}")
            echo "the target of perfomance researching is " "${target}"
        else
            echo "invalid target pathfile"
            exit
        fi
        ;;
    d)
        work_dir_flag='true'
        work_dir_path="${OPTARG}"
        if [ -d "${work_dir_path}" ]; then
            work_dir=$(readlink -f "${work_dir_path}")
            echo "the working directory is" "${work_dir}"
        else
            echo "invalid working directory path"
            exit
        fi
        ;;
    n)
        number_of_measurements_flag='true'
        number_of_measurements="${OPTARG}"
        if [ "${number_of_measurements}" -ge 1 ] && [ "${number_of_measurements}" -lt 181 ]; then
            echo "number of measurements" "${number_of_measurements}" "is correct"
        else
            echo "number of measurements" "${number_of_measurements}" "is uncorrect and must be between 0 and 180"
            exit
        fi
        ;;
    f)
        flame_graph_path_flag='true'
        flame_graph_path="${OPTARG}"
        if [ -d "${flame_graph_path}" ] && [ -x "${flame_graph_path}"/stackcollapse-perf.pl ] && [ -x "${flame_graph_path}"/flamegraph.pl ]; then
            flame_graph_dir=$(readlink -f "${flame_graph_path}")
            echo "the flamegraph directory is" "${flame_graph_dir}"
        else
            echo "invalid flamegraph path"
            exit
        fi
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done

if [ ! "${target_flag}" = 'true' ]; then
    echo "enter a target app with -t flag"
    exit
fi

if [ ! "${work_dir_flag}" = 'true' ]; then
    work_dir="."
fi

if [ ! "${number_of_measurements_flag}" = 'true' ]; then
    echo "set default number of measurements 60"
    number_of_measurements=60
fi
# cleaning working directory
if [ -d "${work_dir}"/data ]; then
    rm -rf "${work_dir}"/data
fi
if [ -d "${work_dir}"/test ]; then
    rm -rf "${work_dir}"/test
fi

mkdir "${work_dir}"/data
mkdir "${work_dir}"/data/raw
mkdir "${work_dir}"/data/raw/networks
mkdir "${work_dir}"/data/processed
mkdir "${work_dir}"/data/results
mkdir "${work_dir}"/test

sudo killall "${target}" 2>/dev/null
cd "${work_dir}"/test || exit
"${target}" &
cd "${work_dir}" || exit

PID=$(pidof "${target}")

# collecting data
ps huH -p "${PID}" | wc >"${work_dir}"/data/raw/threads_count.log &
pmap -x "${PID}" >"${work_dir}"/data/raw/memory_map.log &
top -b -H -n$(("${number_of_measurements}" / 3)) -p "${PID}" >"${work_dir}"/data/raw/threads.log &
pidstat -p "${PID}" 1 "${number_of_measurements}" >"${work_dir}"/data/raw/cpu.log &
pidstat -p "${PID}" -d 1 "${number_of_measurements}" >"${work_dir}"/data/raw/io.log &
if [ "${flame_graph_path_flag}" = 'true' ]; then
    perf record -F 99 -p "${PID}" -g -- sleep "${number_of_measurements}"
    perf script >"${work_dir}"/data/raw/out.perf & 
    echo "flame graph will be"
    
fi

echo "rx tx" >"${work_dir}"/data/raw/network.log
bmon -r 1 -p wlan0 -o format:fmt='$(attr:rxrate:bytes) $(attr:txrate:bytes)\n' >>"${work_dir}"/data/raw/network.log &
for network_port in $(sudo netstat -ltup | grep "${PID}" | awk '{split($4,port_parts,":"); print port_parts[2]}' | grep '^[0-9][0-9]*$'); do
    sudo tcpdump -i any port "${network_port}" | cat >"${work_dir}"/data/raw/networks/"${network_port}".log &
done
lsof -p "${PID}" >>"${work_dir}"/data/raw/file_networks_list.log
sleep "${number_of_measurements}" && sudo killall bmon && sudo killall tcpdump >/dev/null


sudo killall "${target}" >/dev/null

# processing data
tail -n $(("$number_of_measurements" + 2)) <"${work_dir}"/data/raw/cpu.log | head -n $(("$number_of_measurements" + 1)) >"${work_dir}"/data/processed/cpu.log
tail -n $(("$number_of_measurements" + 2)) <"${work_dir}"/data/raw/io.log | head -n $(("$number_of_measurements" + 1)) >"${work_dir}"/data/processed/io.log
if [ "${flame_graph_path_flag}" = 'true' ]; then
    "${flame_graph_dir}"/stackcollapse-perf.pl "${work_dir}"/data/raw/out.perf >"${work_dir}"/data/processed/out.folded
    "${flame_graph_dir}"/flamegraph.pl --title 180188 --width 1920 --height 24 "${work_dir}"/data/processed/out.folded >"${work_dir}"/data/results/kernel.svg
fi 
cp "${work_dir}"/data/raw/network.log "${work_dir}"/data/processed/network.log
echo "PID     USER      PR   NI VIRT     RES    SHR  S  %CPU  %MEM   TIME+ COMMAND" >"${work_dir}"/data/processed/threads.log
grep "${PID}" <"${work_dir}"/data/raw/threads.log >>"${work_dir}"/data/processed/threads.log
