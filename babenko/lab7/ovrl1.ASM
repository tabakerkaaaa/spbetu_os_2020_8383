CODE      	SEGMENT      

		ASSUME CS:CODE, DS:NOTHING, SS:NOTHING

;главная процедура
MAIN		PROC	FAR           

		PUSH	AX
		PUSH	BX
		PUSH	DX
		PUSH	DI
		PUSH	DS

		MOV	DS, AX
		MOV	DI, OFFSET STR
		ADD	DI, 32H
		MOV	AX, CS
		CALL	WRDTOHEX
		MOV	DX, OFFSET STR 
		CALL	WRITE

		POP	DS
		POP	DI
		POP	DX
		POP	BX
		POP	AX
		RETF

MAIN		ENDP	

;процедура печати строки
WRITE  	PROC	NEAR

       	PUSH	AX
       	MOV	AH, 09H
          	INT	21H
		POP 	AX 
          	RET

WRITE  	ENDP

;процедура получения символа в 16 с/c
TETRTOHEX	PROC	NEAR

          	AND	AL, 0FH
          	CMP	AL, 09H
          	JBE	NEXT
      	ADD	AL, 07H

       	NEXT:      
       	ADD	AL, 30H
          	RET

TETRTOHEX	ENDP

;процедура перевода байта в AL в два символа 16 с/c в AX
BYTETOHEX	PROC	NEAR
          	
       	PUSH	CX
      	MOV	AH, AL
       	CALL	TETRTOHEX
          	XCHG	AL, AH
          	MOV	CL, 4H
          	SHR	AL, CL
       	CALL	TETRTOHEX
         	POP	CX
          	RET

BYTETOHEX	ENDP

;процедура записи 16-ти разрядного числа в 16 с/c в строку
WRDTOHEX	PROC	NEAR

          	PUSH	BX
          	MOV 	BH, AH
         	CALL	BYTETOHEX
          	MOV	[DI], AH
          	DEC	DI
          	MOV	[DI], AL
         	DEC	DI
          	MOV	AL, BH
          	CALL	BYTETOHEX
          	MOV	[DI], AH
          	DEC	DI
          	MOV	[DI], AL
          	POP	BX
          	RET

WRDTOHEX	ENDP

STR		DB "I am the first overlay. My segment address is:        ", 0DH, 0AH, "$"

CODE      	ENDS 

       	END	MAIN
