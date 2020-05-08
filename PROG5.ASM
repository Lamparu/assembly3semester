.model small
.stack 100h
.486
.data

lens 	db 	50 	dup(?)	; lens of words
ptrs 	dw	50	dup(?)	; ptrs to the start of words
n	dw	?	; amount of words
m	dw	?	; amount of strings
delit	db	' ', ';', ',', 13, 10, 0
sumlen	dw	30

f_in	db	'prog5\in.txt', 0h 	; Input file
f_out 	db	'prog5\out.txt', 0h	; Output file

;MENU
ch1	db	'1. Input from keyboard$'
ch2	db	'2. Read from file$'
ch3	db	'3. Show on screen$'
ch4	db	'4. Write to file$'
ch0	db	'0. Exit$'
er1	db	'Wrong input, try again$'
opf	db	'File opened$'
filer	db	'Data read from file$'
filew	db	'Written to file$'
er	db	'Error$'
mes2	db	'Enter line:$'
ibuf	db	 100 	dup(0)
ibuf_big	db	4095 	dup(0)
obuf	db	 4095 	dup(0)
inp	db	'Input text. To end input blank line$'
ans	db	4, 2 dup(0)

.code

	mov	ax, @data
	mov	ds, ax	
	mov	es, ax
	cld

@menu:	
	call	menu
	cmp	al, '0'
	je	@exx

;KEYBOARD
@keybm:	cmp	al, '1'
	jne	@flinm
	lea	dx, inp
	call	writestr
	call	input	
	jc	@er
	call	algo
	jc	@er
	jmp	@menu

;FILE INPUT
@flinm:	cmp	al, '2'
	jne	@scrnm
	call	readfile
	jc	@er
	lea	dx, filer
	call	writestr
	call	algo
	jc	@er
	jmp	@menu
	
;SCREEN
@scrnm:	cmp	al, '3'
	jne	@floutm
	lea 	dx, obuf
	call	writestr
	;call	output
	jmp	@menu


;WRITE TO FILE
@floutm:
	cmp	al, '4'
	call	writefile
	jc	@er
	lea	dx, filew
	call	writestr
	jmp	@menu

; END
@exx:	mov    	ax, 4c00h
@ex:	int 	21h
@er:	lea 	dx, er
	call	writestr	
	mov	ax, 4c01h
	jmp	@ex



writestr PROC
	push	ax
	mov	ah, 09h
	int 	21h
	mov	ah, 0eh	; write symbol on active screen
	mov	al, 0ah	; 'enter'
	int 	10h
	mov	al, 0eh
	mov	al, 0dh	; return coursor
	int 	10h
	pop	ax
	ret
endp


space	PROC
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


words	PROC
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


menu PROC
;alternatives
locals @@
	push	dx
	xor	dx ,dx
	lea	dx, ch1
	call	writestr
	xor	dx, dx
	lea	dx, ch2
	call	writestr
	xor	dx, dx
	lea	dx, ch3
	call	writestr
	xor	dx, dx
	lea	dx, ch4
	call	writestr
	xor	dx, dx
	lea	dx, ch0
	call	writestr
	
@@inp:	xor	dx, dx
	lea	dx, ans
	mov	ah, 0ah	; buff input
	int	21h
	lea	di, ans
	mov	al, [di+2]

	cmp	al, '0'
	je	@@ex
	cmp	al, '1'
	je	@@ex
	cmp	al, '2'
	je	@@ex
	cmp	al, '3'
	je	@@ex
	cmp	al, '4'
	je	@@ex
	lea	dx, er1
	call	writestr
	jmp	@@inp
@@ex:	pop	dx
	ret
endp


inputline PROC
locals @@
	push 	bp
	mov	bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	mov	ah, 3fh
	xor	bx, bx
	mov	cx, 80
	lea	dx, ibuf
	int	21h
	jc	@@ex
	cmp	ax, 80
	jne	@@m
	stc
	jmp short @@ex
@@m:	lea	di, ibuf
	dec	ax
	dec	ax
	add	di, ax
	xor	al, al
	stosb
@@ex:	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	ret
endp	


input 	PROC
locals @@
	push	bp
	mov	bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	xor	bx, bx 	; add keyb descriptor
	mov	cx, 4095	; to see hoe many bytes
	lea	dx, ibuf_big
@@m1:	mov	ah, 3fh
	int	21h
	jc	@@ex
	cmp	ax, 2 ; 13 and 10 in empty str
	je	@@m2
	sub	cx, ax
	jcxz	@@m2
	add	dx, ax
	jmp	@@m1
@@m2:	lea	di, ibuf
	add	di, 4095
	sub	di, cx
	xor	al, al
	stosb
@@ex:	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	ret
endp
	

writefile PROC
locals @@
	push	bp
	mov	bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	mov	ah, 3ch 	; create or rewrite file
	xor	cx, cx
	lea	dx, f_out
	int	21h
	jc	@@ex
	lea	dx, opf
	call	writestr
	mov	bx, ax
	lea	di, obuf
	xor	al, al 
	mov	cx, 0ffffh
	repne	scasb
	neg	cx
	dec	cx
	dec 	cx
	jcxz	@@ex1
	cmp	cx, 4095
	jbe	@@m
	mov	cx, 4095
@@m:	mov	ah, 40h
	lea	dx, obuf
	int	21h
	jc	@@er
@@ex1:	mov	ah, 3eh	
	int	21h
@@ex:	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp	
	ret	
@@er:	mov	ah, 3eh
	int 	21h
	stc
	jmp	@@ex
endp


readfile PROC
locals @@
	push	bp
	mov	bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	mov	ax, 3d00h ; readfile 
	lea	dx, f_in
	int	21h
	jc	@@ex
	lea	dx, opf
	call	writestr
	mov	bx, ax
	mov	cx, 4095
	lea	dx, ibuf_big
@@m1:	mov	ah, 3fh
	int	21h
	jc	@@er
	or	ax, ax ; cmp ax, 0
	je	@@m2
	sub	cx, ax
	jcxz	@@m2
	add	dx, ax
	jmp	@@m1
@@m2:	lea	di, ibuf_big
	add	di, 4095
	sub	di, cx
	xor	al, al
	stosb
	mov	ah, 3eh
	int 	21h
@@ex:	pop 	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	ret
@@er:	mov	ah, 3eh
	int 	21h
	stc	
	jmp	@@ex
endp


getstr	PROC
	push	di
	push	si
	push	ax
	push	cx
	lea	di, ibuf_big
	xor	al, al
	mov	cx, 65535
	repne	scasb	; repeat while 0 in al not equal to di
	neg	cx
	dec	cx	
	lea	si, ibuf_big
	lea	di, ibuf
	rep	movsb
	call	algo
	pop	cx
	pop	ax
	pop	si
	pop	di
	ret
endp
			

output	PROC
locals @@
	push 	bp
	mov 	bp,sp
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	di
	lea 	di, obuf
	xor 	al,al
	mov 	cx, 0ffffh
	repne scasb
	neg 	cx
	dec 	cx
	dec 	cx 	; кол-во байт, которые надо прочитать
	jcxz	 @@ex
	cmp 	cx, 4095
	jbe 	@@m
	mov 	cx, 4095
@@m:	mov 	ah, 40h
	xor 	bx, bx
	inc 	bx 	; 1 - экран
	lea 	dx, obuf
	int 	21h
@@ex:	pop 	di
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	pop 	bp
	ret
endp



algo	PROC
locals @@
	push	bp
	mov	bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	
; 1 part - COUNT WORDS
	lea	si, ibuf_big
	lea	di, delit
	push	si
	mov	m, 0
@@st:	pop	si
	lea	di, delit
	xor	bx, bx	; counter of words
	xor	dx, dx	; counter of lens of all words
	mov	n, 0
@@m1:	call	space	; returns beginning of a word
	cmp	byte ptr [si], 0
	JE	@@ex
	cmp	byte ptr [si], 13	; end of str?
	JE	@@m2	; if end - move to the second part
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
	JE	@@ex
	cmp	byte ptr [si], 13
	JNE	@@m1

; 2 part - CHECK STRING
@@m2:	lodsb
	lodsb
	push	si
	cmp	bx, 1
	JNE	@@nxt
	lea	di, obuf
	cmp	m, 0
	JE	@@on2
	mov	ax, m
	push	dx
	imul	sumlen
	add	di, ax
	mov	ax, 2
	imul	m
	pop	dx
	add	di, ax
@@on2:	dec	bx
	mov	si, ptrs[bx] 	; the beginning of a word
	mov	cl, lens[bx]	; len of a word
	xor	ch, ch
	rep	movsb
	mov	cx, sumlen	
	sub	cl, lens[bx]
	mov	al, ' '
@@adsp:	stosb	
	loop	@@adsp
	mov 	al, 13
	stosb	
	mov	al, 10
	stosb
	inc	m
	jmp	@@st
@@nxt:	mov 	n, bx	; amount of words in n 
	add	dx, n
	dec	dx	; needed amount of symbols
	;cmp	dx, sumlen	; if dx > sumlen - error
	;JG	@@er	; if not enough space in result str

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
	push	ax
	push	ax
	lea	di, obuf
	cmp	m, 0
	JE	@@on3
	mov	ax, m
	push	dx
	imul	sumlen
	add	di, ax
	mov	ax, 2
	imul	m
	pop	dx
	add	di, ax
@@on3:	pop	ax
	mov	cx, n
@@m3:	or	bx, bx 	; was str empty?
	JE	@@m4
	cmp	dx, 0
	JE	@@noadd
	push	ax
	mov	al, ' '
	stosb
	pop	ax
	dec	dx
@@noadd:	push	cx
	mov	cx, ax
@@onesp:	push	ax
	mov	al, ' '
	stosb
	pop	ax
	loop	@@onesp
	pop	cx
@@m4: 	push 	cx
	shl	bx, 1
	mov	si, ptrs[bx] 	; the beginning of a word
	shr	bx, 1
	mov	cl, lens[bx]	; len of a word
	xor	ch, ch
	rep	movsb	; copy to di symbol from si cx times
	inc	bx
	pop	cx
	loop	@@m3
	mov	al, 13
	stosb
	mov	al, 10
	stosb
	pop	ax
	inc	m
	jmp	@@st
@@ex:	lea	di, obuf
	cmp	m, 0
	JE	@@on1
	mov	ax, m
	imul	sumlen
	add	di, ax
	mov	ax, 2
	imul	m
	add	di, ax
@@on1:	xor	ax, ax
	stosb
	mov 	al, '$'
	stosb
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	ret
@@er:	mov	ah, 3eh
	int 	21h
	stc
	jmp	@@ex
endp
end