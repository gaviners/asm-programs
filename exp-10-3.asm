assume cs:code,ds:data,ss:stack

stack segment
    dw 16 dup(0)
stack ends

data segment 
    db 10 dup (0)
data ends

code segment 

start:
    mov ax,stack
    mov ss,ax
    mov sp,20H
    mov bx,data
    mov ds,bx
    mov ax,12000
    mov dx,0
    mov si,0
    call dtoc
    ; 将上面的字符串显示在屏幕上，8行，3列，属性为2
    mov dh,8
    mov dl,3
    mov cl,2
    call show_str
    mov ax,4c00H
    int 21H

dtoc:
    push cx
    push dx
    push si
    mov si,0
    push si
trans:
    mov cx,10
    call divdw
    jcxz letter_check_ax
    jmp short number
letter_check_ax:
    mov cx,ax
    jcxz letter_check_dx
    mov cx,0
    jmp short number
letter_check_dx:
    mov cx,dx
    jcxz last_letter
    mov cx,0
    jmp short number
number:
    add cx,30H
    push cx
    inc si
    jmp short trans

last_letter:
    mov si,0
    ; 上面将数字存放到栈中，下面从栈中弹出，存到对应的存储位置上
store:
    pop cx
    jcxz re
    mov [si],cl
    inc si
    jmp short store
re:
    mov byte ptr [si],0
    pop si
    pop dx
    pop cx
    ret


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