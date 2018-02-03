assume cs:code

code segment 
start:
    mov ah,2
    mov bh,0
    mov dh,5
    mov dl,12
    int 10H

    mov ah,9
    mov bh,0
    mov bl,11001010b
    mov al,'a'
    mov cx,3
    int 10H

    mov ax,4c00h
    int 21H

code ends

end start 