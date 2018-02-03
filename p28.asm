assume cs:code 

code segment
start:
    mov ax,cs
    mov ds,ax
    mov si,offset show
    mov ax,0
    mov es,ax
    mov di,200H
    mov cx,offset show_end - offset show
    cld 
    rep movsb

    mov ax,0
    mov es,ax
    mov word ptr es:[7cH*4],200H
    mov word ptr es:[7cH*4+2],0

    mov ax,4c00H
    int 21H

show:
    push es
    push si
    push di
    push ax

    mov ax,0B800H
    mov es,ax
    mov al,0a0H
    mul dh
    mov di,ax
    mov al,2
    mul dl
    add di,ax

s: 
    cmp byte ptr [si],0
    je send
    mov al,[si]
    mov es:[di],al
    mov es:[di+1],cl
    inc si
    add di,2
    jmp short s
send:
    pop ax
    pop di
    pop si
    pop es
    iret
show_end:
    nop

code ends

end start