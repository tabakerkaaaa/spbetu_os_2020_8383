LAB1	SEGMENT
		ASSUME  CS:LAB1, DS:LAB1, ES:NOTHING, SS:NOTHING
		ORG 100H
START: JMP BEGIN
;DATA
OS_VERSION_NUMBER db 13, 10, "OS version is $"
DOT db ".$"
OEM db 13, 10, "OEM is $"
SERIAL db 13, 10, "Serial number is $"
TYPE_PC_STR db 13, 10, "PC type is $"
TYPE_PC db "PC$"
TYPE_PC_XT db "PC/XT$"
TYPE_AT db "AT$"
TYPE_PS2_M30 db "PS2 model 30$"
TYPE_PS2_M5060 db "PS2 model 50 or 60$"
TYPE_PS2M80 db "PS2 model 80$"
TYPE_PC_JR db "PCjr$"
TYPE_PC_CONV db "PC Convertible$"
TYPE_UNKNOWN db "unknown $"
;PROCEDURES
;______________________________________________________________
OS_VER_PROC PROC
	push DX
	push AX
	mov AH, 30h ;GETTING INFO
	int 21h
	
	mov DX, offset OS_VERSION_NUMBER
	call WRITE
	call WRITE_OS_VERSION
	mov DX, offset OEM
	call WRITE
	mov DX, offset OEM
	mov AL, BH
	mov AH, 0
	call WRITE_DEC
	mov DX, offset SERIAL
	call WRITE
	call WRITE_SERIAL
	
	pop AX
	pop DX
	ret
OS_VER_PROC ENDP
;______________________________________________________________
PC_TYPE_PROC PROC
	push AX
	push ES
	push DX
	
	mov AX, 0F000h
	mov ES, AX
	mov AL, ES:[0FFFEh]
	cmp AL, 0FFh
	je PC
	cmp AL, 0FEh
	je XT
	cmp AL, 0FBh
	je XT
	cmp AL, 0FCh
	je PCAT
	cmp AL, 0FAh
	je PS30
	cmp AL, 0FCh;ОПЕЧАТКА В МЕТОДЕ
	je PS50
	cmp AL, 0F8h
	je PS80
	cmp AL, 0FDh
	je JR
	cmp AL, 0F9h
	je CONV
	;DEFOULT
	mov DX, offset TYPE_UNKNOWN
	call WRITE
	call WRITE_HEX_BYTE
	jmp FINISH
PC:
	mov DX, offset TYPE_PC
	jmp RES
XT:
	mov DX, offset TYPE_PC_XT
	jmp RES
PCAT:
	mov DX, offset TYPE_AT
	jmp RES
PS30:
	mov DX, offset TYPE_PS2_M30
	jmp RES
PS50:
	mov DX, offset TYPE_PS2_M5060
	jmp RES
PS80:
	mov DX, offset TYPE_PS2M80
	jmp RES
JR:
	mov DX, offset TYPE_PC_JR
	jmp RES
CONV:
	mov DX, offset TYPE_PC_CONV
	jmp RES
RES:
	call WRITE

FINISH:
	pop DX
	pop ES
	pop AX
	ret
PC_TYPE_PROC ENDP
;______________________________________________________________
WRITE PROC
	push AX
	mov AH, 9h
	int 21h
	pop AX
	ret
WRITE ENDP
;______________________________________________________________
WRITE_OS_VERSION PROC
	push BX
	push DX
	push AX
	
	mov BL, 10
	;VER
	call WRITE_DEC_BYTE
	;DOT
	mov DX, offset DOT
	call WRITE
	;MOD
	mov AL, AH
	call WRITE_DEC_BYTE

	pop AX
	pop DX
	pop BX
	ret
WRITE_OS_VERSION ENDP
;______________________________________________________________
WRITE_DEC PROC
	push AX
	push CX
	push DX
	push BX
	
	mov BX, 10
	xor CX, CX
GETTING_NUMS:
	xor DX, DX
	div BX
	push DX
	inc CX
	test AX, AX
	jnz GETTING_NUMS
	mov AH, 02h
WRITING:
	pop DX
	add DL, '0'
	int 21h
	loop WRITING
	
	pop BX
	pop DX
	pop CX
	pop AX
	ret
WRITE_DEC ENDP
;______________________________________________________________
WRITE_SERIAL PROC
	push AX
	push BX
	push CX
	push DX
	
	;first byte
	mov AL, BL
	call WRITE_HEX_BYTE
	;second byte
	mov AL, CH
	call WRITE_HEX_BYTE
	;third byte
	mov AL, CL
	call WRITE_HEX_BYTE
	
	pop DX
	pop CX
	pop BX
	pop AX
	ret
WRITE_SERIAL ENDP
;______________________________________________________________
WRITE_HEX_BYTE PROC
	push AX
	push BX
	push DX
	
	mov AH, 0
	mov BL, 16
	div BL
	mov DX, AX
	mov AH, 02h
	add DL, '0'
	int 21h;
	mov DL, DH
	add DL, '0'
	int 21h;
	
	pop DX
	pop BX
	pop AX
	ret
WRITE_HEX_BYTE ENDP
;______________________________________________________________
WRITE_DEC_BYTE PROC
	push AX
	mov AH, 0
	div BL
	mov DX, AX
	mov AH, 02h
	add DL, '0'
	int 21h
	mov DL, DH
	add DL, '0'
	int 21h
	pop AX
	ret
WRITE_DEC_BYTE ENDP
;______________________________________________________________

BEGIN:
	call PC_TYPE_PROC
	call OS_VER_PROC
	
	;TO DOS
	xor AL, AL
	mov AH, 4Ch
	int 21h
LAB1 ENDS
END START