assume cs:code,ds:data,ss:stack

stack segment
    dw 64 dup (0)
stack ends

data segment
    dw 0,0
data ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,80H
    mov ax,data
    mov ds,ax

    mov ax,0
    mov es,ax

    push es:[9*4]
    pop ds:[0]
    push es:[9*4+2]
    pop ds:[2]

    ; 设置新的向量地址
    ; 设置过程不允许外部中断
    cli
    mov word ptr es:[9*4],offset int9
    mov es:[9*4+2],cs
    sti

    ; 显示 a-z
    mov ax,0b800H
    mov es,ax
    mov ah,'a'
s:
    mov es:[12*160+40*2],ah
    call delay
    inc ah
    cmp ah,'z'
    jna s

    ; 恢复int9中断向量地址
    mov ax,0
    mov es,ax
    push ds:[0]
    pop es:[9*4]
    push ds:[2]
    pop es:[9*4+2]


    mov ax,4c00H
    int 21H
delay:
    push ax
    push dx
    mov ax,0
    mov dx,8000H
s1:
    sub ax,1
    sbb dx,0
    cmp ax,0
    jne s1
    cmp dx,0
    jne s1
    pop dx
    pop ax
    ret

;------------------
int9:
    push ax
    push bx
    push es
    in al,60H
    pushf

    ;pushf 
    ;pop bx
    ;and bh,11111100B
    ;push bx
    ;popf

    call dword ptr ds:[0]

    cmp al,1
    jne int9ret

    mov ax,0b800H
    mov es,ax
    inc byte ptr es:[12*160+40*2+1]

int9ret:
    pop es
    pop bx
    pop ax
    iret

code ends

end start
