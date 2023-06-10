BITS 32              ; Set the assembly mode to 32-bit

section .text
    global _start

_start:
    ; Set up the EFI system table pointer in register ebx
    mov ebx, 0x2c

    ; Call the EFI system table initialization function
    call efi_main

    ; Terminate the bootloader
    jmp $

; EFI system table initialization function
efi_main:
    ; Save the EFI system table pointer
    mov [esi], ebx

    ; Call the Print function to display a message
    mov edi, message
    call efi_print

    ; Halt the system
    mov eax, 0
    mov ebx, 0x1000
    int 0x15

; Print function
efi_print:
    ; Set up the function number (0x00000003) in register eax
    mov eax, 0x00000003

    ; Call the firmware's print service
    jmp dword [esi + 4]

section .data
    message db "Hello, EFI!", 0
