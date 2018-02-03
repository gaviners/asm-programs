assume cs:code, ss:stack, ds:data

stack segment 
    dw 8 dup (0)
stack ends

data segment 

data ends 

code segment
start:
    ; 设置栈
    mov ax,stack
    mov ss,ax
    mov sp,10H
    ; 中断代码传送
    mov ax,cs
    mov ds,ax
    mov si,offset d0
    mov ax,0
    mov es,ax
    mov di,200H
    mov cx,offset d0stop - offset d0
    cld
    rep movsb
    ; 设置中断向量
    mov ax,0
    mov es,ax
    mov word ptr es:[0*4],200H
    mov word ptr es:[0*4+2],0

    mov ax,4c00H
    int 21H

d0:
    jmp short d0start
    db 'overflow!'
d0start:
    mov ax,cs
    mov ds,ax
    mov si,202H
    mov ax,0b800H
    mov es,ax
    mov di,12*160+36*2
    mov cx,9
s: 
    mov al,[si]
    mov es:[di],al
    mov byte ptr es:[di+1],4aH
    inc si
    add di,2
    loop s
    mov ax,4c00H
    int 21H
d0stop:
    nop

code ends

end start