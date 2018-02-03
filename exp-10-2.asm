assume cs:code,ss:stack,ds:data

stack segment
    dw 8 dup (0)
stack ends

data segment

data ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,10H
    mov ax,42FFH
    mov dx,05H
    mov cx,0AH
    call divdw
    mov ax,4c00H
    int 21H
divdw:
    ; 需要使用bx，先将值存储起来
    push bx
    ; 将低16位存储起来
    push ax
    ; 进行高位运算
    mov ax,dx
    mov dx,0
    div cx
    pop bx
    ; 将高位商存储起来
    push ax
    ; 进行低位运算
    mov ax,bx
    div cx
    mov cx,dx
    pop dx
    pop bx
    ret

code ends

end start

