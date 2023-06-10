# ---- constants ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
# -------------------------

echo "Compiling..."
if [[ $(nasm boot16.asm -f bin -o ./build/boot16-evos.bin) ]]; then
    echo -e "${RED}There were compilation errors! Please check.${NC}"
else
    echo -e "${GREEN}No compilation errors encountered. Proceeding.${NC}"
fi
echo "Building into .flp image..."
if [[ $(dd status=noxfer conv=notrunc if=./build/boot16-evos.bin of=./build/testing.flp) ]]; then
    echo -e "${RED}Build encountered errors.${NC}"
else
    echo -e "${GREEN}Build completed.${NC}"
fi
echo "Checking for running instances..."
if [[$(vmrun stop ~/vmware/evOS-testing/evOS-testing.vmx) ]]; then
    echo -e "${GREEN}No running instances found. Starting VM...${NC}"
else
    echo -e "${RED}Running instances found. Quitting and running new instance...${NC}"
fi
if [[ $(vmrun start ~/vmware/evOS-testing/evOS-testing.vmx) ]]; then
    echo -e "${RED}Instance already running.${NC}"
else
    echo -e "${GREEN}VM started.${NC}"
fi
echo "Bringing to front..."
pids=" $(pidof vmware) "
wmctrl -lp | while read id a pid b; do
  test "${pids/ $pid }" != "$pids" && wmctrl -i -a $id
done
echo -e "${GREEN}Complete.${NC}"