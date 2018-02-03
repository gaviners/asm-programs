assume cs:abc

abc segment
    mov al,ds:[0]
    mov bl,ds:[1]

    mov ax,4c00H
    int 21H

abc ends

end