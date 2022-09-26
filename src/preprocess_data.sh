#!/bin/sh

RAW_RESULT_DIR="$1"
PROCCESSED_RESULT_DIR="$2"
NUMBER_OF_MEASUREMENTS="$3"


tail -n $(("$NUMBER_OF_MEASUREMENTS"+2)) < "$RAW_RESULT_DIR"/cpu.log | head -n $(("$NUMBER_OF_MEASUREMENTS"+1)) > "$PROCCESSED_RESULT_DIR"/cpu.log

tail -n $(("$NUMBER_OF_MEASUREMENTS"+2)) < "$RAW_RESULT_DIR"/io.log | head -n $(("$NUMBER_OF_MEASUREMENTS"+1)) > "$PROCCESSED_RESULT_DIR"/io.log

cp "$RAW_RESULT_DIR"/network.log "$PROCCESSED_RESULT_DIR"/network.log

echo "PID     USER      PR   NI VIRT     RES    SHR  S  %CPU  %MEM   TIME+ COMMAND" >"$PROCCESSED_RESULT_DIR"/threads.log

grep 180188 < "$RAW_RESULT_DIR"/threads.log >> "$PROCCESSED_RESULT_DIR"/threads.log