assume cs:code,ds:data



code segment
start:
  mov ax,0    ;3字节
  ;jmp short s ;2字节
  jmp far ptr s1
  ;add ax,1    ;3字节
;s:
  ;inc ax
code ends

data segment

s1:
  mov ax,data
  mov ax,4c00H
  int 21H
data ends

end start