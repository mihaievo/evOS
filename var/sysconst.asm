; =======================
; STRING CONSTANTS
; =======================
%DEFINE endl 0xA, 0xD
nextl equ 0xA
startl equ 0xD

; =======================
; 16 bit colors
; ========================
b16_BLACK equ 0000b
b16_BLUE equ 0001b
b16_GREEN equ 0010b ;Green
b16_CYAN equ 0011b ;Cyan
b16_RED equ 0100b ;Red
b16_MAGENTA equ 0101b ;Magenta
b16_BROWN equ 0110b ;Brown
b16_WHITE equ 0111b ;White
b16_GRAY equ 1000b ;Gray
b16_LBLUE equ 1001b ;LightBlue
b16_LGREEN equ 1010b ;LightGreen
b16_LCYAN equ 1011b ;LightCyan
b16_LRED equ 1100b ;LightRed
b16_LMAGENTA equ 1101b ;LightMagenta
b16_YELLOW equ 1110b ;Yellow
b16_BWHITE equ 1111b ;BrightWhite

; =======================
; EVOS VARS
; =======================
%DEFINE boot_ver "v0.1.1a"
%DEFINE os_devname "venemo"