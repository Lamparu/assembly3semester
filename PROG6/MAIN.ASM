.model medium
.stack 100h
.486

public 	start
extrn 	lens:byte 
extrn	ptrs:word
extrn	n:word
extrn	m:word
extrn	delit:byte
extrn	sumlen:word

extrn	f_in:byte
extrn	f_out:byte

extrn	ch1:byte
extrn	ch2:byte
extrn	ch3:byte
extrn	ch4:byte
extrn	ch0:byte
extrn	er1:byte
extrn	er:byte
extrn	opf:byte
extrn	filer:byte
extrn	filew:byte
extrn	mes2:byte
extrn	ibuf:byte
extrn	ibuf_big:byte
extrn	obuf:byte
extrn	inp:byte
extrn	ans:byte

extrn	writestr:far
extrn	space:far
extrn	words:far
extrn	menu:far
extrn	inputline:far
extrn	input:far
extrn	writefile:far
extrn	readfile:far
extrn	algo:far

.code

start:	mov	ax, @data
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

end start