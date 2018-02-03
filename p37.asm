assume cs:code ,ss:stack

stack segment
    dw 64 dup (0)
stack ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,80H

    mov ax,0
    mov es,ax
    mov di,200H
    mov ax,cs
    mov ds,ax
    mov si,offset int7c
    mov cx,offset int7c_end - offset int7c
    cld
    rep movsb

    mov ax,0
    mov es,ax
    mov word ptr es:[7cH*4],200H
    mov word ptr es:[7cH*4+2],0

    mov ax,4c00H
    int 21H
    
; org 200H 
; 上面的伪指令表示下面的偏移地址从200H开始计算，与将要安装到的位置相符，这样才能正确找到子程序的位置
int7c:
    jmp short set
    
subtable:
    dw offset sub1 - offset subtable + 202H,offset sub2 - offset subtable + 202H,offset sub3 - offset subtable+202H,offset sub4 - offset subtable + 202H
set:
    push bx
    cmp ah,3
    ja sret
    mov bl,ah
    mov bh,0
    add bx,bx
    call word ptr cs:[202H+bx]

sret:
    pop bx
    iret

sub1:
    push bx
    push cx
    push es
    mov bx,0b800H
    mov es,bx
    mov bx,0
    mov cx,2000
sub1s:
    mov byte ptr es:[bx],' '
    add bx,2
    loop sub1s
    pop es
    pop cx
    pop bx
    ret

sub2:
    push bx
    push cx
    push es
    mov bx,0b800H
    mov es,bx
    mov bx,1
    mov cx,2000
sub2s:
    and byte ptr es:[bx],11111000b
    or es:[bx],al
    add bx,2
    loop sub2s
    pop es
    pop cx
    pop bx
    ret

sub3:
    push bx
    push cx
    push es
    mov bx,0b800H
    mov es,bx
    mov cl,4
    shl al,cl
    mov bx,1
    mov cx,2000
sub3s:
    and byte ptr es:[bx],10001111b
    or es:[bx],al
    add bx,2
    loop sub3s
    pop es
    pop cx
    pop bx
    ret

sub4:
    push cx
    push ds
    push es
    push si
    push di

    mov si,0b800H
    mov es,si
    mov ds,si
    mov si,160
    mov di,0
    cld
    mov cx,24
sub4s:
    push cx
    mov cx,160
    rep movsb
    pop cx
    loop sub4s

    mov cx,80
    mov si,0
sub4s1:
    mov byte ptr [160*24+si],' '
    add si,2
    loop sub4s1
    pop di
    pop si
    pop es
    pop ds
    pop cx
    ret

int7c_end:
    nop
    
code ends
end start