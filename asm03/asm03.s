global _start

section .data
    number: db "1337", 0xA
    NUMBER_LEN: equ $-number

section .bss
    buffer resb 10

section .text
_start:
    ; argc is at [rsp]
    cmp qword [rsp], 2
    jne _notGiven42

    ; argv[1] is at [rsp + 16]
    mov rbx, [rsp + 16]

    ; Compare buffer with "42\n"
    cmp byte [rbx], '4'
    jne  _notGiven42

    cmp byte [rbx + 1], '2'
    jne  _notGiven42

    cmp byte [rbx + 2], 0x0
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
