; Add two numbers passed as arguments and print the result.
;
; Examples:
;   ./asm06 10 15    -> 25
;   ./asm06 999 1    -> 1000
;   ./asm06 -5 2     -> -3

section .bss
    buffer resb 32

section .text
    global _start

_start:
    ; Initial stack:
    ; [rsp]      = argc
    ; [rsp + 8]  = argv[0]
    ; [rsp + 16] = argv[1]
    ; [rsp + 24] = argv[2]

    cmp     qword [rsp], 3
    jb      error

    ; Convert argv[1] to an integer
    mov     rdi, [rsp + 16]
    call    parse_int
    mov     r12, rax

    ; Convert argv[2] to an integer
    mov     rdi, [rsp + 24]
    call    parse_int

    ; Add both numbers
    add     rax, r12

    ; Keep the result in r10
    mov     r10, rax

    ; r9b indicates whether the result is negative
    xor     r9, r9
    test    r10, r10
    jns     .absolute_ready

    mov     r9b, 1
    neg     r10

.absolute_ready:
    ; Start at the end of the buffer
    lea     rsi, [rel buffer + 31]

    ; Add a newline after the number
    mov     byte [rsi], 10
    mov     rcx, 1

    mov     rax, r10
    mov     rbx, 10

    ; Special case for zero
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
    ; write(1, rsi, rcx)
    mov     rax, 1
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall


; ------------------------------------------------------------
; parse_int
; Input:  rdi = address of a null-terminated string
; Output: rax = signed integer
; ------------------------------------------------------------
parse_int:
    xor     rax, rax
    mov     r8, 1               ; sign: 1 or -1
    xor     r9, r9              ; number of digits

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
    ; Reject an empty argument or an argument containing only a sign
    test    r9, r9
    jz      error

    cmp     r8, 1
    je      .return

    neg     rax

.return:
    ret


error:
    ; Invalid or missing argument: exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall
