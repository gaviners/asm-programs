assume cs:code,ss:stack,ds:data

stack segment 
    dw 8 dup (0)
stack ends

data segment
    db 'Welcome to masm!'
    db 82H,2cH,0f1H
data ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,10H
    mov ax,data
    mov ds,ax
    ; 经计算可得，一共25行，取12，13，14行，那么12行的段地址就为0b78H
    mov ax,0b878H
    mov es,ax
    ; 使用bx作为每一行字符的偏移
    mov bx,0
    ; 使用si最为第几行的偏移量
    ; 偏移常量为72，在中间
    mov si,0
    ; 使用di作为字符属性的偏移量
    mov di,0
    mov bp,0
    mov cx,3
s0:
    push cx
    mov bx,0
    mov bp,0
    mov cx,10H
s1:
    mov al,[bx]
    mov es:[bp+si+72],al
    mov al,[di+10H]
    mov es:[bp+si+73],al
    inc bx
    add bp,2
    loop s1
    pop cx
    inc di
    add si,0a0H
    loop s0
    mov ax,4c00H
    int 21H
code ends

end start