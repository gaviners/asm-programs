assume cs:code 
code segment
    a dw 1,2,3,4,5,6,7,8
    b dw 0,0
start:
    mov si,0
    mov cx,8
s:  
    mov ax,a[si]
    add b[0],ax
    adc b[2],0
    add si,2
    loop s

    mov ax,4c00H
    int 21H
code ends

end start