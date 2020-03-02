TESTPC SEGMENT
ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
ORG 100H
START: JMP BEGIN
;Данные
TYPE_PC db  'Type: PC',0DH,0AH,'$'
TYPE_PC_XT db 'Type: PC/XT',0DH,0AH,'$'
TYPE_AT db  'Type: AT',0DH,0AH,'$'
TYPE_PS2_30 db 'Type: PS2 модель 30',0DH,0AH,'$'
TYPE_PS2_50_60 db 'Type: PS2 модель 50 или 60',0DH,0AH,'$'
TYPE_PS2_80 db 'Type: PS2 модель 80',0DH,0AH,'$'
TYPE_PС_JR db 'Type: PСjr',0DH,0AH,'$'
TYPE_PC_CONV db 'Type: PC Convertible',0DH,0AH,'$'


VERSION_OS db 'Version DOS:  .  ',0DH,0AH,'$'
OEM db  'Serial number OEM:  ',0DH,0AH,'$'
USER_NUMBER db  'User serial number:       H $'
;Процедуры
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
;байт в AL переводится в два символа шест. числа в AX
push CX
mov AH,AL
call TETR_TO_HEX
xchg AL,AH
mov CL,4
shr AL,CL
call TETR_TO_HEX ;в AL старшая цифра
pop CX ;в AH младшая
ret
BYTE_TO_HEX ENDP
;-------------------------------
WRD_TO_HEX PROC near
;
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
; перевод в 10с/с, SI - адрес поля младшей цифры
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
;-------------------------------
WRITE_PROC PROC near
	mov AH,09h
	int 21h
	ret
WRITE_PROC ENDP

PC_WRITE PROC near

	mov ax, 0f000h ; получаем номер модели 
	mov es, ax
	mov al, es:[0fffeh]

	cmp al, 0ffh ; начинаем стравнивать
	je pc
	cmp al, 0feh
	je pc_xt
	cmp al, 0fbh
	je pc_xt
	cmp al, 0fch
	je pc_at
	cmp al, 0fah
	je pc_ps2_m30
	cmp al, 0f8h
	je pc_ps2_m80
	cmp al, 0fdh
	je pc_jr
	cmp al, 0f9h
	je pc_conv
	xor dh, dh
	mov dl, al 
	jmp write
	
pc:
		mov dx, offset TYPE_PC
		jmp write
pc_xt:
		mov dx, offset TYPE_PC_XT
		jmp write
pc_at:
		mov dx, offset TYPE_AT
		jmp write
pc_ps2_m30:
		mov dx, offset TYPE_PS2_30
		jmp write
pc_ps2_m80:
		mov dx, offset TYPE_PS2_80
		jmp write
pc_jr:
		mov dx, offset TYPE_PС_JR
		jmp write
pc_conv:
		mov dx, offset TYPE_PC_CONV
		jmp write
write:
		call WRITE_PROC
	ret
PC_WRITE ENDP



VERSION_OS_proc PROC near
	MOV AH,30h
	INT 21h
	
	push ax
	
	mov si, offset VERSION_OS
	add si, 13   ; сдвиг в строке
	call BYTE_TO_DEC
	pop ax
	mov al, ah
	add si, 3
	call BYTE_TO_DEC
	mov dx, offset VERSION_OS ; сдвиг для печати
	call WRITE_PROC
	
	mov si, offset OEM
	add si, 19
	mov al, bl
	call BYTE_TO_DEC
	mov dx, offset OEM 
	call WRITE_PROC
	
	mov di, offset USER_NUMBER
	add di, 25
	mov ax, cx
	call WRD_TO_HEX
	mov al, bl
	call BYTE_TO_DEC
	sub di, 2 ; what is it
	mov [di], ax
	mov dx, offset USER_NUMBER
	call WRITE_PROC
	
	ret
	
VERSION_OS_proc ENDP

BEGIN:

call PC_WRITE
call VERSION_OS_proc


xor AL,AL
mov AH,4Ch
int 21H
TESTPC ENDS
END START ;
