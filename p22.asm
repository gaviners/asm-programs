assume  cs:code, ds:data, ss:stack

stack segment 
    dw 8 dup (0)
stack ends

data segment 
    db "Beginner's All-purpose Symbolic Instruction Code.",0
data ends

code segment 
start:
    mov ax,stack
    mov ss,ax
    mov sp,10H
    mov ax,data
    mov ds,ax
    mov bx,0
    mov ch,0
s:
    mov cl,[bx]
    jcxz zero
    cmp byte ptr [bx],61H
    jb s0
    cmp byte ptr [bx],7BH
    ja s0
    and byte ptr [bx],0DFH
s0:
    inc bx
    jmp short s
zero:
    mov ax,4c00H
    int 21H

code ends

end start