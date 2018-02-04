assume cs:code,ss:stack

stack segment
    dw 8 dup (0)
stack ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,10H

    mov ax,0
    mov es,ax
    mov bx,7c00H
    ; 驱动器号为80H，c盘
    mov dl,80H
    mov dh,0
    mov ch,0
    mov cl,1
    ; 功能选择
    mov ah,2
    mov al,1
    int 13H

    mov ax,4c00H
    int 21H
    
code ends

end start