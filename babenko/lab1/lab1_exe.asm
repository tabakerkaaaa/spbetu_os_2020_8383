STACK	SEGMENT	STACK
			
		DW 12 DUP(?)

STACK   	ENDS

DATA		SEGMENT
			
STR_TYPE	DB "PC type: $"			
STR_VERSION	DB 13, 10, "Version MS-DOS: 0*.0*   $"
STR_OEM 	DB 13, 10, "OEM:    $"
STR_NUMBER 	DB 13, 10, "User serial number:       $"
STR_PC		DB "PC$"
STR_PCXT	DB "PC/XT$"
STR_AT		DB "AT$"
STR_PCCon	DB "PC Convertible$"
STR_PS2m30	DB "PS2 model 30$"
STR_PS2m50m60	DB "PS2 model 50 or 60$"
STR_PS2m80	DB "PS2 model 80$"
STR_PCjr	DB "PCjr$"
STR_ERROR	DB "Not found, your type:  $" 


DATA		ENDS

CODE		SEGMENT


ASSUME 	CS:CODE, DS:DATA, SS:STACK


PRINT  	PROC	NEAR

       	PUSH	AX
       	MOV	AH, 09H
        INT	21H
		POP 	AX 
        RET

PRINT  	ENDP


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


BYTETODEC	PROC	NEAR

          	PUSH	CX
          	PUSH	DX
          	XOR	AH, AH
          	XOR 	DX, DX
          	MOV 	CX, 0AH

      	LOOP_BD:   
			DIV	CX
          	OR 	DL, 30H
          	MOV	[SI], DL
			DEC	SI
          	XOR	DX, DX
          	CMP	AX, 0AH
          	JAE	LOOP_BD
          	CMP	AL, 00H
          	JE	END_L
          	OR 	AL, 30H
          	MOV	[SI], AL
		   
       	END_L:     
			POP	DX
          	POP	CX
          	RET

BYTETODEC	ENDP

		
MAIN      	PROC	FAR

		PUSH  DS		
        SUB   AX, AX
        PUSH  AX
        MOV   AX, DATA
        MOV   DS, AX
		
        MOV	AX, 0F000H
		MOV	ES, AX
		MOV	AL, ES:[0FFFEH]
		
		MOV	DX, OFFSET STR_TYPE
		CALL PRINT
 
		CMP AL, 0FFH
		JZ 	PC
		
		CMP AL, 0FEH
		JZ 	PCXT
		
		CMP AL, 0FBH
		JZ 	PCXT
		
		CMP	AL, 0FCH
		JZ 	AT
		
		CMP AL, 0FCH
		JZ 	PC2m50or60
		
		CMP AL, 0FAH
		JZ 	PC2m30
		
		CMP AL, 0F8H
		JZ 	PC2m80
		
		CMP AL, 0FDH
		JZ 	PCjr
		
		CMP AL, 0F9H
		JZ 	PCCon

		JMP	ELS

       	PC:
		MOV 	DX, OFFSET STR_PC
		JMP 	PRINT_THIS
	
       	PCXT:
		MOV 	DX, OFFSET STR_PCXT
		JMP 	PRINT_THIS
		
		PC2m50or60:
		MOV 	DX, OFFSET STR_PS2m50m60
		JMP 	PRINT_THIS
	
      	AT:
		MOV 	DX, OFFSET STR_AT
		JMP 	PRINT_THIS
	
       	PC2m30:
		MOV 	DX, OFFSET STR_PS2m30
		JMP 	PRINT_THIS
	
       	PC2m80:
		MOV 	DX, OFFSET STR_PS2m80
		JMP 	PRINT_THIS
	
       	PCjr:
		MOV 	DX, OFFSET STR_PCjr
		JMP 	PRINT_THIS
	
       	PCCon:
		MOV 	DX, OFFSET STR_PCCon
		JMP 	PRINT_THIS

		ELS:
		MOV	DI, OFFSET STR_ERROR
		ADD	DI, 18H
		CALL	BYTETOHEX
		MOV	[DI], AX
		MOV	DX, OFFSET STR_ERROR
		JMP 	PRINT_THIS 


       	PRINT_THIS:
		CALL PRINT

		MOV	AH, 30H
		INT	21H
	
       	MOV	SI, OFFSET STR_VERSION
		ADD	SI, 13H
		CALL	BYTETODEC
		ADD	SI, 4H 
		MOV	AL, AH
		CALL	BYTETODEC
		MOV	DX, OFFSET STR_VERSION
		CALL	PRINT
	
		MOV 	SI, OFFSET STR_OEM
		ADD 	SI, 8H
		MOV	AL, BH
		CALL 	BYTETODEC
		MOV	DX, OFFSET STR_OEM
		CALL	PRINT
	
		MOV	DI, OFFSET STR_NUMBER
		ADD	DI, 1BH
		MOV	AX, CX
		CALL	WRDTOHEX
		MOV	AL, BL
		CALL	BYTETOHEX
		SUB	DI, 2H
		MOV	[DI], AX
		MOV	DX, OFFSET STR_NUMBER
		CALL 	PRINT

		RET
       	
MAIN		ENDP
CODE		ENDS
END 		MAIN
