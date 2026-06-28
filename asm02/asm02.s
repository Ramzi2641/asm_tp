global main

section .data
    number: db "1337", 0xA
    NUMBER_LEN: equ $-number

section .bss
    buffer resb 10

section .text
main:
    ; Read from standard input
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 10
    syscall
    
    ; Compare buffer with "42\n"
    cmp byte [buffer], '4'
    jne  _notGiven42

    cmp byte [buffer + 1], '2'
    jne  _notGiven42

    cmp byte [buffer + 2], 0xA
    jne  _notGiven42

_given42:
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

_notGiven42:
    ; Exists with exit code 1
    mov rax, 0x3C
    mov rdi, 1
    syscall
