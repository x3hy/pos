; pOS boot ASM
org 0x7C00
bits 16

%include "std.asm"

section .text
start:
	; setup data segments
	mov ax, 0
	mov ds, ax
	mov es, ax

	; setup stack
	mov ss, ax
	mov sp, 0x7C00

	; print startup message
	mov si, msg_test
	call puts
	; exit
	cli
.halt:
	hlt
	jmp .halt

msg_test: db 'Hello World!', ENDL, 0

times 510-($-$$) db 0
dw 0xAA55
