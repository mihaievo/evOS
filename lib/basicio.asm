[BITS 16]
; BIOS COMMANDS
; ==========================================================================
;                PRINT STRING FUNCTION                                      
; ===========================================================================
%MACRO printStr 1
mov si, %1
	call bios_print_string
%ENDMACRO

bios_print_string:
	mov ah, 0Eh		; int 10h 'print char' function

.repeat:
	lodsb			; Get character from string via LOAD into AL string byte
	cmp al, 0
	je .done		; If char is zero, end of string
	int 10h			; Otherwise, print its
	jmp .repeat

.done:
	ret