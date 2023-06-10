ARCH = $(shell uname -m | sed s,i[3456789]86,ia32,)

OBJS = ./build/efiboot.o
TARGET = ./build/efiboot.efi

EFIINC = /usr/include/efi
EFIINCS = -I$(EFIINC) -I$(EFIINC)/$(ARCH) -I$(EFIINC)/protocol
EFILIB = /usr/lib
EFI_CRT_OBJS = $(EFILIB)/crt0-efi-$(ARCH).o
EFI_LDS = $(EFILIB)/elf_$(ARCH)_efi.lds

CFLAGS = $(EFIINCS) -ffreestanding -mno-red-zone -maccumulate-outgoing-args \
         -fshort-wchar -Wall -fPIC
ifeq ($(ARCH),x86_64)
  CFLAGS += -DEFI_FUNCTION_WRAPPER
endif

LDFLAGS = -nostdlib -znocombreloc -T $(EFI_LDS) -shared \
          -Bsymbolic -L $(EFILIB) $(EFI_CRT_OBJS)

all: $(TARGET)

$(TARGET): $(OBJS)
	ld $(LDFLAGS) $(OBJS) -o $@ -lefi -lgnuefi

./build/efiboot.o: ./boot/efiboot.asm
	gcc -ffreestanding -mno-red-zone -maccumulate-outgoing-args -fshort-wchar -Wall -fPIC -c -o ./build/efiboot.o ./boot/efiboot.asm

.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET)
