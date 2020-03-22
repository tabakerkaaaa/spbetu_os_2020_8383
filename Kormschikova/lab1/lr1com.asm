TESTPC SEGMENT
           ASSUME  CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
           ORG     100H
START:     JMP     BEGIN

;DATA
 
	pcff db 'PC	', 0DH, 0AH, '$' 
	pcxt db 'PC/XT	', 0DH, 0AH, '$'
	atfc db 'AT ', 0DH, 0AH, '$'
	ps30 db 'PS2 m 30 ' , 0DH, 0AH, '$'
	ps50 db 'PS2 m 50/60 ', 0DH, 0AH, '$'
	ps80 db 'PS2 m 80 ', 0DH, 0AH, '$'
	pcjr db 'PCjr ', 0DH, 0AH, '$'
	pccm db 'PC COnvertible ', 0DH, 0AH, '$'
	unkt db 'Unknown type --' , 0DH, 0AH, '$'
	ver db 'MS DOS 00.00', 0DH, 0AH, '$'
	oem db 'Serial number OEM:    ', 0DH, 0AH, '$'
	usn db 'User serial number:      ', 0DH, 0AH, '$'

 ;-----------------------------------------------------
 TETR_TO_HEX   PROC  near
            and      AL,0Fh
            cmp      AL,09
            jbe      NEXT
            add      AL,07
 NEXT:      add      AL,30h
            ret
 TETR_TO_HEX   ENDP
 
 ;-------------------------------
 BYTE_TO_HEX   PROC  near
 ; байт в AL переводится в два символа в шестн. числа в AX
            push     CX
            mov      AH,AL
            call     TETR_TO_HEX
            xchg     AL,AH
            mov      CL,4
            shr      AL,CL
            call     TETR_TO_HEX ;в AL старшая цифра
            pop      CX          ;в AH младшая
            ret
 BYTE_TO_HEX  ENDP
 ;-------------------------------
 
 WRD_TO_HEX PROC near
 ;перевод в 16 с/с 16-ти разрядного числа
 ; в AX - число, DI - адрес последнего символа
 	push BX
	mov BH,AH
 	call BYTE_TO_HEX 
 	mov [DI],AH 
	dec DI
 	mov [DI],AL 
	dec DI
 	mov AL,BH
	call BYTE_TO_HEX 
	mov [DI],AH 
	dec DI
 	mov [DI],AL 
	pop BX
 	ret
 WRD_TO_HEX ENDP ;--------------------------------------------------
 
 
BYTE_TO_DEC   PROC  near
; перевод в 10 с/c, SI - адрес поля младшей цифры
           push     CX
           push     DX
           xor      AH,AH
           xor      DX,DX
           mov      CX,10
loop_bd:   div      CX
           or       DL,30h
           mov      [SI],DL
           dec      SI
           xor      DX,DX
           cmp      AX,10
           jae      loop_bd
           cmp      AL,00h
           je       end_l
           or       AL,30h
           mov      [SI],AL
end_l:     pop      DX
           pop      CX
           ret
BYTE_TO_DEC    ENDP


BEGIN:

;type

	mov ax,0F000h
	mov es, ax
	mov ax, es:[0FFFEh]

	cmp al, 0FFh
	je PC

	cmp al, 0FEh
	je XT

	cmp al, 0FBh
	je XT

	cmp al, 0FCh
	je AT

	cmp al, 0FAh
	je PS230

	cmp al, 0FCh
	je PS250

	cmp al, 0F8h
	je PS280

	cmp al, 0FDh 
	je PCJ

	cmp al, 0F9h
	je PCC

;UNKNOWN TYPE

	call BYTE_TO_HEX
	mov bx, offset unkt
	mov [bx+14], al
	mov [bx+15], ah
	mov dx, bx
	jmp res


PC:
	mov dx, offset pcff
	jmp res

XT:
	mov dx, offset pcxt
	jmp res

AT:
	mov dx, offset atfc
	jmp res

PS230:
	mov dx, offset ps30
	jmp res

PS250:
	mov dx, offset ps50
	jmp res

PS280:
	mov dx, offset ps80
	jmp res

PCJ:
	mov dx, offset pcjr
	jmp res

PCC:
	mov dx, offset pccm

RES:
	mov ah, 09h
	int 21h

;os ver
	mov ah, 30h
	int 21h
	
	push ax
	mov si, offset ver
	add si, 8
	call BYTE_TO_DEC
	pop ax
	mov al, ah
	add si, 3
	call BYTE_TO_DEC
	mov dx, offset ver
	mov ah, 09h
	int 21h
	
	mov si, offset oem
	add si, 19
	mov al, bh
	call BYTE_TO_DEC
	mov dx, offset oem
	mov ah, 09h
	int 21h

	mov di, offset usn
	add di, 25
	mov ax, cx
	call WRD_TO_HEX
	mov al, bl
	call BYTE_TO_HEX
	sub di, 2
	mov [di], ax
	mov dx, offset usn
	mov ah, 09h
	int 21h
	
;exit to dos

	xor AL,AL
	mov AH,4Ch
	int 21H
	
TESTPC     ENDS
END START