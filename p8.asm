assume cs:code,ds:data,ss:stack

data segment
    dw 0123H,2345H,0,0,0,0,0,0
data ends

stack segment
    dw 0,0,0,0,0,0,0,0
stack ends

code segment 

start: 
    mov ax,data
    mov bx,stack
    mov dx,code

    mov ax,4c00H
    int 21H

code ends

end start