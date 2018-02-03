; 编写一个中断安装程序
; 实现jump near ptr s 功能

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
    mov ax,cs
    mov ds,ax
    mov ax,0
    mov es,ax
    mov si,offset d0
    mov di,200H
    mov cx,d0end - d0
    cld
    rep movsb 
    mov ax,0
    mov es,ax
    mov es:[7cH*4],200H
    mov word ptr es:[7cH*4+2],0

    mov ax,4c00H
    int 21H

d0:
    push bp
    mov bp,sp
    add ss:[bp+2],bx
    pop bp
    iret
d0end:
    nop

code ends

end start