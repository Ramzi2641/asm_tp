
section .bss
    buffer resb 66

section .text
    global _start

_start:
    mov     rax, [rsp]

    cmp     rax, 2
    je      .hexadecimal

    cmp     rax, 3
    je      .check_binary_flag

    jmp     .error

.hexadecimal:
    mov     rsi, [rsp + 16]
    mov     r13, 16
    jmp     .parse_number

.check_binary_flag:
    mov     rdi, [rsp + 16]

    cmp     byte [rdi], '-'
    jne     .error

    cmp     byte [rdi + 1], 'b'
    jne     .error

    cmp     byte [rdi + 2], 0
    jne     .error

    mov     rsi, [rsp + 24]
    mov     r13, 2

.parse_number:
    xor     rax, rax
    xor     rcx, rcx

.parse_loop:
    movzx   r8d, byte [rsi]

    test    r8b, r8b
    jz      .parse_done

    cmp     r8b, '0'
    jb      .error

    cmp     r8b, '9'
    ja      .error

    sub     r8b, '0'

    mov     r9, 10
    mul     r9

    test    rdx, rdx
    jnz     .error

    movzx   r8, r8b
    add     rax, r8
    jc      .error

    inc     rcx
    inc     rsi
    jmp     .parse_loop

.parse_done:
    test    rcx, rcx
    jz      .error

    lea     rsi, [rel buffer + 65]

    mov     byte [rsi], 10
    mov     rcx, 1

    test    rax, rax
    jnz     .conversion_loop

    dec     rsi
    mov     byte [rsi], '0'
    inc     rcx
    jmp     .print

.conversion_loop:
    xor     rdx, rdx
    div     r13

    cmp     dl, 9
    jbe     .decimal_digit

    add     dl, 'A' - 10
    jmp     .store_digit

.decimal_digit:
    add     dl, '0'

.store_digit:
    dec     rsi
    mov     [rsi], dl
    inc     rcx

    test    rax, rax
    jnz     .conversion_loop

.print:
    mov     eax, 1
    mov     edi, 1
    mov     rdx, rcx
    syscall

    mov     eax, 60
    xor     edi, edi
    syscall

.error:
    mov     eax, 60
    mov     edi, 1
    syscall
