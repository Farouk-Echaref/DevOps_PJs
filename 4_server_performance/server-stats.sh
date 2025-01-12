#!/bin/bash

echo "Total CPU usage: " 
awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1) "%"; }' \
<(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat)

echo "Total memory (RAM) usage (Free vs Used including percentage): "

# Extract fields from /proc/meminfo
MemTotal=$(grep "^MemTotal:" /proc/meminfo | awk '{print $2}')
MemFree=$(grep "^MemFree:" /proc/meminfo | awk '{print $2}')
Buffers=$(grep "^Buffers:" /proc/meminfo | awk '{print $2}')
Cached=$(grep "^Cached:" /proc/meminfo | awk '{print $2}')

# Calculate actual free and used memory (in kB)
Actual_Free=$((MemFree + Buffers + Cached))
Used_Memory=$((MemTotal - Actual_Free))

# Convert to percentages
Usage_Percentage=$(awk "BEGIN {printf \"%.2f\", ($Used_Memory / $MemTotal) * 100}")
Free_Percentage=$(awk "BEGIN {printf \"%.2f\", ($Actual_Free / $MemTotal) * 100}")

# Output results
echo "Total Memory: $((MemTotal / 1024)) MB"
echo "Used Memory: $((Used_Memory / 1024)) MB ($Usage_Percentage%)"
echo "Free Memory: $((Actual_Free / 1024)) MB ($Free_Percentage%)"
