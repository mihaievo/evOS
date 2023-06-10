section .data
    hello_string db "Hello, EFI!", 0

section .text
    global efi_main

efi_main:
    ; Set up the stack frame
    mov rsp, 0x8000

    ; Call the UEFI entry point
    call uefi_entry

    ; Infinite loop
.loop:
    jmp .loop

; UEFI entry point
uefi_entry:
    ; Save EFI system table pointer in rdi
    mov rdi, [rsp + 8]

    ; Get the system table pointer from EFI system table
    mov rsi, [rdi + 8]

    ; Save the current image handle
    mov r8, [rdi + 16]

    ; Get the ConsoleOut handle
    mov r9, [rdi + 24]

    ; Locate the Print function from the system table
    mov rdi, rsi
    xor eax, eax
    call locate_protocol

    ; Save the Print function pointer in rbx
    mov rbx, rax

    ; Clear the screen
    xor rsi, rsi
    xor rdx, rdx
    mov rdi, r9
    call qword [rbx + print_func_offset]    ; ConsoleClearScreen

    ; Print "Hello, EFI!" message
    lea rdi, [hello_string]
    call qword [rbx]    ; ConsoleOutputString

    ; Exit the UEFI application
    xor edi, edi
    mov eax, 0x4c
    call qword [rsi + exit_func_offset]    ; Exit

    ret

; Locate a protocol from the system table
locate_protocol:
    push rbx
    push rdi
    push rsi
    push rdx
    push r8
    push r9

    mov rbx, [rdi + number_of_entries_offset]    ; NumberOfTableEntries
    mov rdi, [rdi + config_table_offset]    ; ConfigurationTable

.find_protocol:
    dec rbx
    js .protocol_not_found

    mov rsi, [rdi]    ; VendorGuid
    xor eax, eax
    cmp rsi, rax
    je .found_protocol

    add rdi, config_table_entry_size    ; NextEntry

    jmp .find_protocol

.found_protocol:
    mov rax, [rdi + vendor_table_offset]    ; VendorTable
    jmp .protocol_found

.protocol_not_found:
    xor rax, rax

.protocol_found:
    pop r9
    pop r8
    pop rdx
    pop rsi
    pop rdi
    pop rbx
    ret

; Constants for RIP-relative addressing
number_of_entries_offset equ $ - uefi_entry + 40
config_table_offset equ $ - uefi_entry + 48
config_table_entry_size equ 24
vendor_table_offset equ $ - uefi_entry + 16
print_func_offset equ $ - uefi_entry + 16
exit_func_offset equ $ - uefi_entry + 40
