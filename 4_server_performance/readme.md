# Server stats resources:
## Total CPU Usage Doc:

- /proc/stat file: https://www.linuxhowtos.org/System/procstat.htm
- https://stackoverflow.com/questions/9229333/how-to-get-overall-cpu-usage-e-g-57-on-linux

This command calculates the CPU usage as a percentage over a one-second interval by analyzing data from `/proc/stat`. Here's a breakdown of its components:

### 1. **Components and Explanation**
#### **a. `grep 'cpu ' /proc/stat`**
- `/proc/stat` contains CPU activity statistics.
- `grep 'cpu '` extracts the line starting with `cpu`, which represents cumulative CPU stats for all cores. For example:
  ```
  cpu  100 200 300 400 500 600 700
  ```
  Each column represents:
  1. `user`: Time spent in user mode.
  2. `nice`: Time spent in user mode with low priority.
  3. `system`: Time spent in system mode.
  4. `idle`: Time spent idle.
  5. `iowait`: Time spent waiting for I/O.
  6. `irq` and `softirq`: Time spent handling hardware and software interrupts.

#### **b. `<(...)` Process Substitution**
- `<(grep 'cpu ' /proc/stat)` creates a temporary file-like input for the first CPU stats snapshot.
- `<(sleep 1; grep 'cpu ' /proc/stat)` takes another snapshot **after a 1-second delay**.

#### **c. `awk`**
- Processes the two inputs simultaneously. It calculates CPU usage between the two snapshots. Here's the script explained:
  ```bash
  awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1) "%"; }'
  ```
  - **Variables:**
    - `u`: Active CPU time (`user + system`).
    - `t`: Total CPU time (`user + system + idle`).
    - `u1`, `t1`: Values from the first snapshot (stored when `NR==1`).
  - **Logic:**
    1. For the first input (`NR==1`), store the active (`u1`) and total (`t1`) times.
    2. For the second input, calculate:
       - Change in active time: `($2 + $4 - u1)`
       - Change in total time: `(t - t1)`
       - CPU usage as a percentage: `(($2 + $4 - u1) * 100) / (t - t1)`.
  - **Output:**
    - Prints the percentage CPU usage between the two snapshots.

### 2. **Execution Flow**
1. The first snapshot of CPU stats is taken.
2. The script waits for 1 second (`sleep 1`).
3. The second snapshot is taken.
4. The difference in active and total times is calculated and converted to a percentage.

### 3. **Example Output**
If the CPU spends 20% of the time in active states over the one-second interval, the output might look like:
```
20%
```

### 4. **Use Case**
This is a lightweight and effective method to monitor CPU usage without requiring external tools like `top` or `htop`.

## Total Memory (RAM) usgae (free vs used):

- https://phoenixnap.com/kb/linux-commands-check-memory-usage

To calculate the **total memory usage**, including the percentage of used and free memory, from `/proc/meminfo`, you can follow these steps:

---

### **Step 1: Understand Relevant Fields in `/proc/meminfo`**
1. **`MemTotal`**: Total available RAM on the system.
2. **`MemFree`**: Memory that is completely unused.
3. **`Buffers`**: Memory used for file buffers.
4. **`Cached`**: Memory used for caching files (can be reused if needed).

#### **Actual Free Memory**
Linux treats cached and buffered memory as "free" since it can be reclaimed if necessary. Hence, the formula to calculate **actual free memory** is:
```
Actual_Free = MemFree + Buffers + Cached
```

#### **Used Memory**
Used memory is calculated as:
```
Used_Memory = MemTotal - Actual_Free
```

#### **Percentage Usage**
```
Usage_Percentage = (Used_Memory / MemTotal) * 100
```

---

### **Step 2: Bash Script to Calculate**
Here's a Bash script to calculate the memory usage:

```bash
#!/bin/bash

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
```

---

### **Step 3: Example Output**
Assume `/proc/meminfo` contains:
```
MemTotal:       16230416 kB
MemFree:         2123040 kB
Buffers:          123456 kB
Cached:          4567890 kB
```

The script calculates:
1. **Actual Free**: `2123040 + 123456 + 4567890 = 6814386 kB`
2. **Used Memory**: `16230416 - 6814386 = 9416030 kB`
3. **Usage Percentage**: `(9416030 / 16230416) * 100 ≈ 58.00%`
4. **Free Percentage**: `(6814386 / 16230416) * 100 ≈ 42.00%`

**Output**:
```
Total Memory: 15848 MB
Used Memory: 9196 MB (58.00%)
Free Memory: 6651 MB (42.00%)
```

---

### **Conclusion**
This method gives an accurate breakdown of total, used, and free memory percentages by including cached and buffered memory as part of free memory. It reflects Linux's memory management philosophy.