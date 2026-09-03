
section .bss
    buffer resb 32

section .text
    global _start

_start:

    cmp     qword [rsp], 2
    jb      .error

    mov     rsi, [rsp + 16]
    xor     rbx, rbx
    xor     r8, r8

.parse:
    movzx   rax, byte [rsi]

    test    al, al
    jz      .parsed

    cmp     al, '0'
    jb      .error

    cmp     al, '9'
    ja      .error

    imul    rbx, rbx, 10

    sub     rax, '0'
    add     rbx, rax

    inc     r8
    inc     rsi
    jmp     .parse

.parsed:
    test    r8, r8
    jz      .error
    xor     rax, rax
    mov     rcx, 1

.sum_loop:
    cmp     rcx, rbx
    jae     .convert

    add     rax, rcx
    inc     rcx
    jmp     .sum_loop

.convert:
    lea     rsi, [rel buffer + 31]

    mov     byte [rsi], 10
    mov     rcx, 1
    mov     rbx, 10

    test    rax, rax
    jnz     .convert_loop

    dec     rsi
    mov     byte [rsi], '0'
    inc     rcx
    jmp     .print

.convert_loop:
    xor     rdx, rdx
    div     rbx

    add     dl, '0'
    dec     rsi
    mov     [rsi], dl
    inc     rcx

    test    rax, rax
    jnz     .convert_loop

.print:
    mov     rax, 1
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    mov     rax, 60
    xor     rdi, rdi
    syscall

.error:
    mov     rax, 60
    mov     rdi, 1
    syscall
