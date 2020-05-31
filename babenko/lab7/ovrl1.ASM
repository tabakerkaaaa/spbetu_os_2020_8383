CODE      	SEGMENT      

		ASSUME CS:CODE, DS:NOTHING, SS:NOTHING

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

WRITE  	PROC	NEAR

       	PUSH	AX
       	MOV	AH, 09H
          	INT	21H
		POP 	AX 
          	RET

WRITE  	ENDP

TETRTOHEX	PROC	NEAR

          	AND	AL, 0FH
          	CMP	AL, 09H
          	JBE	NEXT
      	ADD	AL, 07H

       	NEXT:      
       	ADD	AL, 30H
          	RET

TETRTOHEX	ENDP

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
