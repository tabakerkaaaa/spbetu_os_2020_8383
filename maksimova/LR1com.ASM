COMMENT *
Максимова Анастасия, группа 8383
*

TESTPC	SEGMENT
		ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
		ORG 100H

START:	JMP		BEGIN

;ДАННЫЕ
TYPE1				DB		'PC', 0DH, 0AH, '$'
TYPE2				DB		'PC/XT', 0DH, 0AH, '$'		
TYPE3				DB		'AT', 0DH, 0AH, '$'			;type5 = type3
TYPE4				DB		'PS2 model 30', 0DH, 0AH, '$'
TYPE6				DB		'PS2 model 80', 0DH, 0AH, '$'
TYPE7				DB		'PCjr', 0DH, 0AH, '$'
TYPE8				DB		'PC Convertible', 0DH, 0AH, '$'
STRING				DB		'Register value AX = ', '$'
VAR0_STR1			DB		'indefined.', 0DH, 0AH, '$'
VAR0_STR2			DB		'Penultimate byte:		', 0DH, 0AH, '$'
SYSTEM_VERSION		DB		'System version:   .  ', 0DH, 0AH, '$'
SERIAL_NUMB_OEM 	DB		'Serial number OEM:     ', 0DH, 0AH, '$'
SERIAL_NUMB_USER	DB		'Serial number user:          ', 0DH, 0AH, '$'

;ПРОЦЕДУРЫ
;-----------------------------------------------------------
TETR_TO_HEX		PROC	NEAR
		   and    AL, 0Fh
		   cmp    AL, 09
		   jbe    NEXT	
		   add    AL, 07
NEXT:	   add	  AL, 30h
		   ret
TETR_TO_HEX    ENDP		   
;-----------------------------------------------------------
BYTE_TO_HEX		PROC	NEAR
;байт в AL переводится в два символа шестн. числа в AX
				push    CX
				mov     AH, AL
				call    TETR_TO_HEX
				xchg    AL, AH
				mov     CL, 4
				shr     AL, CL
				call    TETR_TO_HEX	;в AL - старшая цифра
				pop     CX			;в AH - младшая
				ret
BYTE_TO_HEX		ENDP
;-----------------------------------------------------------
WRD_TO_HEX		PROC	NEAR
;перевод в 16 с/с 16-ти разрядного числа
;в АХ - число, DI - адрес последнего символа
				push	BX
				mov		BH, AH
				call	BYTE_TO_HEX
				mov		[DI], AH
				dec		DI
				mov		[DI], AL
				dec		DI
				mov		AL, BH
				call	BYTE_TO_HEX
				mov		[DI], AH
				dec		DI
				mov		[DI], AL
				pop		BX
				ret
WRD_TO_HEX		ENDP
;-----------------------------------------------------------
BYTE_TO_DEC		PROC	NEAR
;перевод в 10 с/с, SI - адрес поля младшей цифры
				push	CX
				push	DX
				xor		AH, AH
				xor		DX, DX
				mov		CX, 10
loop_bd:		div		CX
				or		DL, 30h
				mov		[SI], DL
				dec		SI
				xor		DX, DX
				cmp		AX, 10
				jae		loop_bd
				cmp		AL, 00h
				je		end_l
				or		AL, 30h
				mov		[SI], AL
end_l:			pop 	DX
				pop		CX
				ret
BYTE_TO_DEC		ENDP
;-----------------------------------------------------------
PRINTF		PROC	NEAR
		mov		AH, 09h
	    int 	21h
		ret
PRINTF		ENDP
;-----------------------------------------------------------
TYPE_PC		PROC	NEAR
				mov		AX, 0F000h	
				mov		ES, AX
				mov 	AL,	ES:[0FFFEh]	
				jmp 	SEARCH_TYPE
SEARCH_TYPE:
				cmp 	AL, 0FFh
				jne		var2_1
				mov		DX, offset TYPE1
				call 	PRINTF
				jmp		exit
				
var2_1:			cmp 	AL, 0FEh		
				jne		var2_2
				mov		DX, offset TYPE2
				call 	PRINTF
				jmp		exit
				
var2_2:			cmp 	AL, 0FBh
				jne		var3
				mov		DX, offset TYPE2
				call 	PRINTF
				jmp		exit
				
var3:			cmp 	AL, 0FCh
				jne var4
				mov		DX, offset TYPE3
				call 	PRINTF
				jmp		exit
				
var4:			cmp 	AL, 0FAh
				jne		var6
				mov		DX, offset TYPE4
				call 	PRINTF
				jmp		exit
				
var6:			cmp 	AL, 0F8h
				jne		var7
				mov		DX, offset TYPE6
				call 	PRINTF
				jmp		exit
				
var7:			cmp 	AL, 0FDh
				jne		var8
				mov		DX, offset TYPE7
				call 	PRINTF
				jmp		exit
				
var8:			cmp 	AL, 0F9h
				jne		var0
				mov		DX, offset TYPE8
				call 	PRINTF
				jmp		exit
		
var0:

				mov		DX, offset VAR0_STR1
				call 	PRINTF
				mov 	DI,	offset VAR0_STR2
				add		DI, 21
				call 	WRD_TO_HEX
				mov		DX, offset VAR0_STR2
				call 	PRINTF
				
exit:
				ret
TYPE_PC		ENDP
;-----------------------------------------------------------
CORRECT			PROC	NEAR
				push 	BX
				mov 	BL, 16	;bl - делитель
				div		BL		;AH - остаток AL - целое
				add 	AH, '0'
				add 	AL, '0'
				pop 	BX
				ret
CORRECT			ENDP
;-----------------------------------------------------------
VERSION_SYSTEM	PROC	NEAR
				mov		AH, 30h
				int		21h
				
				push CX
				mov 	CX, AX 		;save
			
				;AL
				call 	CORRECT
				mov 	SI,	offset SYSTEM_VERSION
				add		SI, 17
				mov		[SI], AH
				
				dec		SI
				mov		[SI], AL
				
				;AH
				xor 	AX, AX
				mov 	AH, CH
				call 	CORRECT
				add		SI, 4
				mov		[SI], AH
				
				dec		SI
				mov		[SI], AL

				mov		DX, offset SYSTEM_VERSION
				call 	PRINTF
				
				;SERIAL_NUMB_OEM
				xor 	AX, AX
				mov 	AL, BH
				
				call 	CORRECT
				mov 	SI,	offset SERIAL_NUMB_OEM
				add		SI, 20
				mov		[SI], AH
				
				dec		SI
				mov		[SI], AL
				
				mov		DX, offset SERIAL_NUMB_OEM
				call 	PRINTF
				
				;SERIAL_NUMB_USER
				;BL
				pop 	CX
				xor 	AX, AX
				mov 	AL, BL
				
				call 	CORRECT
				mov 	SI,	offset SERIAL_NUMB_USER
				add		SI, 21
				mov		[SI], AH

				dec		SI
				mov		[SI], AL
				
				;CH
				xor 	AX, AX
				mov 	AL, CH
				
				call 	CORRECT
				add		SI, 3
				mov		[SI], AH
				
				dec		SI
				mov		[SI], AL
				
				;CL
				xor 	AX, AX
				mov 	AL, CL
				
				call 	CORRECT
				add		SI, 3
				mov		[SI], AH
				
				dec		SI
				mov		[SI], AL
				
				mov		DX, offset SERIAL_NUMB_USER
				call 	PRINTF
				
				
				ret
VERSION_SYSTEM	ENDP
;-----------------------------------------------------------
BEGIN:		
;вывод строки текста из поля STRING					
				mov		DX, offset STRING			
				mov		AH, 09h
				int 	21h
				
;выполнение заданий
				call TYPE_PC
				call VERSION_SYSTEM
				
;выход в DOS
				xor		AL, AL
				mov		AH, 4Ch
				int		21h
TESTPC	ENDS					
		END 	START			;конец модуля, START - точка входа