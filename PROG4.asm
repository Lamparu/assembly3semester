.model small
.stack 100h
.486
.data
lens 	db 	50 	dup(?)	; lens of words
ptrs 	dw	50	dup(?)	; ptrs to the start of words
n	dw	?	; amount of words
delit	db	' ', ';', ',', 0
string 	db 	'Hello   world;Doing,;great', 0
newstr	db	30	dup(?)	; result string
sumlen	dw	30
.code
	mov	ax, @data
	mov	ds, ax 	; input string
	mov	es, ax	; result string
; 1 part - COUNT WORDS
	cld
	lea	si, string
	lea	di, delit
	xor	bx, bx	; counter of words
	xor	dx, dx	; counter of lens of all words
@m1:	call	space	; returns beginning of a word
	cmp	byte ptr [si], 0	; end of str?
	JE	@m2	; if end - move to the second part 
	shl	bx, 1	; if its a beginning of a word
	mov	ptrs[bx], si	; insert the beginning in mass
	shr	bx, 1
	mov	cx, si
	call	words	; return 1 symbol after word
	sub	cx, si	; cx - len of word
	neg	cx
	mov	lens[bx], cl
	add	dx, cx	; counter of len of all words
	inc	bx
	cmp	byte ptr [si], 0
	JNE	@m1


; 2 part - CHECK STRING
@m2:	mov 	n, bx	; amount of words in n 
	add	dx, n
	dec	dx	; needed amount of symbols
	cmp	dx, sumlen	; if dx > sumlen - error
	JG	@er	; if not enough space in result str


; 3 part - INSERT SPACES
	xor	bx, bx
	inc	dx
	sub	dx, n
	mov	ax, sumlen
	sub	ax, dx	; needed amount of spaces in AX
	dec	n
	xor	dx, dx
	div	n	; in AX + DX amount of nedded spaces between 2 words 
	inc	n
	lea	di, newstr
	push	ax
	mov	cx, n
@m3:	or	bx, bx 	; was str empty?
	JE	@m4
	cmp	dx, 0
	JE	@noadd
	push	ax
	mov	al, ' '
	stosb
	pop	ax
	dec	dx
@noadd:	push	cx
	mov	cx, ax
@onesp:	push	ax
	mov	al, ' '
	stosb
	pop	ax
	loop	@onesp
	pop	cx
@m4: 	push 	cx
	shl	bx, 1
	mov	si, ptrs[bx] 	; the beginning of a word
	shr	bx, 1
	mov	cl, lens[bx]	; len of a word
	xor	ch, ch
	rep	movsb	; copy to di symbol from si cx times
	inc	bx
	pop	cx
	loop	@m3
	xor	al, al
	stosb

	mov	ax, 4c00h
@ex:	int	21h
@er:	mov	ax, 4c01h
	jmp	@ex

space	proc
locals 	@@
	push 	ax
	push	cx
	push	di
	xor	al, al
	mov	cx, 65535
	repne	scasb	; repeat while 0 in al not equal to di
	neg	cx
	dec	cx	
	push	cx
@@m1:	pop	cx
	pop	di
	push	di
	push	cx
	lodsb		; from SI to AL
	repne	scasb	; while al not equal to di 
	JCXZ	@@m2	; cx = 0 => symbol not in delit
	jmp	@@m1	; check again
@@m2:	dec	si
	add	sp, 2
	pop	di
	pop	cx
	pop	ax
	ret
endp

words	proc
locals 	@@
	push	ax
	push	cx
	push	di
	xor	al, al
	mov	cx, 65535
	repne	scasb
	neg	cx
	push	cx
@@m:	pop	cx
	pop	di
	push	di
	push	cx
	lodsb
	repne	scasb
	JCXZ	@@m
	dec	si
	add	sp, 2
	pop	di
	pop	cx
	pop	ax
	ret
endp

end