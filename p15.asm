assume cs:code, ss:stack

stack segment
    db 256 dup(0)
stack ends

code segment
start:
    mov ax,stack
    mov ss,ax
code ends

end start