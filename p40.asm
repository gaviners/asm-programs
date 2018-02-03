assume cs:code

code segment
start:
    mov ax,0b800H
    mov es,ax
    mov bx,0
    mov al,8
    mov ah,3
    mov dh,0
    mov dl,0
    mov ch,0
    mov cl,1
    int 13h

    mov ax,4c00H
    int 21H
    
code ends

end start