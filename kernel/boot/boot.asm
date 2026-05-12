; pOS boot ASM
org 0x7C00
bits 16


jmp short start
nop

%include "fat12.asm"

section .text
start:
	; setup data segments
	mov ax, 0
	mov ds, ax
	mov es, ax

	; setup stack
	mov sp, 0x7C00

	mov si, msg_test
	call puts

	mov [ebr_drive_number], dl
	mov ax, 1
	mov cl, 1
	mov bx, 0x7E00 ; after the bootloader
	call disk_read

	; exit
	cli
.halt:
	hlt
	jmp .halt


%include "disk.asm"
%include "std.asm"

msg_test: db 'Hello World!', ENDL, 0

times 510-($-$$) db 0
dw 0xAA55
