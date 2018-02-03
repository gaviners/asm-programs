; 编写一个新的中断程序，放到7cH里面
; 实现将软盘的面号、磁道号与扇区号封装为逻辑扇区号

assume cs:code ,ss:stack

stack segment
    dw 64 dup (0)
stack ends


code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,80H

    mov ax,cs
    mov ds,ax
    mov si,offset int7c

    mov ax,0
    mov es,ax
    mov di,200H
    mov cx,offset int7cend - offset int7c

    cld
    rep movsb

    push es:[7cH*4]
    pop es:[202H]
    push es:[7cH*4+2]
    pop es:[204H]

    cli
    mov word ptr es:[7cH*4],200H
    mov word ptr es:[7cH*4+2],0
    sti

    mov ax,4c00H
    int 21H

org 200H
int7c:
    jmp short int7cstart
    int13 dd 0
    table dw read,write
int7cstart:
    push bx
    push cx
    
    cmp ah,2
    ja sret
    mov bl,ah
    mov bh,0
    add bx,bx
    jmp word ptr table[bx]


cal:
    mov cx,1440
    mov ax,dx
    mov dx,0
    div cx
    mov cl,al
    mov ax,dx
    ; 得到磁头号，也就是面号
    mov dh,cl
    ; 写入驱动器号0
    mov dl,0
    ; 计算磁道号
    mov ch,18
    div ch
    mov ch,al
    mov cl,ah
    inc cl
    ; 操作扇区数为1
    mov al,1
    ret

read:
    call cal
    mov ah,2
    pushf
    call dword ptr int13
    jmp sret

write:
    call cal
    mov ah,3
    pushf
    call dword ptr int13
    jmp sret
    

sret:
    pop cx
    pop bx
    iret

int7cend:
    nop
code ends

end start