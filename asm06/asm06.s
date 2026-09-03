
section .bss
    buffer resb 32

section .text
    global _start

_start:
    cmp     qword [rsp], 3
    jb      error

    mov     rdi, [rsp + 16]
    call    parse_int
    mov     r12, rax

    mov     rdi, [rsp + 24]
    call    parse_int

    add     rax, r12

    mov     r10, rax

    xor     r9, r9
    test    r10, r10
    jns     .absolute_ready

    mov     r9b, 1
    neg     r10

.absolute_ready:
    lea     rsi, [rel buffer + 31]

    mov     byte [rsi], 10
    mov     rcx, 1

    mov     rax, r10
    mov     rbx, 10

    test    rax, rax
    jnz     .convert_loop

    dec     rsi
    mov     byte [rsi], '0'
    inc     rcx
    jmp     .add_sign

.convert_loop:
    xor     rdx, rdx
    div     rbx

    add     dl, '0'
    dec     rsi
    mov     [rsi], dl
    inc     rcx

    test    rax, rax
    jnz     .convert_loop

.add_sign:
    test    r9b, r9b
    jz      .print

    dec     rsi
    mov     byte [rsi], '-'
    inc     rcx

.print:
    mov     rax, 1
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    mov     rax, 60
    xor     rdi, rdi
    syscall


parse_int:
    xor     rax, rax
    mov     r8, 1
    xor     r9, r9

    movzx   rcx, byte [rdi]

    cmp     cl, '-'
    jne     .check_plus

    mov     r8, -1
    inc     rdi
    jmp     .parse_loop

.check_plus:
    cmp     cl, '+'
    jne     .parse_loop
    inc     rdi

.parse_loop:
    movzx   rcx, byte [rdi]

    test    cl, cl
    jz      .parse_done

    cmp     cl, '0'
    jb      error

    cmp     cl, '9'
    ja      error

    imul    rax, rax, 10
    sub     rcx, '0'
    add     rax, rcx

    inc     r9
    inc     rdi
    jmp     .parse_loop

.parse_done:
    test    r9, r9
    jz      error

    cmp     r8, 1
    je      .return

    neg     rax

.return:
    ret


error:
    mov     rax, 60
    mov     rdi, 1
    syscall
