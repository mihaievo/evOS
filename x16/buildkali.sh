#!/bin/bash

# ---- constants ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
# -------------------------

echo "Compiling..."
if ! nasm ./boot/boot16.asm -f bin -o ./build/boot16-evos.bin 2> ./build/compilation_errors.txt; then
    echo -e "${RED}There were compilation errors! Please check.${NC}"
    echo "Compilation errors:"
    cat ./build/compilation_errors.txt
    rm ./build/compilation_errors.txt
    exit 1
else
    echo -e "${GREEN}No compilation errors encountered. Proceeding.${NC}"
fi

echo "Building into .flp image..."
if ! dd conv=notrunc if=./build/boot16-evos.bin of=./build/testing.flp 2> /dev/null; then
    echo -e "${RED}Build encountered errors.${NC}"
    exit 1
else
    echo -e "${GREEN}Build completed.${NC}"
fi

echo "Checking for running instances..."
if ! vmrun stop ~/vmware/evOS-testing/evOS-testing.vmx; then
    echo -e "${GREEN}No running instances found. Starting VM...${NC}"
else
    echo -e "${RED}Running instances found. Quitting and running new instance...${NC}"
fi

if vmrun start ~/vmware/evOS-testing/evOS-testing.vmx; then
    echo -e "${RED}Instance already running.${NC}"
else
    echo -e "${GREEN}VM started.${NC}"
fi

# Check if vmrun encountered any errors
vmrun_exit_code=$?
if [ $vmrun_exit_code -ne 0 ]; then
    echo -e "${RED}vmrun command encountered an error. Script execution stopped.${NC}"
    exit 1
fi

echo "Bringing to front..."
pids=" $(pidof vmware) "
wmctrl -lp | while read -r id a pid b; do
    test "${pids/ $pid }" != "$pids" && wmctrl -i -a "$id"
done

echo -e "${GREEN}Complete.${NC}"
