 	.model	small	
	.stack	100h
	.486
	.data
a	dw	-127
b	dw	-127
c	dw	-127
d	dw	-127
e	dw	-127
	.code
	mov	ax,@data
	mov	ds,ax
	mov	ax, a		; a in BX
	SAL	ax, 1
	cwde
	mov	ebx, eax
	mov	ax, b
	imul	ax		; b^2 in EAX
	cwde
	add	eax, ebx	; 2a+b^2 in EAX
	mov	ebx, eax
	mov	ax, a
	imul	ax
	cwde
	SAL	eax, 2		; 4a^2 in ECX
	xchg	eax, ebx
	idiv	ebx		; (2a + b^2)/4a^2
	push	eax
	
	mov	ax, c
	imul	ax
	cwde
	mov	ebx, eax
	mov	ax, a	
	cwde
	imul	ebx
	mov	ebx, eax	
	mov	ax, d
	imul	ax
	cwde
	xchg	eax, ebx
	sub	eax, ebx	
	mov	ebx, eax	
	mov	ax, e
	SAL	ax, 1
	cwde
	xchg	eax, ebx
	idiv	ebx
	pop	ebx
	add	eax, ebx

	mov	ax,4c00h
	int	21h
	end	


