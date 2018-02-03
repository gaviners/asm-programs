assume cs:code,ds:data,ss:stack

stack segment
    db 40H dup(0)
stack ends

data segment
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'

    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800
data ends

table segment
    db 21 dup('00000000','00000000','00000000','00000000')
table ends



code segment 

start:
    mov ax,stack
    mov ss,ax
    mov sp,40H
    mov bx,data
    mov ds,bx
    mov bx,table
    mov es,bx

    ; 清屏
    push es
    mov di,0
    mov bx,0B800H
    mov es,bx
    mov cx,2000
cls:
    mov byte ptr es:[di],' '
    mov byte ptr es:[di+1],0
    add di,2
    loop cls
    pop es

    ; 先将年份存放到对应的位置，并且末尾加上0
    mov cx,21
    mov bx,0
    mov si,0


year:
    mov ax,[bx]
    mov es:[si],ax
    mov ax,[bx+2]
    mov es:[si+2],ax
    mov byte ptr es:[si+4],0
    add bx,4
    add si,20H
    loop year
    ; 先将收入，人数进行字符串转换，然后放到对应的位置上
    ; 然后将人均收入计算出来，转换为字符串，放到对应的位置上
    ; 可以同时进行这三个操作
    ; 使用es作为存储地址，bp作为初始偏移量
    ; cx: 循环控制
    ; bx: data 数据段年份索引
    ; di: data 数据段人数索引
    ; bp: table数据段索引，并且在转换程序中作为参数使用
    ;
    mov bx,0
    mov cx,21
    mov di,0
    mov bp,8
income:
    ; 转换收入为字符串并存储
    mov ax,[bx+84]
    mov dx,[bx+86]
    call dtoc
    ; 人数存储索引更新
    add bp,8
    ; 转换人数为字符串并存储
    mov ax,[di+168]
    mov dx,0
    call dtoc
    ; 人均收入索引值更新
    add bp,8
    ; 计算人均收入
    push cx
    mov ax,[bx+84]
    mov dx,[bx+86]
    mov cx,[di+168]
    call divdw
    call dtoc
    pop cx
    add bp,16
    add bx,4
    add di,2
    loop income

    ; 上面已经将带显示的数据存储到table中，下面来显示到屏幕上
    ; 因为调试模式会将屏幕向上滚动4行，所以行地址加4处理，能够看到全部的数据
    ; 更改显示字符串的代码，使用bp控制偏移量
    ; ds:bp 显示字符串的初始地址
    ; dh: 行
    ; dl: 列
;------------------------------
    ;mov dh,8
    ;mov dl,3
    ;mov cl,2
    ;mov bp,0
    ;mov ax,table
    ;mov ds,ax
    ;call show_str
    ;mov dl,23
    ;mov bp,8
    ;call show_str
    ;mov dl,43
    ;mov bp,16
    ;call show_str
;------------------------------
    push ax
    push bx
    push cx
    push dx
    push ds
    push bp
    
    mov cx,21
    mov ax,table
    mov ds,ax
    mov dh,5
    mov dl,1
    mov bl,2
    mov bp,0
show:
    push cx

    mov cx,4
    ; 针对每一行显示
line:
    push cx
    mov cl,bl
    call show_str
    add dl,20
    add bp,8
    pop cx
    loop line

    mov dl,1
    inc dh
    pop cx
    loop show

    pop bp
    pop ds
    pop ds
    pop cx
    pop bx
    pop ax
;
;    
    ;mov ax,12666
    ;mov si,0
    ;call dtoc
    ;; 将上面的字符串显示在屏幕上，8行，3列，属性为2
    ;mov dh,8
    ;mov dl,3
    ;mov cl,2
    ;call show_str
    mov ax,4c00H
    int 21H

dtoc:
    ; 先保存子程序将要用到的寄存器的值
    push cx
    push dx
    push si
    ; 使用si作为存储的偏移量，初始化
    mov si,0
    ; 为了能得到顺序的数字，需要借助栈，先存储一个0
    push si
trans:
    mov cx,10
    call divdw
    jcxz letter_check_ax
    jmp short number
letter_check_ax:
    mov cx,ax
    jcxz letter_check_dx
    mov cx,0
    jmp short number
letter_check_dx:
    mov cx,dx
    jcxz last_letter
    mov cx,0
    jmp short number
number:
    add cx,30H
    push cx
    inc si
    jmp short trans
last_letter:
    mov si,0
    ; 上面将数字存放到栈中，下面从栈中弹出，存到对应的存储位置上
store:
    pop cx
    jcxz re
    mov es:[bp+si],cl
    inc si
    jmp short store
re:
    mov byte ptr es:[bp+si],0
    pop si
    pop dx
    pop cx
    ret


show_str:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    mov ax,0B800H
    mov es,ax
    ; 索引从0开始，先减去1
    ; 计算行的偏移量，赋值到bx
    dec dh
    mov al,dh
    mov bl,0a0H
    mul bl
    mov bx,ax
    ; 计算列的偏移量,放到di中
    dec dl
    add dl,dl
    mov ah,0
    mov al,dl
    mov di,ax
    ; 将属性放到dl中
    mov dl,cl
    mov si,0
s:
    mov ch,0
    mov cl,ds:[bp+si]
    jcxz zero
    mov es:[bx+di],cl
    mov es:[bx+di+1],dl
    inc si
    add di,2
    jmp short s

zero:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

divdw:
    ; 被除数：
    ;     高位：dx
    ;     低位：ax
    ; 除数：
    ;     cx
    ; 商：
    ;     高位：dx
    ;     低位：ax
    ; 余数 cx
    ;
    ; 需要使用bx，先将值存储起来
    push bx
    ; 将低16位存储起来
    push ax
    ; 进行高位运算
    mov ax,dx
    mov dx,0
    div cx
    pop bx
    ; 将高位商存储起来
    push ax
    ; 进行低位运算
    mov ax,bx
    div cx
    mov cx,dx
    pop dx
    pop bx
    ret
code ends

end start 