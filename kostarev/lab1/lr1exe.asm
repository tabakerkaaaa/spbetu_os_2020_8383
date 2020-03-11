AStack    SEGMENT  STACK
          DW 20h DUP(?)   
AStack    ENDS

DATA  SEGMENT
    TYPE_PC db 'Type: ', '$'
    VERSION db 'Version: ', '$'
    SERIAL db 0DH, 0AH, 'Serial: ', '$'
    OEM db 0DH, 0AH, 'OEM: ', '$'
    NEW_STR db "  $"
    NEW_STR2 db "        $"
    STR_PC db 'PC',0DH,0AH,'$'
    STR_PCXT db 'PC/XT',0DH,0AH,'$'
    STR_AT db 'AT',0DH,0AH,'$'
    STR_PS230 db 'PS2 model 30',0DH,0AH,'$'
    STR_PS280 db 'PS2 model 80',0DH,0AH,'$'
    STR_PCJR db 'PCjr',0DH,0AH,'$'
    STR_PCCO db 'PC Convertible',0DH,0AH,'$'
DATA ENDS

CODE SEGMENT
   ASSUME CS:CODE,DS:DATA,SS:AStack

TETR_TO_HEX PROC near
    and AL,0Fh
    cmp AL,09
    jbe NEXT
    add AL,07
    NEXT: add AL,30h
    ret
TETR_TO_HEX ENDP

BYTE_TO_HEX PROC near
    push CX
    mov AH,AL
    call TETR_TO_HEX
    xchg AL,AH
    mov CL,4
    shr AL,CL
    call TETR_TO_HEX
    pop CX
    ret
BYTE_TO_HEX ENDP

WRD_TO_HEX PROC near
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

BYTE_TO_DEC PROC near
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

WRITE_NUMBER PROC near
    push AX
    mov AH, 02H
    int 21H
    pop AX
    ret
WRITE_NUMBER ENDP

WRITE_STRING PROC near
    push AX
    mov AH, 09H
    int 21H
    pop AX
    ret
WRITE_STRING ENDP

WRITE_TYPE PROC near
    push	AX
    push	BX
    push	DX
    push	ES
    mov DX,offset TYPE_PC
    call WRITE_STRING
    mov	BX,0F000H
    mov	ES,BX
    mov	AL,ES:[0FFFEH]
    call BYTE_TO_HEX
    cmp AX, 0FFH
    je printPC
    cmp AX, 0FEH
    je printPCXT
    cmp AX, 0FCH
    je printAT
    cmp AX, 0FAH
    je printPS230
    cmp AX, 0F8H
    je printPS280
    cmp AX, 0FDH
    je printPCjr
    cmp AX, 0F9H
    je printPCCo
printPC:
    mov DX,offset STR_PC
    jmp printSTR
printPCXT:
    mov DX,offset STR_PCXT
    jmp printSTR
printAT:
    mov DX,offset STR_AT
    jmp printSTR
printPS230:
    mov DX,offset STR_PS230
    jmp printSTR
printPS280:
    mov DX,offset STR_PS280
    jmp printSTR
printPCjr:
    mov DX,offset STR_PCJR
    jmp printSTR
printPCCo:
    mov DX,offset STR_PCCO
printSTR:
    call WRITE_STRING
    pop	ES
    pop	DX
    pop	BX
    pop	AX
    ret
WRITE_TYPE ENDP

WRITE_VERSION PROC near
    push AX
    push DX
    mov DX, offset VERSION
    call WRITE_STRING
    mov DL, AL
    add DL, '0'
    call WRITE_NUMBER
    mov DL, '.'
    call WRITE_NUMBER
    mov DL, AH
    add DL, '0'
    call WRITE_NUMBER
    pop DX
    pop AX
    ret
WRITE_VERSION ENDP

WRITE_OEM PROC near
    push AX
    push DX
    mov DX, offset OEM
    call WRITE_STRING
    mov SI, offset NEW_STR
	add SI, 2
	mov AL, BH
	call BYTE_TO_DEC
	mov DX, offset NEW_STR
	call WRITE_STRING
    pop DX
    pop AX
    ret
WRITE_OEM ENDP

WRITE_SERIAL PROC near
    push AX
    push DX
    mov DX, offset SERIAL
    call WRITE_STRING
    mov DI, offset NEW_STR2
	add DI, 6
	mov AX, CX
	call WRD_TO_HEX
	mov AL, BL
	call BYTE_TO_HEX
	sub DI, 2
	mov [DI], AX
	mov dx, offset NEW_STR2
	call WRITE_STRING	
    pop DX
    pop AX
    ret
WRITE_SERIAL ENDP

MAIN PROC FAR
    push AX
    sub AX,AX
    mov AX,DATA
    mov DS,AX
    pop AX
    call WRITE_TYPE
    mov AH, 30H
    int 21H
    call WRITE_VERSION
    call WRITE_OEM
    call WRITE_SERIAL
    xor AL,AL
    mov AH,4Ch
    int 21H
MAIN ENDP
CODE ENDS
      END MAIN