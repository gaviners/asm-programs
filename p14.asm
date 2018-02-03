assume cs:code,ss:stack,ds:data

stack segment
    dw 0,0,0,0,0,0,0,0
stack ends

data segment
    db '1. display      '
    db '2. brows        '
    db '3. replace      '
    db '4. modify       '
data ends

code segment
start:
    mov ax,stack 
    mov ss,ax
    mov sp,10H
    mov ax,data
    mov ds,ax

    mov bx,0
    mov cx,4
s0:
    push cx
    mov si,0
    mov cx,4
s:
    mov al,[bx].3[si]
    and al,11011111B
    mov [bx].3[si],al
    inc si
    loop s
    pop cx
    add bx,10H
    loop s0

    mov ax,4c00H
    int 21H

code ends
    
end start

