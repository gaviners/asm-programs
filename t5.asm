; 测试程序：
; 测试没有操作系统的情况下，中断的执行情况

code segment
assume cs:code
start:


    mov ax,install
    mov es,ax
    mov bx,7c00H
    ; 驱动器号为80H，c盘
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,1
    ; 功能选择
    mov ah,3
    mov al,1
    int 13H


    mov ax,interrupt
    mov es,ax
    mov bx,200H
    ; 驱动器号为0H，软盘
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,2
    ; 功能选择
    mov ah,3
    mov al,1
    int 13H


    mov ax,4c00H
    int 21H


code ends

install segment
assume cs:install
org 7c00H

    ; int7c 安装
    ; int9 保存
    ; int7c中断向量设置
    ; 清屏
    ; 无限循环

    jmp run
    run_stack dw 16 dup (0)
sp_end:
    ; 将第二个分区的代码加载到1：2000H，也就是中断代码，然后进行中断安装
    nop

run:
    mov ax,install
    mov ss,ax
    mov sp,offset sp_end


    mov ax,2000H
    mov es,ax
    mov bx,00H
    ; 驱动器号为0H，软盘
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,2
    ; 功能选择
    mov ah,2
    mov al,1
    int 13H   


    mov ax,2000H
    mov ds,ax
    mov si,00H
    mov ax,0
    mov es,ax
    mov di,200H
    mov cx,offset int7cend - offset int7c
    cld
    rep movsb

    mov ax,0
    mov es,ax

    push es:[4*9]
    pop es:[202H]
    push es:[4*9+2]
    pop es:[204H]

    cli
    mov word ptr es:[4*9],200H
    mov word ptr es:[4*9+2],0
    sti

    call clscreen
    nop
    ; 无限循环
    jmp $

clscreen:
    push cx
    push es
    push bx
    mov bx,0b800H
    mov es,bx
    mov bx,0
    mov cx,2000
cls:
    mov byte ptr es:[bx],' '
    mov byte ptr es:[bx+1],07H
    add bx,2
    loop cls
    pop bx
    pop es
    pop cx
    ret

install ends

;----------------------------------------------

interrupt segment
assume cs:interrupt
org 200H
int7c:
    jmp short int7cstart
    int9 dw 0,0
int7cstart:
    
    push ax
    push bx
    push cx
    push es

    in al,60H

    pushf
    call dword ptr int9

    mov ah,1
    mov cl,4
    shl ah,cl
    ; 'r'
    cmp al,13H
    je red
    cmp al,22H
    je green
    cmp al,30H
    je blue
    jmp short sret

red:
    shl ah,1
green:
    shl ah,1
blue:
    mov bx,0b800H
    mov es,bx
    mov bx,1
    mov cx,2000
s:
    and byte ptr es:[bx],10001111b
    mov cl,4
    shl ah,cl
    or es:[bx],ah
    add bx,2
    loop s

sret:
    pop es
    pop cx
    pop bx
    pop ax

    iret

int7cend:
    nop

interrupt ends


end start