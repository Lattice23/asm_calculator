  section .data
    prompt_1  db    "Enter a number: "
    size_1   equ    $-prompt_1

  prompt_2 db     "Enter the Operation: ",0x0A,0x2B,0x0A,0x2D,0x0A,0x2A,0x0A,0x2F,0x0A,"here: "
    size_2  equ     $-prompt_2
    
    prompt_3  db    "The result is: "
    size_3  equ     $-prompt_3
    
  _default db "Enter a valid operatror: + - * /"
   def_size equ $-_default

  section .bss
    num1      resb 4
    num2      resb 4
    temp      resb 4
    sum       resb 4
    operatror resb 4
    total     resb 4

  section .text
    global _start

    _start:
      ; ask for numbers
      call   _Ask_Input
      mov    [num1],rax
      call   _Ask_Input
      mov    [num2],rax
      
      ; fill in numbers
      
      ; Get operatror
      call   _Ask_Operation
      mov    [sum],rax
      jmp    int_to_str
      

  _Ask_Operation:
      ; Ask Operation
      mov     rax,0x1                     ; setup up sys_write
      mov     rdi,0x1                     ; set FD 1 = output
      mov     rsi,prompt_2                ; set the output to prompt_2
      mov     rdx,size_2                  ; set sizeof prompt_2 
      syscall 
    
      ; Read Input
      mov     rax,0
      mov     rdi,0         ; Set FD 0 = input
      mov     rsi,operatror ; Set output to prompt_1
      mov     rdx,4
      syscall
      
      mov    ebx,[num1]
      mov    rcx,[num2]

      ;if statment depending on operatror
      mov    rax,0x0a2b
      cmp    rax,[operatror]   ; check for +
      je     _add

      mov    rax,0x0a2d
      cmp    rax,[operatror]   ; check for -
      je     _sub


      mov    rax,0x0a2a
      cmp    rax,[operatror]   ; check for *
      je     _mul

      mov    rax,0x0a2F
      cmp    rax,[operatror]   ; check for /
      je     _div

  _defualt:
      mov     rax,0x1                     ; setup up sys_write
      mov     rdi,0x1                     ; set FD 1 = output
      mov     rsi,_defualt                ; set the output to default
      mov     rdx,def_size                ; set sizeof default
      syscall
      jmp _Ask_Operation
      
  _add:
    add    rcx,rbx
    mov    rax,rcx
    ret

  _sub:
    sub    rbx,rcx
    mov    rax,rbx
    ret

  _mul:
    mov    rax,rcx
    mul    rbx
    ret

  _div:
    mov    rax,rbx
    xor    rdx,rdx
    div    rcx
    mov    rax,rbx
    ret


  _Ask_Input:
      ; Start off with prompting user
      mov     rax,0x1                     ; Setup sys_write call
      mov     rdi,0x1                     ; Set FD 1 = output
      mov     rsi,prompt_1                ; Set the output to prompt_1
      mov     rdx,size_1                  ; Set sizeof prompt_1 
      syscall

      ; Read Input
      mov     rax,0
      mov     rdi,0                       ; Set FD 0 = input
      mov     rsi,temp                    ; Set output to prompt_1
      mov     rdx,4
      syscall
    
      mov rsi, temp      ; Pointer to input string
      xor rax, rax       ; Clear RAX (result)

  convert_loop:
    movzx rcx, byte [rsi]   ; Load one character
    cmp cl, 0x0A            ; Check for newline '\n'
    je _return              ; Stop if newline

    sub cl, '0'            ; convert ascii to number
    imul rax, rax, 10      ; multiply current result by 10
    add rax, rcx           ; add new digit
    inc rsi                ; move to next character
    jmp convert_loop       ; repeat

 _return:
      ret

  int_to_str:
    mov rcx, 10        ; Divisor base 10
    mov rdi, sum

_convert_loop2:
    dec rdi
    mov rdx, 0
    div rcx            ; rax = rax / 10, rdx = rax % 10
    add dl, '0'        ; convert remainder to ASCII
    mov [rdi], dl      ; store character
    test rax, rax      ; check if RAX is zero
    jnz _convert_loop2  ; Repeat if not

    mov [sum], rdi       ; Return pointer to string
  
  xor rbx,rbx
  xor rax,rax

  _Exit:
      sub rax,rbx
      mov [total],rax
      mov     rax,0x1                   ; setup up sys_write
      mov     rdi,0x1                   ; set FD 1 = output
      mov     rsi,prompt_3              ; set the output to prompt_3
      mov     rdx,size_3                ; set sizeof the prompt_3
      syscall

      mov     rax,0x1                   ; setup up sys_write
      mov     rdi,0x1                   ; set FD 1 = output
      mov     rcx,[sum]
      mov     rsi,rcx                   ; set the output to sum
      mov     rdx,size_1                ; set sizeof the    sum
      syscall

      mov     rax,0x3C
      mov     rdi,5
      syscall
      
