#!/bin/bash

# ---- constants ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
# -------------------------

VOLUME_LABEL="evBOOT"  # New volume label

echo "Creating EFI System Partition (ESP)..."
if ! mkdir -p ./build/esp/EFI/BOOT; then
    echo -e "${RED}Failed to create EFI System Partition (ESP).${NC}"
    exit 1
fi

echo "Compiling..."
if ! gcc -ffreestanding -mno-red-zone -maccumulate-outgoing-args -c -o ./build/efiboot.o ./boot/efiboot.asm; then
    echo -e "${RED}Compilation failed.${NC}"
    exit 1
else
    echo -e "${GREEN}No compilation errors encountered. Proceeding.${NC}"
fi


echo "Creating linker script..."
if ! echo -e "ENTRY(efi_main)\n\nSECTIONS {\n    . = 0x1000;\n    .text : { *(.text) }\n    .data : { *(.data) }\n    .bss : { *(.bss) }\n    /DISCARD/ : { *(.eh_frame) *(.comment) }\n}" > ./build/linker.lds; then
    echo -e "${RED}Failed to create linker script.${NC}"
    exit 1
fi

echo "Linking..."
if ! ld -nostdlib -znocombreloc -T ./build/linker.lds -Bsymbolic -L /usr/lib /usr/lib/crt0-efi-x86_64.o ./build/efiboot.o /usr/lib/x86_64-linux-gnu/crti.o /usr/lib/x86_64-linux-gnu/crtn.o -lefi -lgnuefi -o ./build/efiboot.efi; then
    echo -e "${RED}There were link errors! Please check.${NC}"
    exit 1
else
    echo -e "${GREEN}No link errors encountered. Proceeding.${NC}"
fi


echo "Creating ESP image file..."
if ! dd if=/dev/zero of=./build/esp_image bs=1M count=100; then
    echo -e "${RED}Failed to create ESP image file.${NC}"
    exit 1
fi

echo "Creating FAT32 filesystem..."
if ! mkfs.fat -n "$VOLUME_LABEL" ./build/esp_image; then
    echo -e "${RED}Failed to create FAT32 filesystem.${NC}"
    exit 1
fi

echo "Mounting EFI System Partition (ESP) image..."
if ! sudo mount -o loop ./build/esp_image ./build/esp; then
    echo -e "${RED}Failed to mount EFI System Partition (ESP) image.${NC}"
    #exit 1
fi

echo "Copying bootloader to EFI System Partition (ESP)..."
if ! sudo cp ./build/bootx64.efi ./build/esp/EFI/BOOT/BOOTX64.EFI; then
    echo -e "${RED}Failed to copy bootloader to EFI System Partition (ESP).${NC}"
    exit 1
fi

echo "Unmounting EFI System Partition (ESP) image..."
if ! sudo umount ./build/esp; then
    echo -e "${RED}Failed to unmount EFI System Partition (ESP) image.${NC}"
    exit 1
fi

echo "Creating ISO image..."
if ! mkisofs -quiet -J -R -V "$VOLUME_LABEL" -o ./build/evOS-x64.iso -eltorito-alt-boot -e esp_image -no-emul-boot -b esp_image ./build/esp_image; then
    echo -e "${RED}Failed to create ISO image.${NC}"
    exit 1
else
    echo -e "${GREEN}ISO image created.${NC}"
fi

rm ./build/efiboot.efi
rm ./build/efiboot.o
rm ./build/efiboot.efi.o
rm ./build/esp_image

echo "Checking for running instances..."
if ! vmrun stop /home/venemo/vmware/evOS-testing/evOS-testing.vmx; then
    echo -e "${GREEN}No running instances found. Starting VM...${NC}"
else
    echo -e "${RED}Running instances found. Quitting and running new instance...${NC}"
fi

if ! vmrun start /home/venemo/vmware/evOS-testing/evOS-testing.vmx; then
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
