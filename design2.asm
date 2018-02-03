; 编写引导程序，写入到软盘第1扇区


assume cs:code 
code segment
;-----------------------------------------------------
; 下面为主程序，执行将任务程序写入到软盘上去
start:
    jmp task
    ;mov dx,seg task 
    ;mov dx,offset task 
    ;mov ax,cs
    ;mov es,ax
    ;mov bx,offset task

    ;mov al,1
    ;mov ch,0
    ;mov cl,1
    ;mov dh,0
    ;mov dl,0
    ;mov ah,3
    ;int 13H

    ;mov ax,4c00H
    ;int 21H
;-----------------------------------------------------
; 下面为任务程序
org 7c00H
task:

    jmp taskstart
    stack dw 64 dup (0)
    ; subprog  子程序的地址
    ; subindex 根据索引调用子程序
    ; subsign  是否调用子程序
    ; pagesel  表示当前正处在哪一个页面中，取值为0，1，2，3，4，分别代表主界面和其他四个选项
sp_addr:
    subprog  dw sub1,sub2,sub3,sub4
    subindex db 0
    subsign  db 0
    pagesel  db 0
    time_lc  dw 10*160,0*2
    section1 db '1) reset pc',0
    section2 db '2) start system',0
    section3 db '3) clock',0
    section4 db '4) set clock',0
    sections dw section1,section2,section3,section4
    rows     db 11,12,13,14
    columns  db 10,10,10,10
    time     db 9,8,7,4,2,0

taskstart:
    ; 初始化
    mov ax,cs
    mov ss,ax
    mov sp,offset sp_addr
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

    ; 进入主循环
    jmp main
main:
    call show_mainpage
forever:
    cmp subsign,0
    je nosub
    mov subsign,0
    push bx
    mov bl,subindex
    mov bh,0
    call word ptr subprog[bx]
    pop bx
    call show_mainpage
nosub:
    call delay
    jmp short forever

; reset pc 的逻辑代码
sub1:
    nop
    ret
; start system 的逻辑代码
sub2:
    nop
    ret

; clock 的逻辑代码
sub3:
    call clscreen
sub3s:
    call show_t
    call delay
    cmp pagesel,0
    je sub3ret
    jmp sub3s
sub3ret:
    ret
    
show_t:
    push ax
    push bx
    push cx
    push si

    mov bx,0
    mov cx,6
    mov si,0

show_time:
    push cx
    mov al,time[bx]
    out 70H,al
    in al,71H

    mov ah,al
    mov cl,4
    shr ah,cl
    and al,00001111b

    add al,30H
    add ah,30H
    call show_number
    pop cx

    cmp cx,4
    ja sign1
    je sign2
    cmp cx,1
    ja sign3
    jmp short circle
sign1:
    mov dl,'/'
    call show_sign
    jmp short circle
sign2:
    mov dl,' '
    call show_sign
    jmp short circle
sign3:
    mov dl,':'
    call show_sign
    jmp short circle
circle:
    inc bx
    add si,6
    loop show_time

    pop si
    pop cx
    pop bx
    pop ax
    ret

show_number:
    push bx
    push es
    mov bx,0b800H
    mov es,bx
    mov byte ptr es:[12*160+32*2+si],ah
    mov byte ptr es:[12*160+32*2+2+si],al
    pop es
    pop bx
    ret 


show_sign:
    push bx
    mov bx, 0b800H
    mov es,bx
    mov byte ptr es:[12*160+32*2+4+si],dl
    pop bx
    ret

; set clock 的逻辑代码
sub4:
    nop

; 显示主界面
show_mainpage:
    call clscreen
    push ds
    push bx
    push cx
    push di
    push si

    mov bx,cs
    mov ds,bx
    mov bx,0
    mov di,0
    mov cx,4
sects:
    mov si,sections[bx]
    mov dh,rows[di]
    mov dl,columns[di]
    call show_str
    add bx,2
    inc di
    loop sects

    pop si
    pop di
    pop cx
    pop bx
    pop ds
    ret

; 显示字符串，以0结尾
; 行：dh
; 列：dl
; 地址：ds:si
; 
show_str:
    push es
    push si
    push di
    push ax

    mov ax,0B800H
    mov es,ax
    mov al,0a0H
    mov ah,0
    mul dh
    mov di,ax
    mov al,2
    mov ah,0
    mul dl
    add di,ax

shows: 
    cmp byte ptr [si],0
    je show_end
    mov al,[si]
    mov es:[di],al
    inc si
    add di,2
    jmp short shows
show_end:
    pop ax
    pop di
    pop si
    pop es
    ret

; 延时子程序
delay:
    push ax
    push dx
    mov ax,0
    mov dx,1000H
delays:
    sub ax,1
    sbb dx,0
    cmp ax,0
    jne delays
    cmp dx,0
    jne delays
    pop dx
    pop ax
    ret

; 清屏子程序
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

; 键盘中断程序
; 安装到200H
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
    push dx
    push ds

    in al,60H
    mov dl,al
    pushf
    call dword ptr int9

    ; 取出pagesel的段地址，放到ds中
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
    jmp int7cret
second_page:
    mov ds:[pagesel],2
    mov ds:[subindex],2
    mov ds:[subsign],1
    jmp int7cret
third_page:
    mov ds:[pagesel],3
    mov ds:[subindex],4
    mov ds:[subsign],1
    jmp int7cret
forth_page:
    mov ds:[pagesel],4
    mov ds:[subindex],6
    mov ds:[subsign],1
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
    ; 取出扫描码
    mov al,dl
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
    mov cx,17
f1_s:
    
    inc byte ptr es:[bx+1]
    add bx,2
    loop f1_s
    jmp sub3set_end

sub3_esc:
    mov ds:[pagesel],0
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

    ; 取出扫描码
    mov al,dl
    ; 判断是否是esc
    cmp al,01H
    je sub4_esc
    jmp sub4set_end
sub4_esc:
    mov ds:[pagesel],0
    jmp sub4set_end

sub4set_end:
    pop cx
    pop bx
    pop es
    jmp int7cret

int7cret:
    pop ds
    pop dx
    pop bx
    pop ax
    iret
int7cend:
    nop


taskend:
    nop
code ends

end start

