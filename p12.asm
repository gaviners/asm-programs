assume cs:code

a segment
    dw 1,2,3,4,5,6,7,8,9,0aH,0bH,0cH,0dH,0eH,0fH,0ffH
a ends

b segment
    dw 0,0,0,0,0,0,0,0
b ends

code segment

start:
    mov ax,a
    mov ds,ax
    mov ax,b
    mov ss,ax
    mov sp,10H
    mov cx,8H
    mov bx,0
s:
    push ds:[bx]
    add bx,2
    loop s

    mov ax,4c00H
    int 21H

code ends

end start