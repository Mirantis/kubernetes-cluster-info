#!/bin/bash

# make sure the necessary files exist in the PWD
if [ ! -f ucp-nodes.txt ] || [ ! -f ucp-instance-id.txt ]
then
  echo "ERROR: Unable to find ucp-nodes.txt or ucp-instance-id.txt"
  echo "  Hint: are you running this script from the directory where support dump is extracted?"
  exit 1
fi

# calculate needed values
nanoCPUs="$(grep NanoCPUs ucp-nodes.txt | awk '{print $2}' | awk -F ',' '{print $1}')" &&\
CPUs=$(for i in ${nanoCPUs}; do   echo "$((i/1000000000))"; done) &&\
ttlCPU="$(count=0; total=0; for i in ${CPUs};do total=$(echo "$total+$i" | bc ); ((count++)); done; echo "${total}")"
node_count=$(echo "${CPUs}" | wc -l | tr -d " ")
avgCPU="$(echo "scale=2; $ttlCPU / $node_count" | bc)"
minCPU="$(echo "${CPUs}" | sort -n | head -1)"
maxCPU="$(echo "${CPUs}" | sort -n | tail -n 1)"
CPU_sizes="$(echo "${CPUs}" | sort -n | uniq)"

# output cluster id
echo "ClusterID - $(cat ucp-instance-id.txt)"

# CPU size report
for size in ${CPU_sizes}
do
  echo -n "${size} Core x "
  echo "${CPUs}" | grep "${size}" | sort -n | wc -l | tr -d " "
done

echo
echo "# Nodes  - ${node_count}"
echo "Ttl Core - ${ttlCPU}"
echo "Min Core - ${minCPU}"
echo "Max Core - ${maxCPU}"
echo "Avg Core - ${avgCPU}"

# gather Mirantis Container Runtime (MCR) information
echo "---- Mirantis Container Runtime (MCR) Information ----"

# Check if Docker is installed
if command -v docker &> /dev/null; then
    echo "Docker Version:"
    docker version
    echo "Docker Info:"
    docker info
else
    echo "Docker is not installed or not in the system's PATH."
fi

# Check if containerd is installed
if command -v containerd &> /dev/null; then
    echo "Containerd Version:"
    containerd --version
else
    echo "Containerd is not installed or not in the system's PATH."
fi

# Check if ctr (containerd CLI) is installed
if command -v ctr &> /dev/null; then
    echo "Containerd CLI (ctr) Version:"
    ctr version
    echo "List of Running Containers:"
    ctr containers list
else
    echo "Containerd CLI (ctr) is not installed or not in the system's PATH."
fi
