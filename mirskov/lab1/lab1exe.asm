SSTACK SEGMENT STACK
		   DW 128 dup(0)
SSTACK  ENDS


DATA SEGMENT
	TYPE_PC db 'Type: PC',0DH,0AH,'$'
	TYPE_PC_XT db 'Type: PC/XT',0DH,0AH,'$'
	TYPE_AT db  'Type: AT',0DH,0AH,'$'
	TYPE_PS2_30 db 'Type: PS2 model 30',0DH,0AH,'$'
	TYPE_PS2_80 db 'Type: PS2 model 80',0DH,0AH,'$'
	TYPE_PC_JR db 'Type: PCjr',0DH,0AH,'$'
	TYPE_PC_C db 'Type: PC Convertible',0DH,0AH,'$'
	TYPE_UNKNOWN db 'Unknown type: ',0DH,0AH,'$'

	OS_VERSION db 'MS-DOS version: 00.00  ',0DH,0AH,'$'
	NUMBER_OEM db 'Serial number OEM:   ',0DH,0AH,'$'
	NUMBER_USER db 'User serial number:         ',0DH,0AH,'$'
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA, SS:SSTACK
;-----------------------------------------------------
WRITE_TYPE   PROC   near
		    mov ax, 0f000h
			mov es, ax
			mov al, es:[0fffeh]

			cmp al, 0ffh
			je write_pc
			cmp al, 0feh
			je write_pc_xt
			cmp al, 0fbh
			je write_pc_xt
			cmp al, 0fch
			je write_at
			cmp al, 0fah
			je write_ps2_30
			cmp al, 0f8h
			je write_ps2_80
			cmp al, 0fdh
			je write_pc_jr
			cmp al, 0f9h
			je write_pc_c
			;else
				call BYTE_TO_HEX
				mov bx, offset TYPE_UNKNOWN
				mov [bx+14], AL
				mov [bx+15], AH
				mov dx, bx
				mov AH,09h
   				int 21h
				ret

			write_pc:
				mov dx, offset TYPE_PC
				jmp write
			write_pc_xt:
				mov dx, offset TYPE_PC_XT
				jmp write
			write_at:
				mov dx, offset TYPE_AT
				jmp write
			write_ps2_30:
				mov dx, offset TYPE_PS2_30
				jmp write
			write_ps2_80:
				mov dx, offset TYPE_PS2_80
				jmp write
			write_pc_jr:
				mov dx, offset TYPE_PC_JR
				jmp write
			write_pc_c:
				mov dx, offset TYPE_PC_C
				jmp write

			write:
				mov AH,09h
   				int 21h
	ret
WRITE_TYPE ENDP
;-----------------------------------------------------
WRITE_OS_VERSION PROC near
			mov ah, 30h
			int 21h
			push ax

			mov si, offset OS_VERSION
			add si, 17
			call BYTE_TO_DEC
		    pop ax
		    mov al, ah
		    add si, 3
			call BYTE_TO_DEC
			mov dx, offset OS_VERSION
			mov ah, 09h
			int 21h

			mov si, offset NUMBER_OEM
			add si, 19
			mov al, bh
			call BYTE_TO_DEC
			mov dx, offset NUMBER_OEM
			mov ah, 09h
			int 21h

			mov di, offset NUMBER_USER
			add di, 25
			mov ax, cx
			call WRD_TO_HEX
			mov al, bl
			call BYTE_TO_HEX
			sub di, 2
			mov [di], ax
			mov dx, offset NUMBER_USER
			mov ah, 09h
			int 21h

			ret
WRITE_OS_VERSION ENDP
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
WRD_TO_HEX   PROC  near
;перевод в 16 с/c 16-ти разрядного числа
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
;-------------------------------

; код

MAIN PROC FAR
			sub   AX,AX
		    push  AX
		    mov   AX,DATA
		    mov   DS,AX

			call WRITE_TYPE
			call WRITE_OS_VERSION

			; вход в DOS
            xor     AL,AL
            mov     AH,4Ch
            int     21H
MAIN      ENDP
CODE ENDS
END MAIN