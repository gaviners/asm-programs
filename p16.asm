assume cs:code,ss:stack,ds:data,es:table

stack segment
    dw 8 dup(0)
stack ends
    
data segment
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'

    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

    dw 3,7,9,13,28,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,11430,15257,17800
data ends

table segment
    db 21 dup('1234',' ','1234',' ','12',' ','12',' ')
table ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,10H
    mov ax,data 
    mov ds,ax
    mov ax,table
    mov es,ax

    mov cx,21
    mov bx,0
    mov si,0
    mov di,168
s:
    mov ax,[si]
    mov es:[bx],ax
    mov ax,[si+2]
    mov es:[bx+2],ax

    mov ax,[si+84]
    mov es:[bx+5],ax
    mov ax,[si+86]
    mov es:[bx+7],ax

    mov ax,[di]
    mov es:[bx+10],ax

    mov ax,[si+84]
    mov dx,[si+86]
    div word ptr [di]
    mov es:[bx+13],ax

    add si,4
    add di,2
    add bx,16
    loop s

    mov ax,4c00H
    int 21H
code ends


end start