	.model small
	.stack 100h
	.486
	.data
num	dw	255
	.code
	mov	ax, @data
	mov	ds, ax	

	mov	ax, num
	cwde
	mov	ecx, eax
	dec	ecx
@loop_start:
	inc	ecx
	SHR	ecx, 1
	JAE	@pury		; if CF = 0
	inc	dl		; 1 in DL
	dec	dh
@pury:
	inc	dh		; 0 in DH		
	loop @loop_start
	inc	dl		; last 1
	mov	cl, dl		; 1 in CL
	mov	ch, dh		; 0 in CH
	mov	dh, 0
	add	dl, ch		; sum of 0 and 1

	mov	ax, 4c00h
	int	21h
	end