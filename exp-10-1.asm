; 名称：显示字符串
; 功能：在指定的位置，用指定的颜色，显示一个用0结束的字符串
;
;

assume cs:code , ss:stack, ds:data

stack segment
    dw 8 dup (0)
stack ends

data segment
    db 'Welcome to masm!',0
data ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,10H
    mov ax,data
    mov ds,ax
    mov dh,8
    mov dl,3
    mov cl,2
    mov si,0
    call show_str
    mov ax,4c00H
    int 21H

show_str:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    mov ax,0B800H
    mov es,ax
    ; 索引从0开始，先减去1
    ; 计算行的偏移量，赋值到bx
    dec dh
    mov al,dh
    mov bl,0a0H
    mul bl
    mov bx,ax
    ; 计算列的偏移量,放到di中
    dec dl
    add dl,dl
    mov ah,0
    mov al,dl
    mov di,ax
    ; 将属性放到dl中
    mov dl,cl
s:
    mov ch,0
    mov cl,[si]
    jcxz zero
    mov es:[bx+di],cl
    mov es:[bx+di+1],dl
    inc si
    add di,2
    jmp short s

zero:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
code ends

end start
