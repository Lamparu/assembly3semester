.model small
.stack 100h
.486
.data
n	db	4		; stolb
m	db	3		; stroka
max	dw	?
min	dw	?
matrix	dw	2, 7, 4, 1
	dw	3, 8, 9, 0
	dw	0, 1, 0, 0
.code
	mov	ax, @data
	mov	ds, ax
	mov 	es, ax
	cmp	n, 0
	jle	@er
	cmp	m, 0
	jle	@er

	mov	al, n		
	mov	bl, m
	imul	bl 		; size of matrix
	xor	bx, bx		; bx - index
	xor 	dx, dx		; register for comparing
	mov	dx, WORD PTR matrix[bx]	
	mov	max, dx
	mov	min, dx
	push	ax
	dec	ax
	mov	cx, ax		; size-1 in counter CX

@loop_start:	inc	bx
	shl	bx, 1
	mov	dx, WORD PTR matrix[bx]
	shr	bx, 1
	cmp	min, dx
	JLE 	@m1
	mov	min, dx

@m1:	cmp	max, dx
	JGE	@m2
	mov	max, dx

@m2:	loop	@loop_start

	mov	dx, min 	; min in DX
	mov	ax, max		; max in AX

	xor 	bx,bx
	pop	cx		; size in counter
	push	cx
@edit_mat:	
	test	cx, 1
	JZ	@m3
	shl	bx, 1
	mov	WORD PTR matrix[bx], ax
	shr	bx, 1	
	jmp	@m4
@m3:	shl	bx, 1
	mov	WORD PTR matrix[bx], dx	
	shr	bx, 1
@m4:	inc bx
	loop	@edit_mat

	xor 	bx, bx
	pop	cx
@show:	shl	bx, 1
	mov	ax, WORD PTR matrix[bx]
	shr 	bx, 1
	inc	bx
	loop	@show

	mov	ax, 4c00h
@ex: 	int	21h
@er: 	mov	ax, 4c01h
	jmp	@ex
	end