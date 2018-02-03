; 编程，读取年月日时分秒，并显示到屏幕上

assume cs:code ,ss:stack

stack segment
    dw 8 dup (0)
stack ends


code segment
time: 
    db 9,8,7,4,2,0

start:
    mov ax,stack
    mov ss,ax
    mov sp,10h
    mov bx,offset time
    mov cx,6
    mov si,0
num:
    push cx
    mov al,cs:[bx]
    out 70H,al
    in al,71H

    mov ah,al
    mov cl,4
    shr ah,cl
    and al,00001111b

    add al,30H
    add ah,30H
    call show
    pop cx

    cmp cx,4
    ja sign1
    je sign2
    cmp cx,1
    ja sign3
    jmp short circle
sign1:
    mov dl,'/'
    call show_sign
    jmp short circle
sign2:
    mov dl,' '
    call show_sign
    jmp short circle
sign3:
    mov dl,':'
    call show_sign
    jmp short circle
circle:
    inc bx
    add si,6
    loop num

    mov ax,4c00H
    int 21H

show:
    push bx
    mov bx, 0b800H
    mov es,bx
    mov byte ptr es:[12*160+32*2+si],ah
    mov byte ptr es:[12*160+32*2+2+si],al
    pop bx
    ret 


show_sign:
    push bx
    mov bx, 0b800H
    mov es,bx
    mov byte ptr es:[12*160+32*2+4+si],dl
    pop bx
    ret

code ends

end start