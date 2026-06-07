org 0x0
bits 16

%define ENDL 0x0D, 0x0A

start:
	; print hello world message
	mov si, msg_hello
	call puts

.halt:
	cli
	hlt

%include "std.asm"


msg_hello: db 'STAGE2 loaded..', ENDL, 0
