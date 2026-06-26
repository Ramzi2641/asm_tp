global main

section .data
    number: db "1337", 10
    NUMBER_LEN: equ $-number

section .text
main:
    ; Write "1337" to the standard output
    mov rax, 1
    mov rdi, 1
    mov rsi, number
    mov rdx, NUMBER_LEN
    syscall

    ; Exists with exit code 0
    mov rax, 0x3C
    mov rdi, 0
    syscall

