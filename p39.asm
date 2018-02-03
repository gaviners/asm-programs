; 从键盘接收一个字符串，并且实时显示，直到遇到enter键结束

assume cs:code,ds:data,ss:stack

stack segment
    dw 64 dup (0)
stack ends

data segment
    db 128 dup (0)
data ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,80H
    mov ax,data
    mov ds,ax

    mov si,0
    mov dh,10
    mov dl,10
    call getchar

    mov ax,4c00H
    int 21H


getchar:
    push ax
getchars:
    mov ah,0
    int 16H
    cmp al,20H
    jb nochar
    mov ah,0
    call charstack
    mov ah,2
    call charstack
    jmp short getchars

nochar:
    cmp ah,0eH
    je backspace
    cmp ah,1cH
    je enter
    jmp getchars
backspace:
    mov ah,1
    call charstack
    mov ah,2
    call charstack
    jmp getchars
enter:
    mov al,0
    mov ah,0
    call charstack
    mov ah,2
    call charstack
    pop ax
    ret

charstack:
    jmp short charstart

table dw charpush,charpop,charshow
top   dw 0

charstart:
    push bx
    push dx
    push di
    push es

    cmp ah,2
    ja sret
    mov bl,ah
    mov bh,0
    add bx,bx
    jmp word ptr table[bx]

charpush:
    mov bx,top
    mov [si][bx],al
    inc top
    jmp sret

charpop:
    cmp top,0
    je sret
    dec top
    mov bx,top
    mov al,[si][bx]
    jmp sret

charshow:
    mov bx,0b800H
    mov es,bx
    mov al,160
    mov ah,0
    mul dh
    mov di,ax
    add dl,dl
    mov dh,0
    add di,dx

    mov bx,0

charshows:
    cmp bx,top
    jne noempty
    mov byte ptr es:[di],' '
    jmp sret
noempty:
    mov al,[si][bx]
    mov es:[di],al
    mov byte ptr es:[di+2],' '
    inc bx
    add di,2
    jmp charshows

sret:
    pop es
    pop di
    pop dx
    pop bx
    ret



code ends

end start