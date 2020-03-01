TESTPC SEGMENT
ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
ORG 100H
START: JMP BEGIN

	PC_TYPE db 13, 10, "PC type: $"
	TYPE_PC db "PC$"
	TYPE_PCXT db "PC/XT$"
	TYPE_AT db "AT$"
	TYPE_30 db "PS2 model 30$"
	TYPE_80 db "PS2 model 80$"
	TYPE_PCJR db "PCjr$"
	TYPE_5060 db "PS2 model 50 or 60$"
	TYPE_CONVERTIBLE db "PC Convertible$"
	TYPE_UNKNOWN db "Unknown $"
	UNKNOWN_STR db "   $"
	SYSTEM_VERSION db 13,10,"System version: $"
	IF_AL0 db "<2.0$"
	OEM_SN db 13, 10, "OEM serial number: $"
	STR_OEM db "      $"
	STR_USER db "            $"
	SYSVER_STR db " . $"
	USER_SN db 13, 10, "User serial number: $"

;-----------------------------------------------------
TETR_TO_HEX PROC near
	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT: add AL,30h
	ret
TETR_TO_HEX ENDP
;-------------------------------
BYTE_TO_HEX PROC near
; байт в AL переводится в два символа шестн. числа в AX
	push CX
	mov AH,AL
	call TETR_TO_HEX
	xchg AL,AH
	mov CL,4
	shr AL,CL
	call TETR_TO_HEX ; в AL старшая цифра
	pop CX ;в AH - младшая
	ret
BYTE_TO_HEX ENDP
;-------------------------------
WRD_TO_HEX PROC near
;перевод в 16 с.с. 16-ти разрядного числа
; в AX - число, в DI - адрес последнего символа
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
WRD_TO_HEX ENDP
;--------------------------------------------------
BYTE_TO_DEC PROC near
; перевод в 10 с.с., SI - адрес поля младшей цифры
	push CX
	push DX
	xor AH,AH
	xor DX,DX
	mov CX,10
loop_bd: div CX
	or DL,30h
	mov [SI],DL
	dec SI
	xor DX,DX
	cmp AX,10
	jae loop_bd
	cmp AL,00h
	je end_l
	or AL,30h
	mov [SI],AL
end_l: pop DX
	pop CX
	ret
BYTE_TO_DEC ENDP
;-----------------------------------------------
PRINT PROC near
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
PRINT ENDP
;-----------------------------------------------
OS_VERSION_DETECTION PROC near
	push ax
	push dx
	mov ah, 30h
	int 21h
	push ax
	mov dx, offset SYSTEM_VERSION
	call PRINT
	cmp al, 0
	je ifal0
	mov si, offset SYSVER_STR
	call BYTE_TO_DEC
	pop ax
	mov al, ah
	add si, 3
	call BYTE_TO_DEC
	mov dx, offset SYSVER_STR
	exit_from_al0:
		call PRINT
	
	mov dx, offset OEM_SN
	call PRINT
	mov si, offset STR_OEM
	add si, 2   ;т.к. OEM может состоять макс. из 2 цифр в 16 с.с.
	mov al, bh
	call BYTE_TO_DEC
	mov dx, offset STR_OEM
	call PRINT

	mov dx, offset USER_SN
	call PRINT
	mov di, offset STR_USER  ;т.к. WRD_TO_HEX принимает di
	add di, 6
	mov ax, cx
	call WRD_TO_HEX
	mov al, bl
	call BYTE_TO_HEX
	sub di, 2
	mov [di], ax
	mov dx, offset STR_USER
	call PRINT
	jmp exit_from_osdetection
	

	ifal0:
		mov dx, offset IF_AL0 
		jmp exit_from_al0

	exit_from_osdetection:
		pop dx
		pop ax
	ret
OS_VERSION_DETECTION ENDP
;----------------------------------------------
PC_TYPE_DETECTION PROC near
	push ax
	push dx
	mov ax, 0F000h
	mov es, ax
	mov al, es:[0FFFEH]
	mov dx, offset PC_TYPE
	call PRINT

	;Определение типа
	cmp al, 0FFh ;PC
	je pc_model
	cmp al, 0FEh ;PC/XT
	je xt_model
	cmp al, 0FBh ;PC/XT
	je xt_model
	cmp al, 0FCh ;AT
	je at_model
	cmp al, 0FAh ;PS2 30
	je ps2_model_30
	cmp al, 0FCh ;PS2 50 or 60
	je ps2_model_5060
	cmp al, 0F8h ;PS2 80
	je ps2_model_80
	cmp al, 0FDh ;PCjr
	je pcjr_model
	cmp al, 0F9h ;PC Convertible
	je pc_convertible
	
	;Если неизвестный тип
	mov di, offset UNKNOWN_STR
	call BYTE_TO_HEX
	mov [di], ax
	mov dx, offset UNKNOWN_STR
	call PRINT
	mov dx, offset TYPE_UNKNOWN 
	jmp end_of_detection

	pc_model:
		mov dx, offset TYPE_PC
		jmp end_of_detection
	xt_model:
		mov dx, offset TYPE_PCXT
		jmp end_of_detection
	at_model:
		mov dx, offset TYPE_AT
		jmp end_of_detection
	ps2_model_30:
		mov dx, offset TYPE_30
		jmp end_of_detection
	ps2_model_5060:
		mov dx, offset TYPE_5060
		jmp end_of_detection
	ps2_model_80:
		mov dx, offset TYPE_80
		jmp end_of_detection
	pcjr_model:
		mov dx, offset TYPE_PCJR
		jmp end_of_detection
	pc_convertible:
		mov dx, offset TYPE_CONVERTIBLE 	
	
	end_of_detection:
		call PRINT
	pop dx
	pop ax
	ret
	
PC_TYPE_DETECTION ENDP
;----------------------------------------------

BEGIN:

	call OS_VERSION_DETECTION
	call PC_TYPE_DETECTION

	xor AL, AL
	mov AH, 4Ch
	int 21h
TESTPC ENDS
	END START