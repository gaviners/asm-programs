; 7cH中断程序的实现与安装
; 完成loop功能
; bx保存转移位移
; cx 为循环次数

assume cs:code 

code segment
start:
    mov ax,cs
    mov ds,ax
    mov si,offset loo
    mov ax,0
    mov es,ax
    mov di,200H
    mov cx,offset loend - offset loo
    cld
    rep movsb

    mov ax,0
    mov es,ax
    mov word ptr es:[7cH*4],200H
    mov word ptr es:[7cH*4+2],0

    mov ax,4c00H
    int 21H

loo:
    cmp cx,0
    je lostop
    dec cx
    push bp
    mov bp,sp
    add ss:[bp+2],bx
    pop bp
lostop:
    iret
loend:    

code ends

end start