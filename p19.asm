assume cs:code,ds:data

data segment
    db 'ABCDEF'
    ;db 02H
data ends

code segment

start:
    mov ax,data
    mov ds,ax
    mov ax,0b828h
    mov es,ax
    mov cx,6
    mov bx,0
    mov si,0
s:
    mov al,[bx]
    mov es:[si],al
    mov es:[si+0a0H],al
    mov es:[si+1400H],al
    mov byte ptr es:[si+1],07H
    mov byte ptr es:[si+0a1H],07H
    mov byte ptr es:[si+1401H],07H
    inc bx
    add si,2
    loop s
    mov ax,4c00H
    int 21H
code ends

end start