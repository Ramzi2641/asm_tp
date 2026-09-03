section .bss
    buffer resb 64

section .text
    global _start

_start:
    xor     eax, eax
    xor     edi, edi
    lea     rsi, [rel buffer]
    mov     edx, 64
    syscall

    test    rax, rax
    jle     .invalid

    mov     rcx, rax
    lea     rsi, [rel buffer]
    xor     r8d, r8d
    xor     r9d, r9d

    mov     al, [rsi]
    cmp     al, '-'
    je      .skip_sign
    cmp     al, '+'
    jne     .parse

.skip_sign:
    inc     rsi
    dec     rcx
    jz      .invalid

.parse:
    test    rcx, rcx
    jz      .check_result

    mov     al, [rsi]

    cmp     al, 10
    je      .check_result
    cmp     al, 13
    je      .check_result

    cmp     al, '0'
    jb      .invalid
    cmp     al, '9'
    ja      .invalid

    sub     al, '0'
    mov     r9b, al
    inc     r8d

    inc     rsi
    dec     rcx
    jmp     .parse

.check_result:
    test    r8d, r8d
    jz      .invalid

    test    r9b, 1
    jnz     .odd

.even:
    mov     edi, 0
    jmp     .exit

.odd:
    mov     edi, 1
    jmp     .exit

.invalid:
    mov     edi, 2

.exit:
    mov     eax, 60
    syscall
