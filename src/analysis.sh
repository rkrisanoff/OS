#!/bin/sh

goal="${1}"
workScriptsDir="${2}"
NUMBER_OF_MEASUREMENTS="${3}"
if [ -d "${workScriptsDir}"/data ]; then
    rm -rf "${workScriptsDir}"/data
fi

mkdir "${workScriptsDir}"/data
mkdir "${workScriptsDir}"/data/raw
mkdir "${workScriptsDir}"/data/processed

${goal} &

"${workScriptsDir}"/src/collect_data.sh "${goal}" "${workScriptsDir}/data/raw" "${NUMBER_OF_MEASUREMENTS}"
kill "$(pidof ${goal})"
"${workScriptsDir}"/src/preprocess_data.sh "${workScriptsDir}/data/raw" "${workScriptsDir}/data/processed" "${NUMBER_OF_MEASUREMENTS}"
