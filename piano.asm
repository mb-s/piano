IDEAL
MODEL small
STACK 100h

;redefines current octave as lower or higher
MACRO changeoctave newoct
	local tochange

	lea bx, [currentoct]
	lea di, [newoct]
	
	mov cx, 12
	
tochange:
	
	push [di]
	pop [bx]
	add bx, 2
	add di, 2
	
loop tochange
	
ENDM

;changes frequency and defines tile color
MACRO notes color
	
	out 42h, al
	mov al, ah
	out 42h, al
	mov [tclr], color
	
ENDM

DATASEG
; --------------------------
	tclr db ?
	tilesp dw ?
	tstop dw ?
	errormsg db 'This key does nothing...$'
	nooctmsg db 'This is the last octave$'
	instructmsg db 'Use left and right arrows to change     octave and press Esc to leave$'
	deletmsg db '                           $'
	keysmsg db '    X  D  C F  V   B  H  N J  M K  ,$'
	lowoct dw 9120, 8608, 8126, 7668, 7228, 6832, 6448, 6086, 5746, 5422, 5118, 4830
	midoct dw 4560, 4304, 4063, 3834, 3614, 3416, 3224, 3043, 2873, 2711, 2559, 2415
	highoct dw 2280, 2152, 2031, 1917, 1807, 1708, 1612, 1521, 1436, 1355, 1279, 1207
	currentoct dw 4560, 4304, 4063, 3834, 3614, 3416, 3224, 3043, 2873, 2711, 2559, 2415
	currentkey db ?
; --------------------------
CODESEG

;prints on screen message that the user can't go further in the octave range
proc printoctmsg

	lea dx, [nooctmsg]
	mov ah, 9h
	int 21h
	
	ret
endp
	
;for if the user pressed a meaningless key. prints error message
proc printerrormsg

	in al, 61h
	and al, 11111100b
	out 61h, al
	
	lea dx, [errormsg]
	mov ah, 9
	int 21h
	
	call play
	
	ret
endp printerrormsg

;prints spaces over a message
proc wipe
	
	;change cursor position
	mov dl, 0
	mov dh, 3
	mov ah, 2
	xor bh, bh
	int 10h
	
	lea dx, [deletmsg]
	mov ah, 9
	int 21h
	
	mov dl, 0
	mov dh, 3
	mov ah, 2
	xor bh, bh
	int 10h
	
	ret 
endp wipe

;checks what octave the user is currently on and if the want to go up or down. according to that either calls a macro that changes octaves, or call a procedure that prints an error message
proc octchange
	
	mov cx, [currentoct]
	
	higho:
	cmp cx, [highoct]
	jne mid
	
	cmp [currentkey], 4bh
	je tomid
	
	call printoctmsg
	ret
	
	mid:
	cmp cx, [midoct]
	jne lowo
	
	cmp [currentkey], 4bh
	je tolow
	
	jmp tohigh
	
	lowo:
	
	cmp [currentkey], 4dh
	je tomid
	
	call printoctmsg
	ret
	
	tomid:
	changeoctave midoct
	ret
	
	tohigh:
	changeoctave highoct
	ret
	
	tolow:
	changeoctave lowoct
	ret
	
endp octchange

;prints a black tile on the screen
proc blacktiles
	
	xor bh, bh
	mov cx, [tilesp]
	mov dx, 50
	mov al, [tclr]
	mov ah, 0Ch
	
	mov [tstop], cx
	add [tstop], 20
	
	bwdth:
	
	push cx
	
	bhght:
	
	int 10h
	inc cx
	cmp cx, [tstop]
	jne bhght
	
	pop cx
	
	inc dx
	cmp dx, 130
	jne bwdth
	
	ret 
endp blacktiles
	
;calls pocedure that print the upper rectangle of a white tile and the low rectangle
proc rwtiles
	
	call mostwtiles
	
	mov [tstop], cx
	add [tstop], 38
	
	call lowrectangle
	
	ret
endp rwtiles
	
;prints upper rectangle of a white tile and calls a procedure that prints the lower rectangle
proc mwtiles
	
	xor bh, bh
	mov cx, [tilesp]
	mov dx, 50
	mov al, [tclr]
	mov ah, 0Ch
	mov [tstop], cx
	add [tstop], 18
	
	mwwdth:
	
	push cx
	
	mwhght:
	
	int 10h
	inc cx
	cmp cx, [tstop]
	jne mwhght
	
	pop cx
	inc dx
	cmp dx, 131
	jne mwwdth
	
	sub cx, 10
	add [tstop], 10
	
	call lowrectangle
	
	ret
endp mwtiles

;calls pocedure that print the upper rectangle of a white tile and the low rectangle
proc lwtiles
	
	call mostwtiles
	
	sub cx, 10
	
	call lowrectangle
	
	ret
endp lwtiles

;prints the upper part of a white tile with either a left prong or a right one
proc mostwtiles
	
	xor bh, bh
	mov cx, [tilesp]
	mov dx, 50
	mov al, [tclr]
	mov ah, 0ch
	mov [tstop], cx
	add [tstop], 28
	
	swwdth:
	
	push cx
	
	swhght:
	
	int 10h
	inc cx
	cmp cx, [tstop]
	jne swhght
	
	pop cx
	inc dx
	cmp dx, 131
	jne swwdth
	
	ret
endp mostwtiles

;prints on screen the lowest rectangle of a white tile	
proc lowrectangle
	
	lswdth:
	
	push cx
	
	lshght:
	
	int 10h
	inc cx
	cmp cx, [tstop]
	jne lshght
	
	pop cx
	inc dx
	cmp dx, 200
	jne lswdth
	
	ret
endp lowrectangle
	
;prints all tiles on the screen
proc begin
	
	mov [tclr], 37h
	
	mov [tilesp], 50
	call blacktiles
	mov [tilesp], 90
	call blacktiles
	mov [tilesp], 170
	call blacktiles
	mov [tilesp], 210
	call blacktiles
	mov [tilesp], 250
	call blacktiles
	
	mov [tclr], 40h
	
	mov [tilesp], 21
	call rwtiles
	mov [tilesp], 141
	call rwtiles
	mov [tilesp], 71
	call mwtiles
	mov [tilesp], 191
	call mwtiles
	mov [tilesp], 231
	call mwtiles
	mov [tilesp], 111
	call lwtiles
	mov [tilesp], 271
	call lwtiles
	
	ret
endp begin
	
;waits until the key pressed by the user is released
proc waitforup

	notyet:
	in al, 60h
	cmp al, [currentkey]
	je notyet
	
	ret
endp waitforup

;checks which note the user wants to play and calls a macro and a procedure that change the frequency and print the intended tile on the screen
proc compare
	
	lea bx, [currentoct]
	
	do:
	cmp [currentkey], 2dh
	jne re
	
	mov ax, [bx]
	notes 0d0h
	mov [tilesp], 21
	call rwtiles
	ret
	
	re:
	cmp [currentkey], 2eh
	jne mi
	
	mov ax, [bx + 4]
	notes 0d0h
	mov [tilesp], 71
	call mwtiles
	ret
	
	mi:
	cmp [currentkey], 2fh
	jne fa
	
	mov ax, [bx + 8]
	notes 0d0h
	mov [tilesp], 111
	call lwtiles
	ret
	
	fa:
	cmp [currentkey], 30h
	jne so 
	
	mov ax, [bx + 10]
	notes 0d0h
	mov [tilesp], 141
	call rwtiles
	ret
	
	so:
	cmp [currentkey], 31h
	jne la
	
	mov ax, [bx + 14]
	notes 0d0h
	mov [tilesp], 191
	call mwtiles
	ret
	
	la:
	cmp [currentkey], 32h
	jne ti 
	
	mov ax, [bx + 18]
	notes 0d0h
	mov [tilesp], 231
	call mwtiles
	ret
	
	ti:
	cmp [currentkey], 33h
	jne doshrp
	
	mov ax, [bx + 22]
	notes 0d0h
	mov [tilesp], 271
	call lwtiles
	ret
	
	doshrp:
	cmp [currentkey], 20h
	jne resharp
	
	mov ax, [bx + 2]
	notes 0c7h
	mov [tilesp], 50
	call blacktiles	
	ret
	
	resharp:
	cmp [currentkey], 21h
	jne fasharp
	
	mov ax, [bx + 6]
	notes 0c7h
	mov [tilesp], 90
	call blacktiles
	ret
	
	fasharp:
	cmp [currentkey], 23h
	jne sosharp
	
	mov ax, [bx + 12]
	notes 0c7h
	mov [tilesp], 170
	call blacktiles
	ret
	
	sosharp:
	cmp [currentkey], 24h
	jne lasharp
	
	mov ax, [bx + 16]
	notes 0c7h
	mov [tilesp], 210
	call blacktiles
	ret
	
	lasharp:
	cmp [currentkey], 25h
	jne wrong
	
	mov ax, [bx + 20]
	notes 0c7h
	mov [tilesp], 250
	call blacktiles
	ret
	
	wrong: 
	call printerrormsg
	
	ret
endp compare

proc play
	
	;reads one character from user
	mov ax, 0c07h
	int 21h
	
	call wipe
	
	;check if user wants to exit program
	cmp al, 1bh 
	je endgame
	
	in al, 60h
	mov [currentkey], al
	
	;check if user wants to change octave
	cmp [currentkey], 4bh 
	je skip
	cmp [currentkey], 4dh
	je skip
	
	;get access to change frequency
	in al, 61h
	or al, 00000011b
	out 61h, al
	
	call compare
	
	;turn speaker on
	in al, 61h
	or al, 00000011b
	out 61h, al
	
	call waitforup
	
	;turn speaker off
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	call begin
	jmp play
	
	;for if the user wants to change octave. call octave changing procedure
	skip:
	
	call octchange
	
	jmp play
endp play

start:
	
	mov ax, @data
	mov ds, ax
	
	;change to draphic mode
	mov ax, 13h
	int 10h
	
	;write instructions message
	lea dx, [instructmsg]
	mov ah, 9
	int 21h
	
	;change cursor position
	mov dl, 0
	mov dh, 5
	mov ah, 2
	xor bh, bh
	int 10h
	
	;write keyboard key ubove each piano key
	lea dx, [keysmsg]
	mov ah, 9
	int 21h
	
	;print initial keyboard
	call begin
	
	piano:
	
	call play
	
	jmp piano
	
	endgame:
	;exit graphic mode
	xor ah, ah
	mov al, 2
	int 10h
exit:
	mov ax, 4c00h
	int 21h
END start