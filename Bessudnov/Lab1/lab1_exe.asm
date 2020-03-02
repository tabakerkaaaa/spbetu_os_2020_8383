AStack    SEGMENT  STACK
          DW 20h DUP(?)   
		  ;DW 100h
AStack    ENDS

DATA  SEGMENT
	OS_VER db 13,10,"OS version: $"
	OS_FORM db "  .  $" 
	NUMBER db 13, 10, "Number OEM: $"
	NUMBER_FORM db "      $"	
	SERIAL_NUMBER db 13, 10, "Serial number: $"
	SERIAL_NUMBER_FORM db "            $"
	PC_VER db 13, 10, "PC Version: $"
	VER_PC db "PC$"
	VER_PCXT db "PC/XT$"
	VER_AT db "AT$"
	VER_PS2_30 db "PS2 model 30$"
	VER_PS2_80 db "PS2 model 80$"
	VER_PJR db "PCjr$"
	VER_PS2_5060 db "PS2 model 50/60$"
	VER_CON db "PC Convertible$"
	ERROR_MESSAGE db "Not found          $"
DATA ENDS

CODE SEGMENT
   ASSUME CS:CODE,DS:DATA,SS:AStack
;-------------------------------
PRINT_MESSEGE PROC near
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
PRINT_MESSEGE ENDP
;-------------------------------
TETR_TO_HEX   PROC  near
           and      al,0fh
           cmp      al,09
           jbe      NEXT
           add      al,07
NEXT:      
		   add      al,30h
           ret
TETR_TO_HEX   ENDP
;-------------------------------
BYTE_TO_HEX   PROC  near
           push     cx
           mov      ah,al
           call     TETR_TO_HEX
           xchg     al,ah
           mov      cl,4
           shr      al,cl
           call     TETR_TO_HEX 
           pop      cx          
           ret
BYTE_TO_HEX  ENDP
;-------------------------------
WRD_TO_HEX   PROC  near
           push     bx
           mov      bh,ah
           call     BYTE_TO_HEX
           mov      [di],ah
           dec      di
           mov      [di],al
           dec      di
           mov      al,bh
           call     BYTE_TO_HEX
           mov      [di],ah
           dec      di
           mov      [di],al
           pop      bx
           ret
WRD_TO_HEX ENDP
;--------------------------------------------------
BYTE_TO_DEC   PROC  near
           push     cx
           push     dx
           xor      ah,ah
           xor      dx,dx
           mov      cx,10
loop_bd:   div      cx
           or       dl,30h
           mov      [si],dl
		   dec		si
           xor      dx,dx
           cmp      ax,10
           jae      loop_bd
           cmp      al,00h
           je       END_PCl
           or       al,30h
           mov      [si],al
		   
END_PCl:     pop      dx
           pop      cx
           ret
BYTE_TO_DEC    ENDP
;-----------------------------------------------------------------------

OS_VERSION PROC near 
	push dx
	
	pop dx 
	ret
OS_VERSION ENDP
;-------------------------------


Main PROC FAR
	push ax
    sub ax,ax
	mov ax,DATA
	mov ds,ax
	pop ax
;---------------PC VER----------------
    mov ax,0f000h
    mov es,ax 
    mov al,es:[0fffeh]
	mov dx, offset PC_VER
	call PRINT_MESSEGE
	cmp al, 0ffh  ; PC
	je PC
	cmp al, 0feh  ; pc/xt
	je XT
	cmp al, 0fbh  ; pc/xt
	je XT
	cmp al, 0fch
	je AT_PS2_5060
	cmp al, 0fah  ; pc2 30
	je PS2_30
	cmp al, 0f8h  ; pc2 80
	je PS2_80
	cmp al, 0fdh  ; pcjr
	je JR
	cmp al, 0f9h  ; pc convertible
	je CON
	
ERROR:
	    mov si, offset ERROR_MESSAGE
		add si, 16
		call BYTE_TO_HEX
		mov dx, offset ERROR_MESSAGE
		jmp END_PC
PC:
		mov dx, offset VER_PC
		jmp END_PC
XT:
		mov dx, offset VER_PCXT
		jmp END_PC
PC_AT:
		mov dx, offset VER_AT
		jmp END_PC
PS2_5060:
		mov dx, offset VER_PS2_5060
		jmp END_PC
PS2_30:
		mov dx, offset VER_PS2_30
		jmp END_PC
PS2_80:
		mov dx, offset VER_PS2_80
		jmp END_PC
JR:
		mov dx, offset VER_PJR
		jmp END_PC
CON:
		mov dx, offset VER_CON
		jmp END_PC
AT_PS2_5060:	                         
       	mov ah, 192						
		int 15H
		mov al, ES:[BX+3]
		cmp al, 00h
		je PC_AT                  
		jmp PS2_5060
END_PC:
	call PRINT_MESSEGE
	
;--------------OS-----------------
	mov ah, 30h
	int 21h
	push ax
	mov dx, offset OS_VER
	call PRINT_MESSEGE
	mov si, offset OS_FORM
	inc si
	call BYTE_TO_DEC
	pop ax
    mov al, ah                 	
    add si, 3
	call BYTE_TO_DEC
	mov dx, offset OS_FORM	
	call PRINT_MESSEGE
	mov dx, offset NUMBER
	call PRINT_MESSEGE
	mov si, offset NUMBER_FORM
	add si, 5
	mov al, bh                   
	call BYTE_TO_DEC
	mov dx, offset NUMBER_FORM
	call PRINT_MESSEGE
	mov dx, offset SERIAL_NUMBER
    call PRINT_MESSEGE
    mov di, offset SERIAL_NUMBER_FORM
	add di, 10
	mov ax, cx
	call WRD_TO_HEX
	mov al, bl
	call BYTE_TO_HEX
	sub di, 2
	mov [di], ax
	mov dx, offset SERIAL_NUMBER_FORM
	call PRINT_MESSEGE	
;-------------------------------
    xor  AL,AL
    mov AH,4Ch
	int  21H 	
	
Main ENDP
CODE ENDS
      END Main