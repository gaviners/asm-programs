assume cs:code

code segment

start:
    jmp short s1
    jmp s1
    jmp s
s1:
    nop
    dw 40000 dup (0)
s:
    nop

code ends

end start