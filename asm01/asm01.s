global main

section .data
    number: db "1337", 10
    NUMBER_LEN: equ $-number

section .text
main:
    mov rax, 1
    mov rdi, 1
    mov rsi, number
    mov rdx, NUMBER_LEN
    syscall

    mov rax, 0x3C
    mov rdi, 0
    syscall

