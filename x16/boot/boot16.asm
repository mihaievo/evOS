[BITS 16]
;start
jmp boot_routine

;includes
%INCLUDE "./lib/basicio.asm" ; basic IO functions
%INCLUDE "./var/sysconst.asm" ; attach system variables

; CODE
boot_routine:

    mov ax, 07C0h		; Set up 4K stack space after this bootloader
	add ax, 288		; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096

	mov ax, 07C0h		; Set data segment to where we're loaded
	mov ds, ax

mov AH, 00H            ;Video Mode number 
mov AL, 02H            ;Mode Number, refer the BIOS Function List above
int   10H                  ;Call the function

printStrColor welcomeMsg, b16_BLACK, b16_YELLOW ; welcome!
printStr newline
printStr verMsg
printStr initMsg

; hide cursor
mov ah, 01h
mov cx, 2607h
int 10h

call anim

jmp $ ; infinite loop - halt system

;data
welcomeMsg db "evOS bootloader", 0
verMsg db boot_ver, endl, 0
initMsg db "[/] Initiating boot sequence...", 0
newline db 0xA, 0xD, 0
animLoadBSlash db "\", 0
animLoadSlash db "/", 0
animLoadMidSlash db "|", 0
animLoadMinus db "-", 0

;BOOT SECTOR
times 510-($-$$) db 0 ;  must fit into 512 bytes, last 2 are boot sector ID rest will be 0 if not used
dw 0xAA55 ; BIOS boot sector ID