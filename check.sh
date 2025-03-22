#!/bin/bash

LOGFILE="system_monitor.log"
INTERVAL=5  # Set the monitoring interval in seconds

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}'
}

# Function to get memory usage
get_mem_usage() {
    free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get disk usage
get_disk_usage() {
    df -h | awk '$NF=="/"{print $5}'
}

# Function to get network usage
get_network_usage() {
    RX1=$(cat /sys/class/net/enp5s0f0/statistics/rx_bytes)
    TX1=$(cat /sys/class/net/enp5s0f0/statistics/tx_bytes)
    sleep 1
    RX2=$(cat /sys/class/net/enp5s0f0/statistics/rx_bytes)
    TX2=$(cat /sys/class/net/enp5s0f0/statistics/tx_bytes)
    RX=$(echo "($RX2 - $RX1) / 1024" | bc)
    TX=$(echo "($TX2 - $TX1) / 1024" | bc)
    echo "RX:${RX}KB/s TX:${TX}KB/s"
}

# Function to log system performance
log_system_performance() {
    while true; do
        CPU_USAGE=$(get_cpu_usage)
        MEM_USAGE=$(get_mem_usage)
        DISK_USAGE=$(get_disk_usage)
        NETWORK_USAGE=$(get_network_usage)
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

        LOG_ENTRY="$TIMESTAMP | CPU: ${CPU_USAGE}% | MEM: ${MEM_USAGE}% | Disk: ${DISK_USAGE} | Net: ${NETWORK_USAGE}"
        echo "$LOG_ENTRY"
        echo "$LOG_ENTRY" >> "$LOGFILE"

        sleep "$INTERVAL"
    done
}

# Run the monitoring function
log_system_performance
