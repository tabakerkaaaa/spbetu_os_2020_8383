TESTPC     SEGMENT
           ASSUME  CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
		   ORG 100H    ;обязательно!!
START:     JMP     BEGIN
; ДАННЫЕ
	SYSTEM_VER db 13,10,"OS version: $"
	OUT_VER db "  .  $" 
	OEM_NUMBER db 13, 10, "Number OEM: $"
	OUT_OEM db "      $"	
	USER_NUMBER db 13, 10, "Serial number: $"
	OUT_UNUM db "            $"
	PC_VER db 13, 10, "Version PC: $"
	MODEL_PC db "PC$"
	MODEL_PCXT db "PC/XT$"
	MODEL_AT db "AT$"
	MODEL_30 db "PS2 model 30$"
	MODEL_80 db "PS2 model 80$"
	MODEL_JR db "PCjr$"
	MODEL_5060 db "PS2 model 50/60$"
	MODEL_CONVERT db "PC Convertible$"
	WARNING_VER db "Not found          $"

;ПРОЦЕДУРЫ
;-------------------------------

WRITE_STR PROC near
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
WRITE_STR ENDP
;-------------------------------
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
; байт в AL переводится в два символа шестн. числа в AX
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
WRD_TO_HEX   PROC  near
;перевод в 16 с/с 16-ти разрядного числа
; в AX - число, DI - адрес последнего символа
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
;--------------------------------------------------
BYTE_TO_DEC   PROC  near
; перевод в 10с/с, SI - адрес поля младшей цифры
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
;-----------------------------------------------------------------------


PRINT_PCTYPE PROC near

    push ax
	push bx
    MOV AX,0F000H ; указывает ES на ПЗУ
    MOV ES,AX ;
    MOV AL,ES:[0FFFEH] ;получаем байт
	mov dx, offset PC_VER
	call WRITE_STR
	cmp al, 0FFH  ; PC
	JE mod_pc
	cmp al, 0FEH  ; PC/XT
	JE mod_xt
	cmp al, 0FBH  ; PC/XT
	JE mod_xt
	cmp al, 0FCH
	JE is_at_5060
	cmp al, 0FAH  ; PC2 30
	JE mod_30
	cmp al, 0F8H  ; PC2 80
	JE mod_80
	cmp al, 0FDH  ; PCjr
	JE mod_jr
	cmp al, 0F9H  ; PC Convertible
	JE mod_conv
	
	error_type:
	    mov si, offset WARNING_VER
		add si, 16
		call BYTE_TO_HEX
		mov dx, offset WARNING_VER
		jmp end_
	mod_pc:
		mov dx, offset MODEL_PC
		jmp end_
	mod_xt:
		mov dx, offset MODEL_PCXT
		jmp end_
	mod_at:
		mov dx, offset MODEL_AT
		jmp end_
	mod_30:
		mov dx, offset MODEL_30
		jmp end_
	mod_5060:
		mov dx, offset MODEL_5060
		jmp end_
	mod_80:
		mov dx, offset MODEL_80
		jmp end_
	mod_jr:
		mov dx, offset MODEL_JR
		jmp end_
	mod_conv:
		mov dx, offset MODEL_CONVERT
		jmp end_

	is_at_5060:	                          ; At - 00
       	mov ah, 192						  ;50/60 - 04
		int 15H
		mov al, ES:[BX+3]
		cmp al, 00h
		je mod_at                  ; =
		jmp mod_5060
	end_:
		call WRITE_STR
	pop bx 
	pop ax 
	ret
PRINT_PCTYPE ENDP


PRINT_OS PROC near 
	push dx
	mov ah, 30h
	int 21h
	push ax
	mov dx, offset SYSTEM_VER
	call WRITE_STR
	mov si, offset OUT_VER
	inc si
	call BYTE_TO_DEC
	pop ax
    mov al, ah                  ;делает над ah	
    add si, 3
	call BYTE_TO_DEC
	mov dx, offset OUT_VER	
	call WRITE_STR
	mov dx, offset OEM_NUMBER
	call WRITE_STR
	mov si, offset OUT_OEM
	add si, 5
	mov al, bh                    ;хранится оем
	call BYTE_TO_DEC
	mov dx, offset OUT_OEM
	call WRITE_STR
	mov dx, offset USER_NUMBER
    call WRITE_STR
    mov di, offset OUT_UNUM
	add di, 10
	mov ax, cx
	call WRD_TO_HEX
	mov al, bl
	call BYTE_TO_HEX
	sub di, 2
	mov [di], ax
	mov dx, offset OUT_UNUM
	call WRITE_STR	
	pop dx 
	ret
PRINT_OS ENDP
;-------------------------------





; КОД
BEGIN:
        call PRINT_PCTYPE
		call PRINT_OS
        xor  AL,AL
        mov AH,4Ch
        int  21H    ; в com cs уже на psp
       ; int 20h		
		
TESTPC    ENDS
END       START     ;конец модуля, START - точка входа
