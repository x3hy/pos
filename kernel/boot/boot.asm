; pOS boot ASM
org 0x7C00
bits 16

jmp short start
nop

bdb_oem: db 'MSWIN4.1'
bdb_bytes_per_sector: dw 512
bdb_sectores_per_cluster: db 1
bdb_reserved_sectors: dw 1
bdb_fat_count: db 2
bdb_dir_entries_count: dw 0E0h
bdb_total_sectors: dw 2880
bdb_media_descriptor_type: db 0F0h
bdb_sectors_per_fat: dw 9
bdb_sectors_per_track: dw 18
bdb_heads: dw 2
bdb_hidden_secrets: dd 0
bdb_large_sector_count: dd 0

; extended boot record
ebr_drive_number: db 0
ebr_signature: db 29h
ebr_volume_id: db 12h, 34h, 56h, 78h
ebr_volume_label: db 'pos        '
ebr_system_id: db 'FAT12   '


section .text
start:
	; setup data segments
	mov ax, 0
	mov ds, ax
	mov es, ax

	; setup stack
	mov ss, ax
	mov sp, 0x7C00

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


; required for errors


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

	

%include "std.asm"
times 510-($-$$) db 0
dw 0xAA55
