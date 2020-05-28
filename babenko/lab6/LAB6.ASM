CODE      	SEGMENT      

		ASSUME CS:CODE, DS:DATA, SS:STACKK 

WRITE  	PROC	NEAR

       		PUSH	AX
       		MOV	AH, 09H
          	INT	21H
		POP 	AX 
          	RET

WRITE  	ENDP

Main		PROC	FAR           

		MOV 	AX, DATA		  
		MOV 	DS, AX

		MOV	AX, STACKK
		SUB	AX, CODE
		ADD	AX, 100H
		MOV	BX, AX
		MOV	AH, 4AH
		MOV	AL, 00H
		INT	21H
		
		JNC	PARAMETRBLOCK

		MOV 	DX, OFFSET STR1 
		CALL 	WRITE

		CMP	AX, 7H
		JE	ERROR1
		CMP	AX, 8H
		JE	ERROR2
		
		MOV 	DX, OFFSET STR2
		CALL 	WRITE
		JMP	ENDPROG
		ERROR1:
		MOV 	DX, OFFSET STR3 
		CALL 	WRITE
		JMP	ENDPROG
		ERROR2:
		MOV 	DX, OFFSET STR4 
		CALL 	WRITE
		JMP	ENDPROG

		PARAMETRBLOCK:
		MOV 	BYTE PTR [BLOCKPARAM], 0H


		MOV 	ES, ES:[2CH]
		MOV 	SI, 0H

       	BEG:
		MOV 	AX, ES:[SI]
		INC 	SI
		CMP 	AX, 0H
		JNE 	BEG
		ADD 	SI, 3H
		MOV 	DI, 0H
	
       	FIND:
		MOV 	CL, ES:[SI]
		CMP 	CL, 0H
		JE	NAME2LAB	
		CMP 	CL, '\'
		JNE 	ENTRY
		MOV 	DELTA, DI

       	ENTRY:
		MOV 	BYTE PTR [PATH + DI], CL
		INC 	SI
		INC 	DI
		JMP 	FIND
	
       	NAME2LAB:
		MOV 	BX, DELTA
		INC 	BX
		MOV 	BYTE PTR [PATH + BX], 'l'
		INC 	BX
		MOV	BYTE PTR [PATH + BX], 'a'
		INC 	BX	
		MOV 	BYTE PTR [PATH + BX], 'b'
		INC 	BX	
		MOV 	BYTE PTR [PATH + BX], '2'
		INC 	BX	
		MOV 	BYTE PTR [PATH + BX], '.'
		INC 	BX
		MOV 	BYTE PTR [PATH + BX], 'c'
		INC 	BX
		MOV 	BYTE PTR [PATH + BX], 'o'
		INC 	BX
		MOV 	BYTE PTR [PATH + BX], 'm'
		INC 	BX
		MOV 	BYTE PTR [PATH + BX], '$'
	
       	MOV 	FORSP, SP
		MOV 	FORSS, SS

		MOV 	BX, OFFSET BLOCKPARAM
		MOV 	DX, OFFSET PATH 
		MOV 	AX, 4B00H	
		INT 	21H
	
		PUSH	AX
		MOV	AX, DATA
		MOV	DS, AX
		POP	AX
		MOV 	SS, FORSS	 
		MOV 	SP, FORSP 
	
		JNC 	FINALITY

		MOV 	DX, OFFSET STR5 
		CALL 	WRITE 

		CMP 	AX, 1H
		JE 	ERROR3
		CMP 	AX, 2H
		JE 	ERROR4
		CMP 	AX, 5H
		JE 	ERROR5
		CMP 	AX, 8H
		JE 	ERROR6
		CMP 	AX, 0AH
		JE 	ERROR7
	
		MOV 	DX, OFFSET STR6
		CALL 	WRITE
		JMP 	ENDPROG 
       	ERROR3:
		MOV 	DX, OFFSET STR7
		CALL 	WRITE
		JMP 	ENDPROG 
       	ERROR4:
		MOV 	DX, OFFSET STR8
		CALL 	WRITE
		JMP 	ENDPROG 	
       	ERROR5:
		MOV 	DX, OFFSET STR9
		CALL 	WRITE
		JMP 	ENDPROG	
       	ERROR6:
		MOV 	DX, OFFSET STR4
		CALL 	WRITE
		JMP 	ENDPROG	
       	ERROR7:
		MOV 	DX, OFFSET STR10
		CALL 	WRITE
		JMP 	ENDPROG	
	
		FINALITY:
		MOV 	AH, 4DH	
		MOV	AL, 00H
		INT 	21H
	
		MOV	DI, OFFSET STR11
		MOV	[DI + 13H], AL
		MOV 	DX, OFFSET STR11
		CALL 	WRITE
	
		CMP 	AH, 0H
		JE 	CODE0
		CMP 	AH, 1H
		JE 	CODE1
		CMP 	AH, 2H
		JE 	CODE2
		
		MOV	DX, OFFSET STR12
		CALL	WRITE
       	JMP 	ENDPROG
       	CODE0:
		MOV 	DX, OFFSET STR13
		CALL 	WRITE
		JMP 	ENDPROG 	
       	CODE1:
		MOV 	DX, OFFSET STR14
		CALL 	WRITE
		JMP 	ENDPROG 
       	CODE2:
		MOV 	DX, OFFSET STR15
		CALL	WRITE
		JMP 	ENDPROG	
	
		ENDPROG:
		MOV 	AH, 4CH
		INT 	21H

Main		ENDP	
CODE      	ENDS 

DATA		SEGMENT

STR1 	DB "Error function 4AH!", 0DH, 0AH, "$"
STR2 	DB "Invalid memory block address!", 0DH, 0AH, "$"
STR3 	DB "Control memory block destroyed!", 0DH, 0AH, "$"
STR4 	DB "Not memory!", 0DH, 0AH, "$"
STR5 	DB "Error function 4BH!", 0DH, 0AH, "$"
STR6 	DB "Wrong format!", 0DH, 0AH, "$"
STR7 	DB "Wrong function number!", 0DH, 0AH, "$"
STR8 	DB "File not found!", 0DH, 0AH, "$"
STR9 	DB "Disk error!", 0DH, 0AH, "$"
STR10 	DB "Wrong environment string!", 0DH, 0AH, "$"
STR11 	DB 0DH, 0AH, "Completion code:      ", 0DH, 0AH, "$"
STR12 	DB "Exit by function 31H!", 0DH, 0AH, "$"
STR13 	DB "Normal exit!", 0DH, 0AH, "$"
STR14 	DB "Exit by ctrl-break!", 0DH, 0AH, "$"
STR15 	DB "Exit by device error!", 0DH, 0AH, "$"

BLOCKPARAM 	DB 0EH dup(0)
PATH   		DB 46H dup(0)
FORSS		DW ?
FORSP		DW ? 	  
DELTA		DW 0H 				

DATA      	ENDS 

STACKK	SEGMENT	STACK           

DW 		100H DUP(?)

STACKK    	ENDS  


       	END	Main

