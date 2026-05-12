%ifndef ASM_FAIL_H
%define ASM_FAIL_H

%include "std.asm"

; messages:
msg_error_floppy: db 'Failed to read from disk', ENDL, 0

wait_key_and_reboot:
	call await_keypress
	call reboot

; called on floppy read error
error_floppy:
	mov si, msg_error_floppy
	call puts
	cli
	jmp wait_key_and_reboot
	hlt



%endif
