.model medium
public lens, ptrs, n, m, delit, sumlen, f_in, f_out, ch1, ch2, ch3, ch4, ch0, er1, er, mes2, ibuf, ibuf_big, obuf, inp, ans, opf, filer, filew

.data

lens 	db 	50 	dup(?)	; lens of words
ptrs 	dw	50	dup(?)	; ptrs to the start of words
n	dw	?	; amount of words
m	dw	?	; amount of strings
delit	db	' ', ';', ',', 13, 10, 0
sumlen	dw	30

f_in	db	'prog6\in.txt', 0h 	; Input file
f_out 	db	'prog6\out.txt', 0h	; Output file

;MENU
ch1	db	'1. Input from keyboard$'
ch2	db	'2. Read from file$'
ch3	db	'3. Show on screen$'
ch4	db	'4. Write to file$'
ch0	db	'0. Exit$'
er1	db	'Wrong input, try again$'
er	db	'Error$'
opf	db	'File opened$'
filer	db	'Data read from file$'
filew	db	'Written to file$'
mes2	db	'Enter line:$'
ibuf	db	100 	dup(0)
ibuf_big	db	4095 	dup(0)
obuf	db	4095 	dup(0)
inp	db	'Input text. To end input blank line$'
ans	db	4, 2 dup(0)

end