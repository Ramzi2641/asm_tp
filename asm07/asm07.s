
section .bss
    buffer resb 32

section .text
    global _start

_start:
    mov     rax, 0
    mov     rdi, 0
    lea     rsi, [rel buffer]
    mov     rdx, 32
    syscall

    test    rax, rax
    jle     .not_prime

    mov     rcx, rax
    lea     rsi, [rel buffer]

    xor     rbx, rbx
    xor     r8, r8

.parse_loop:
    test    rcx, rcx
    jz      .parse_done

    movzx   rdx, byte [rsi]

    cmp     dl, 10
    je      .parse_done

    cmp     dl, 13
    je      .parse_done

    cmp     dl, '0'
    jb      .not_prime

    cmp     dl, '9'
    ja      .not_prime

    imul    rbx, rbx, 10
    jo      .not_prime

    sub     rdx, '0'
    add     rbx, rdx
    jo      .not_prime

    inc     r8
    inc     rsi
    dec     rcx
    jmp     .parse_loop

.parse_done:
    test    r8, r8
    jz      .not_prime

    cmp     rbx, 2
    jb      .not_prime

    je      .prime

    test    rbx, 1
    jz      .not_prime

    mov     rcx, 3

.test_divisor:
    mov     rax, rcx
    mul     rcx

    test    rdx, rdx
    jnz     .prime

    cmp     rax, rbx
    ja      .prime

    mov     rax, rbx
    xor     rdx, rdx
    div     rcx

    test    rdx, rdx
    jz      .not_prime

    add     rcx, 2
    jmp     .test_divisor

.prime:
    mov     rax, 60
    mov     rdi, 0
    syscall

.not_prime:
    mov     rax, 60
    mov     rdi, 1
    syscall
