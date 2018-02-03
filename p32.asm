assume cs:code,ss:stack

stack segment
    dw 64 dup (0)
stack ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,80H

    mov ax,0b800H
    mov es,ax
    mov ah,'a'
s:
    mov es:[12*160+40*2],ah
    call delay
    inc ah
    cmp ah,'z'
    jna s

    mov ax,4c00H
    int 21H
delay:
    push ax
    push dx
    mov ax,0
    mov dx,1000H
s1:
    sub ax,1
    sbb dx,0
    cmp ax,0
    jne s1
    cmp dx,0
    jne s1
    pop dx
    pop ax
    ret

code ends

end start

