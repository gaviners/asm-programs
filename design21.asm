;---------------------------------------------------------------------------
;   version:        v1.0
;   author:         zhishengqianjun
;   email:          zhishengqianjun@163.com
;   finish time:    2018/02/04
;---------------------------------------------------------------------------
; 功能实现：
;       编写引导程序，实现如下的4个功能
;            1) reset pc
;            2) start system
;            3) clock
;            4) set clock
;       将引导程序写入软盘，从软盘启动
;---------------------------------------------------------------------------

;================================================
;   安装代码
;       将任务代码安装到软盘上去
;   任务代码分成4部分：
;       1、内存加载代码， 存放在第一扇区
;       2、配置信息代码， 存放在第二扇区
;       3、主程序代码，   存放在三、四扇区
;       4、中断程序代码， 存放在五扇区
;================================================
code segment
assume cs:code 
start:
    ; 将task写入到软盘第一扇区
    mov ax,task
    mov es,ax
    mov bx,7c00H
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,1
    mov ah,3
    mov al,1
    int 13H

    ; 将config配置信息加载到第2扇区
    mov ax,config
    mov es,ax
    mov bx,0
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,2
    mov ah,3
    mov al,1
    int 13H

    ; 将install写入到软盘第3,4扇区
    mov ax,install
    mov es,ax
    mov bx,0
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,3
    mov ah,3
    mov al,2
    int 13H

    ; 将中断程序写到软盘的第5扇区
    mov ax,interrupt
    mov es,ax
    mov bx,200H
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,5
    mov ah,3
    mov al,1
    int 13H

    ; 调用结束中断
    mov ax,4c00H
    int 21H
code ends

;================================================
;   配置信息
;       配置软盘存放地址： 第2扇区
;       配置内存存放地址： 2000:0
;================================================
config segment
    subindex         db 0
    subsign          db 0
    pagesel          db 0
    init_addr        dw 7c00H,00H
    install_addr     dw 00H,2400H
    interrupt_addr   dw 00H,2800H
    interrupt_inst   dw 200H,00H
    interrupt_9      dw 4*9,0
    subprog          dw sub1,sub2,sub3,sub4
    time_lc          dw 12*160,32*2 
    section1         db '1) reset pc',0
    section2         db '2) start system',0
    section3         db '3) clock',0
    section4         db '4) set clock',0
    sections         dw section1,section2,section3,section4
    rows             db 11,12,13,14
    columns          db 10,10,10,10
    time             db 9,8,7,4,2,0
    timebuff         db 0,1,3,4,6,7,9,10,12,13,15,16

config ends


;================================================
;   内存加载
;       将配置信息，主程序以及中断代码加载到内存中
;       将配置信息加载到2000:0处，后面的加载地址从配置信息中读取
;================================================
task segment
assume cs:task
org 7c00H
    jmp short task_
    config_address dw 00H,2000H

task_:
    ; 将第二扇区的配置信息加载到内存中
    mov ax,config_address[2]
    mov es,ax
    mov bx,config_address[0]
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,2
    mov ah,2
    mov al,1
    int 13H

    ; 根据配置信息初始化变量
    mov ax,config_address[2]
    mov ds,ax

    ; 主程序代码加载
    mov ax,ds:[install_addr+2]
    mov es,ax
    mov bx,ds:[install_addr]
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,3
    mov ah,2
    mov al,2
    int 13H

    ; 中断程序加载
    mov ax,ds:[interrupt_addr+2]
    mov es,ax
    mov bx,ds:[interrupt_addr]
    mov dl,0
    mov dh,0
    mov ch,0
    mov cl,5
    mov ah,2
    mov al,1
    int 13H

    ; 跳转到任务程序开始执行
    jmp dword ptr ds:[install_addr]

task ends


;================================================
;   主程序
;       主程序显示界面，通过判断不同的标志位，调用不同子程序
;   标志位存储在配置信息段
;   <一个小问题，配置信息的地址还是要写上，不然无法获取>
;   <所以要修改的话，还是会修改多个地方，直接写还是会有问题>
;================================================
install segment
assume cs:install
    jmp short taskstart
    config_address_inst  dw 00H,2000H
    stack                dw 32 dup (0)

taskstart:
    ; 初始化
    mov ax,cs
    mov ss,ax
    mov sp,offset taskstart


    ; 中断安装
    ; 首先要根据配置信息，初始化变量
    mov ax,config_address_inst[2]
    mov ds,ax
    mov ax,ds:[interrupt_inst+2]
    mov es,ax
    mov di,ds:[interrupt_inst]
    
    mov bx,ds:[interrupt_addr+2]
    mov si,ds:[interrupt_addr]
    mov ds,bx

    mov cx,offset int7cend - offset int7c
    cld
    rep movsb

    ; 配置原int9的中断地址
    mov ax,config_address_inst[2]
    mov ds,ax
    mov bx,ds:[interrupt_9]
    mov ax,ds:[interrupt_inst+2]
    mov es,ax
    mov bp,ds:[interrupt_inst]
    mov ax,ds:[interrupt_9+2]
    mov ds,ax
    push ds:[bx]
    pop es:[bp+2]
    push ds:[bx+2]
    pop es:[bp+4]

    ; 配置新的int9地址,这时候不允许键盘中断
    cli
    mov word ptr ds:[bx],bp
    mov word ptr ds:[bx+2],es
    sti

    ; 进入主循环
    jmp main

main:
    mov ax,config_address_inst[2]
    mov ds,ax
    call show_mainpage
forever:
    cmp byte ptr ds:[subsign],0
    je nosub
    mov byte ptr ds:[subsign],0
    push bx
    mov bl, ds:[subindex]
    mov bh,0
    call word ptr ds:[subprog+bx]
    pop bx
    call show_mainpage
nosub:
    call delay
    jmp short forever

; reset pc 的逻辑代码
; 将 CS:IP 设置为ffff:0
sub1:
    push ax

    mov ax,0ffffH
    push ax
    mov ax,00H
    push ax
    retf
    pop ax
    ret

;-----------------------------------------------------------
; start system 的逻辑代码
; 实现思路如下：
;   (1) 将c盘的第0面，第0磁道，第1扇区的512字节加载到内存中,加载地址为：
;   (2) 然后将CS:IP 设置为加载地址0:8c00H
;
; 采用int13中断，硬盘读写程序
; 参数：
;   ah: int13功能号（2表示读，3表示写）
;   al: 读取的扇区数
;   dl: 驱动器号，软盘从0开始，硬盘从80开始
;   dh: 磁头号，每个面使用一个磁头读写
;   ch: 磁道号
;   cl: 扇区号
;   es:bx 内存区
; 返回参数
;   操作成功：ah=0,al=扇区数
;   操作失败：ah=出错代码

sub2:
    push ax
    push bx
    push cx
    push es
    mov ax,0
    mov es,ax
    mov bx,7c00H
    ; 驱动器号为80H，c盘
    mov dl,80H
    mov dh,0
    mov ch,0
    mov cl,1
    ; 功能选择
    mov ah,2
    mov al,1
    int 13H
    ; 错误处理
    cmp ah,0
    jne sub2ret
    mov ax,00H
    push ax
    mov ax,7c00H
    push ax
    retf
sub2ret:
    pop es
    pop cx
    pop bx
    pop ax
    ret

; clock 的逻辑代码
sub3:
    call clscreen
sub3s:
    call show_t
    call delay
    cmp byte ptr ds:[pagesel],0
    je sub3ret
    jmp sub3s
sub3ret:
    ret


; set clock 的逻辑代码
; 实现思路如下：
;   (1) 清屏幕
;   (2) 
;
;
;
sub4:
    nop
    ret

; 显示主界面
show_mainpage:
    call clscreen
    push ds
    push bx
    push cx
    push di
    push si

    mov ax,config_address_inst[2]
    mov ds,ax
    mov bx,0
    mov di,0
    mov cx,4
sects:
    mov si,ds:[sections+bx]
    mov dh,ds:[rows+di]
    mov dl,ds:[columns+di]
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


; 显示时间子程序 
show_t:
    push ax
    push bx
    push cx
    push si
    push bp
    push ds

    mov ax,config_address_inst[2]
    mov ds,ax
    mov bp,ds:[time_lc]
    add bp,ds:[time_lc+2]
    mov bx,0
    mov cx,6
    mov si,0

show_time:
    push cx
    mov al,ds:[time+bx]
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

    pop ds
    pop bp
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
    mov byte ptr es:[bp+si],ah
    mov byte ptr es:[bp+si],al
    pop es
    pop bx
    ret 

show_sign:
    push bx
    push es
    mov bx, 0b800H
    mov es,bx
    mov byte ptr es:[bp+si],dl
    pop es
    pop bx
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

install ends

;================================================
;   中断程序
;       重写键盘中断程序，对应的页面更改相应的标记位
;================================================
interrupt segment
assume cs:interrupt
org 200H
int7c:
    jmp short int7cstart
    int9                    dw 0,0
    config_address_inter    dw 00H,2000H
    table                   dw sub0set,sub1set,sub2set,sub3set,sub4set
    mainpage                dw first_page,second_page,third_page,forth_page
int7cstart:
    push ax
    push bx
    push dx
    push ds

    ; 读取键盘扫描码
    in al,60H

    ; 调用int9键盘中断
    pushf
    call dword ptr int9

    ; 取出配置信息的段地址，放到ds中
    mov bx,config_address_inter[2]
    mov ds,bx
    mov bl,ds:[pagesel]
    cmp bl,4
    ja interrupt_exit
    mov bh,0
    add bx,bx
    call word ptr table[bx]
interrupt_exit:
    pop ds
    pop dx
    pop bx
    pop ax
    iret

; 主页面
sub0set:
    ; 判断是否是数字1~4,其扫描码是2，3，4，5
    cmp al,5
    ja sub0ret
    cmp al,2
    jb sub0ret
    mov bl,al
    sub bl,2
    mov bh,0
    add bx,bx
    call word ptr mainpage[bx]

sub0ret:
    ret

; 对应每个选项卡，执行对应的配置
first_page:
    mov ds:[pagesel],1
    mov ds:[subindex],0
    mov ds:[subsign],1
    ret
second_page:
    mov ds:[pagesel],2
    mov ds:[subindex],2
    mov ds:[subsign],1
    ret
third_page:
    mov ds:[pagesel],3
    mov ds:[subindex],4
    mov ds:[subsign],1
    ret
forth_page:
    mov ds:[pagesel],4
    mov ds:[subindex],6
    mov ds:[subsign],1
    ret

; 重启计算机选项
sub1set:
    ret

; 引导现有操作系统
sub2set:
    ret

; 时间显示
sub3set:
    push es
    push bx
    push cx

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
    mov bx,ds:[time_lc]
    add bx,ds:[time_lc+2]
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
    ret

; 设置时间
sub4set:
    ret

int7cend:
    nop

interrupt ends
end start
