
section .data
    newline db 10

section .text
    global _start

_start:

    mov     rax, [rsp]
    cmp     rax, 2
    jb      .missing_argument

    mov     rsi, [rsp + 16]
    xor     rdx, rdx

.find_length:
    cmp     byte [rsi + rdx], 0
    je      .print_string

    inc     rdx
    jmp     .find_length

.print_string:
    mov     rax, 1
    mov     rdi, 1
    syscall

    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    mov     rax, 60
    xor     rdi, rdi
    syscall

.missing_argument:
    mov     rax, 60
    mov     rdi, 1
    syscall
