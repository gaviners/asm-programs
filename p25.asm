assume cs:code,ds:data,ss:stack

stack segment 
    dw 8 dup (0)
stack ends

data segment
    db 'conversation',0
data ends

code segment
start:
    mov ax,data
    mov ds,ax
    mov si,0
    mov ax,stack
    mov ss,ax
    mov ax,0b800H
    mov es,ax
    mov di,12*160
s:
    cmp byte ptr [si],0
    je finish
    mov al,[si]
    mov es:[di],al
    inc si
    add di,2
    mov bx,offset s - offset finish
    int 7cH
finish:
    mov ax,4c00H
    int 21H

code ends

end start