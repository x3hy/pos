%ifndef ASM_STD_H
%define ASM_STD_H
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

await_keypress:
	mov ah, 0
	int 16h
	ret

reboot:
	cli
	jmp 0FFFFh:0 ; Jump to the beginning of the bios
	ret;

%endif; ASM_STD_H
