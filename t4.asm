; 编写引导程序，写入到软盘第1扇区


assume cs:code 
code segment
;-----------------------------------------------------
; 下面为主程序，执行将任务程序写入到软盘上去
org 7c00H
    subindex db 0
    subsign  db 0
    pagesel  db 0

    dw 64 dup (0)
    ; subprog  子程序的地址
    ; subindex 根据索引调用子程序
    ; subsign  是否调用子程序
    ; pagesel  表示当前正处在哪一个页面中，取值为0，1，2，3，4，分别代表主界面和其他四个选项

   

start:
    ; 初始化
    mov ax,cs
    mov ss,ax
    mov sp,offset start
    mov ds,ax

    ; 中断安装
    mov si,offset int7c
    mov ax,0
    mov es,ax
    mov di,200H

    mov cx,offset int7cend - offset int7c
    cld
    rep movsb

    ; 配置原int9的中断地址
    push es:[4*9]
    pop es:[202H]
    push es:[4*9+2]
    pop es:[204H]

    ; 配置新的int9地址,这时候不允许键盘中断，否则会出错
    cli
    mov word ptr es:[4*9],0200H
    mov word ptr es:[4*9+2],0000H
    sti
    nop

    mov ax,4c00H
    int 21H

org 200H
int7c:
    jmp short int7cstart
    int9 dw 0,0
    table dw sub0set,sub1set,sub2set,sub3set,sub4set
    mainpage dw first_page,second_page,third_page,forth_page
int7cstart:
    ; 首先根据页面，进入程序选择子程序
    push ax
    push bx

    in al,60H
    mov dl,al

    pushf
    call dword ptr int9
    mov bx,seg pagesel
    mov ds,bx
    mov al,ds:[pagesel]
    cmp al,4
    ja input_error
    mov bl,al
    mov bh,0
    add bx,bx
    jmp word ptr table[bx]

; 比较指令之后的转移，都是短转移
input_error:
    jmp int7cret

; 主页面
sub0set:
    ;in al,60H
    mov al,dl

    ; 判断是否是1~4
    cmp al,5
    ja sub0exit
    cmp al,2
    jb sub0exit
    mov bl,al
    sub bl,2
    mov bh,0
    add bx,bx
    jmp word ptr mainpage[bx]
sub0exit:
    jmp int7cret
; 对应每个选项卡，执行对应的配置
; 配置子程序的选项：
;      子程序索引
;      子程序调用
; 配置页面选项：
;      页面标记
first_page:
    mov ds:[pagesel],1
    mov ds:[subindex],0
    mov ds:[subsign],1
    ;mov si,1111H
    jmp int7cret
second_page:
    mov pagesel,2
    mov subindex,2
    mov subsign,1
    ;mov si,2222H
    jmp int7cret
third_page:
    mov ds:[pagesel],3
    mov ds:[subindex],4
    mov ds:[subsign],1
    ;mov si,3333H
    jmp int7cret
forth_page:
    mov pagesel,4
    mov subindex,6
    mov subsign,1
    ;mov si,4444H
    jmp int7cret

; 重启计算机和引导现有的操作系统不需要额外操作
sub1set:
sub2set:
    jmp int7cret
; 在时间显示界面，需要配置f1和esc
sub3set:
    push es
    push bx
    push cx

    in al,60H
    ; 判断是否是f1
    cmp al,3bH
    je sub3_f1
    ; 判断是否是esc
    cmp al,01H
    je sub3_esc
    jmp sub3set_end

sub3_f1:
    mov bx,0b800H
    mov es,bx
    mov bx,12*160+32*2
    mov cx,11
f1_s:
    
    inc byte ptr es:[bx+1]
    add bx,2
    loop f1_s
    jmp sub3set_end

sub3_esc:
    mov pagesel,0
    jmp sub3set_end 
sub3set_end:
    pop cx
    pop bx
    pop es
    jmp int7cret

sub4set:
    push es
    push bx
    push cx

    in al,60H
    pushf
    call dword ptr int9
    ; 判断是否是esc
    cmp al,01H
    je sub4_esc
    jmp sub4set_end
sub4_esc:
    mov pagesel,0
    jmp sub4set_end

sub4set_end:
    pop cx
    pop bx
    pop es
    jmp int7cret

int7cret:
    pop bx
    pop ax
    iret
int7cend:
    nop

code ends

end start

