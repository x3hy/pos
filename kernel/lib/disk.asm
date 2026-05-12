%ifndef ASM_DISK_H
%define ASM_DISK_H

; LBA to CHS
; ax = LBA address
; returns:
; cx [bits 0-5]: sector number
; cx [bits 6-15]: cylinder
; dh: head
lba_to_chs:
	push ax

	; dx = 0
	xor dx, dx

	; ax = LBA / sectors_per_track
	; dx = LBA % sectors_per_track
	div word [bdb_sectors_per_track]

	; dx = (LBA % sectors_per_track) + 1
	inc dx

	; cx = sector
	mov cx, dx
	
	; reset dx to 0
	xor dx, dx

	; ax = (LBA / sectors_per_track) / heads = cylinder
	; dx = (LBA % sectors_per_track) / heads = head
	div word [bdb_heads]
	
	; dh = head
	mov dh, dl

	;  cylinder (lower 8 bits)
	mov ch, al

	; put upper 2 bits in cl
	shl ah, 6
	or cl, ah

	pop ax
	ret

; reads from the disk
; ax: LBA block address
; cl: number of sectors
; dl: drive number
; es:bx: memory location for output
disk_read:
	; save modified registers
	push ax
	push bx
	push cx
	push dx
	push di

	; save this, as its overwritten by the conversion func
	push cx
	call lba_to_chs
	
	; get number of sectors to read
	pop ax


	mov ah, 02h

	; floppy disks are unreliable, this function will read
	; di times to ensure a correct operation.
	mov di, 2

.retry_loop:
	pusha

	; sets the carry flag for call 13h
	stc

	; calls the read
	int 13h

	; if the carry flag is cleared it means everything went
	; correctly.
	jnc .done
	popa
	
	; operation failed
	call disk_reset
	dec di
	test di, di
	jnz .retry_loop
.fail:
	jmp error_floppy
	hlt

.done:
	popa
	
	push di
	push dx
	push cx
	push bx
	push ax
	ret

; dl = drive number
disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc error_floppy
	popa
	ret
%endif
