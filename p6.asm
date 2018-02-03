assume cs:abc

abc segment
    mov bx,0
    mov cx,3fH
    mov ax,0020H
    mov ds,ax
s:  mov [bx],bx
    inc bx
    loop s

    mov ax,4c00H
    int 21H
abc ends

end