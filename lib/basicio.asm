[BITS 16]
; BIOS COMMANDS
; ===========================================================================
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

; ===========================================================================
;                PRINT STRING WITH COLOR FUNCTION                            
; ===========================================================================

%MACRO printStrColor 3 ; string, bgcolor, forecolor
mov si, %1
mov bl, %2
shl bl, 4
add bl, %3
    call bios_printcolor_string
%ENDMACRO

bios_printcolor_string:
    ; GET CURSOR DATA
    mov ah, 03h
    mov bh, 00h
    int 10h
    xor cx, cx
    mov cx, 1


.repeat:

    mov ah, 02h ; move cursor
    int 10h
	lodsb			; Get character from string via LOAD into AL string byte
	cmp al, 0
	je .done		; If char is zero, end of string
    mov ah, 09h
	int 10h			; Otherwise, print its
    inc dl ; column
	jmp .repeat

.done:
	ret

; cursor animation
anim:
call animcursor
printStrColor animLoadMidSlash, b16_BLACK, b16_YELLOW
call animcursor
call delay
printStrColor animLoadSlash, b16_BLACK, b16_YELLOW
call animcursor
call delay
printStrColor animLoadMinus, b16_BLACK, b16_YELLOW
call animcursor
call delay
printStrColor animLoadBSlash, b16_BLACK, b16_YELLOW
call animcursor
call delay
printStrColor animLoadMidSlash, b16_BLACK, b16_YELLOW
call animcursor
call delay
printStrColor animLoadSlash, b16_BLACK, b16_YELLOW
call animcursor
call delay
printStrColor animLoadMinus, b16_BLACK, b16_YELLOW
call animcursor
call delay
printStrColor animLoadBSlash, b16_BLACK, b16_YELLOW
call animcursor
call delay
jmp anim

animcursor:
mov  dx, 0201h
mov bh, 0
mov ah, 02h
int 10h
ret

delay:
mov al, 0
mov ah, 86h
mov cx, 1
mov dx, 2
int 15h
ret