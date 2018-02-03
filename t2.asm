assume cs:code

code segment
start:
    mov ax,0b800H
    mov es,ax
    mov byte ptr es:[2000],'!'
    int 0
code ends

end start