; pOS bootloader
org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

; prints a string to the screen
; takes ds:si pointers to a string
puts:
	push si
	push ax

; loop through each char in al
.loop:
	lodsb ; loads next char in al
	or al, al ; check if char is null

	; exit loop
	jz .done

	; print char to screen and continue loop
	mov ah, 0x0e
	int 0x10
	jmp .loop

.done:
	pop ax
	pop si
	ret

main:
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
	hlt

.halt:
	jmp .halt

msg_test: db 'Waddup faggots!', ENDL, 0

times 510-($-$$) db 0
dw 0xAA55
