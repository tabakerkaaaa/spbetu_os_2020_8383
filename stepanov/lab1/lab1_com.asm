LAB1	SEGMENT
 		ASSUME  CS:LAB1, DS:LAB1, ES:NOTHING, SS:NOTHING
 		ORG 100H
 START: JMP BEGIN

;------------------------------------------------
TYPE_OF_PC db "Type of PC: $"
PC db "PC$"
PC_XT db "PC/XT$"
AT db "AT$"
PS2_30 db "PS2 model 30$"
PS2_50 db "PS2 model 50 or 60$"
PS2_80 db "PS2 model 80$"
PCjr db "PCjr$"
PC_Con db "PC convertable$"
UNKNOWN_TYPE db " Unknown$"
OUT_UNKNOWN db "   $"
VER_NUM db 13, 10, "Version number: $"

OUT_VER_NUM db "  .  $"

OEM_NUM db 13, 10, "OEM: $"
OUT_OEM db "      $"
SER_NUM db 13, 10, "Serial number: $"
OUT_SER_NUM DB "            $"
;------------------------------------------------

TYPE_PC PROC near
 	
	push ax
	push dx
	
	mov dx, offset TYPE_OF_PC
	call PRINT
	
	mov ax, 0F000h
	mov es, ax 
	mov al, es:[0FFFEH]
	
	mov al, 7h
	
	cmp al, 0FFh
		je W_PC
	cmp al, 0FEh
		je W_PC_XT
	cmp al, 0FBh
		je W_PC_XT
	cmp al, 0FCh
		je W_AT
	cmp al, 0FAh
		je W_PS2_30
	cmp al, 0FCh
		je W_PS2_50
	cmp al, 0F8h
		je W_PS2_80
	cmp al, 0FDh
		je W_PCjr
	cmp al, 0F9h
		je W_PC_Con
	
	mov di, offset OUT_UNKNOWN
	call BYTE_TO_HEX
	mov [di], ax
	mov dx, offset OUT_UNKNOWN
	CALL PRINT

	mov DX, offset UNKNOWN_TYPE
	jmp ESC_PROC
		
		
	W_PC:
		mov DX, offset PC
		jmp ESC_PROC
	
	W_PC_XT:
		mov DX, offset PC_XT
		jmp ESC_PROC

	W_AT:
		mov DX, offset AT
		jmp ESC_PROC
	
	W_PS2_30:
		mov DX, offset PS2_30
		jmp ESC_PROC

	W_PS2_50:
		mov DX, offset PS2_50
		jmp ESC_PROC	
	
	W_PS2_80:		
		mov DX, offset PS2_80
		jmp ESC_PROC
	
	W_PCjr:
		mov DX, offset PCjr
		jmp ESC_PROC

	W_PC_Con:
		mov DX, offset PC_Con
		
	ESC_PROC:		
		call PRINT
	
	pop dx
	pop ax
 
	ret
TYPE_PC ENDP
 
;------------------------------------------------

PRINT PROC near

	push ax
	sub ax, ax
	mov ah, 9h
	int 21h
	pop ax

	ret
PRINT ENDP

;------------------------------------------------

WRD_TO_HEX   PROC  near
            push     BX
            mov      BH,AH
            call     BYTE_TO_HEX
            mov      [DI],AH
            dec      DI
            mov      [DI],AL
            dec      DI
            mov      AL,BH
            call     BYTE_TO_HEX
            mov      [DI],AH
            dec      DI
            mov      [DI],AL
            pop      BX
            ret
 WRD_TO_HEX ENDP

;------------------------------------------------

TETR_TO_HEX   PROC  near
            and      AL,0Fh
            cmp      AL,09
            jbe      NEXT
            add      AL,07
 NEXT:      add      AL,30h
            ret
 TETR_TO_HEX   ENDP
 
 ;------------------------------------------------

BYTE_TO_HEX   PROC  near
            push     CX
            mov      AH,AL
            call     TETR_TO_HEX
            xchg     AL,AH
            mov      CL,4
            shr      AL,CL
            call     TETR_TO_HEX ;â AL ñòàðøàÿ öèôðà
            pop      CX          ;â AH ìëàäøàÿ
            ret
 BYTE_TO_HEX  ENDP
 
 ;------------------------------------------------

BYTE_TO_DEC   PROC  near
            push     CX
            push     DX
            xor      AH,AH
            xor      DX,DX
            mov      CX,10
 loop_bd:   div      CX
            or       DL,30h
            mov      [SI],DL
 		   dec		si
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
 
 ;------------------------------------------------

SYSTEM_VERSION PROC

	push ax
	push bx
	push cx
	push dx
	
	sub ax, ax
	mov ah, 30h
	int 21h
		
	mov dx, offset VER_NUM
	call PRINT
			
	push ax
	mov si, offset OUT_VER_NUM
	inc si
	call BYTE_TO_DEC
	pop ax
	mov al, ah
	add si, 3
	call BYTE_TO_DEC
	
	mov dx, offset OUT_VER_NUM 
	call print
	
	mov DX, offset OEM_NUM
	call PRINT
	
	mov si, offset OUT_OEM
	add si, 2
	mov al, bh                    
	call BYTE_TO_DEC
	mov dx, OFFSET OUT_OEM
	call PRINT
	
	
	mov dx, offset SER_NUM
	call PRINT
	
	mov di, offset OUT_SER_NUM
	add di, 6
	mov ax, cx
	
	call WRD_TO_HEX
	mov al, bl
	call BYTE_TO_HEX
	sub di, 2
	mov [di], ax
	mov dx, offset OUT_SER_NUM
	CALL PRINT

	pop DX
	pop CX
	pop BX
	pop AX
	ret
SYSTEM_VERSION ENDP

;-------------------------------------------

PRINT_NUMBER_DEC PROC
	push AX
	push BX
	
	sub BX, BX
	mov Bl, 10
	mov AH, 0
	div Bl
	mov DX, AX		
	
	add DL, '0'
	sub AX, AX
	mov AH, 02h
	int 21h
	
	mov DL, DH
	
	add DL, '0'
	sub AX, AX
	mov AH, 02h
	int 21h
	
	pop BX
	pop AX
	ret
PRINT_NUMBER_DEC ENDP

;-------------------------------------------

 BEGIN:	 
	call TYPE_PC
	call SYSTEM_VERSION
	 
 	xor AX, AX
 	mov	AH, 4Ch
 	int 21h
	 
 LAB1 ENDS
 END START 