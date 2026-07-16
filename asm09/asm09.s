; Convert a decimal integer to:
;   hexadecimal by default
;   binary with the -b flag
;
; Examples:
;   ./asm09 15       -> F
;   ./asm09 -b 15    -> 1111
;   ./asm09 255      -> FF
;   ./asm09 0        -> 0
;   ./asm09 -b 8     -> 1000

section .bss
    buffer resb 66            ; 64 binary digits + newline + safety byte

section .text
    global _start

_start:
    mov     rax, [rsp]         ; argc

    cmp     rax, 2
    je      .hexadecimal

    cmp     rax, 3
    je      .check_binary_flag

    jmp     .error

.hexadecimal:
    mov     rsi, [rsp + 16]    ; argv[1]
    mov     r13, 16            ; output base
    jmp     .parse_number

.check_binary_flag:
    mov     rdi, [rsp + 16]    ; argv[1]

    ; Check that argv[1] is exactly "-b"
    cmp     byte [rdi], '-'
    jne     .error

    cmp     byte [rdi + 1], 'b'
    jne     .error

    cmp     byte [rdi + 2], 0
    jne     .error

    mov     rsi, [rsp + 24]    ; argv[2]
    mov     r13, 2             ; output base

.parse_number:
    xor     rax, rax           ; parsed number
    xor     rcx, rcx           ; digit counter

.parse_loop:
    movzx   r8d, byte [rsi]

    test    r8b, r8b
    jz      .parse_done

    cmp     r8b, '0'
    jb      .error

    cmp     r8b, '9'
    ja      .error

    sub     r8b, '0'

    ; number = number * 10
    mov     r9, 10
    mul     r9                 ; RDX:RAX = RAX × 10

    ; Reject unsigned overflow
    test    rdx, rdx
    jnz     .error

    ; number += digit
    movzx   r8, r8b
    add     rax, r8
    jc      .error

    inc     rcx
    inc     rsi
    jmp     .parse_loop

.parse_done:
    ; Reject an empty argument
    test    rcx, rcx
    jz      .error

    ; Begin writing from the end of the buffer
    lea     rsi, [rel buffer + 65]

    mov     byte [rsi], 10     ; newline
    mov     rcx, 1             ; output length

    ; Special case for zero
    test    rax, rax
    jnz     .conversion_loop

    dec     rsi
    mov     byte [rsi], '0'
    inc     rcx
    jmp     .print

.conversion_loop:
    xor     rdx, rdx
    div     r13                ; quotient in RAX, remainder in RDX

    cmp     dl, 9
    jbe     .decimal_digit

    ; Values 10–15 become A–F
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
    ; write(stdout, rsi, length)
    mov     eax, 1             ; sys_write
    mov     edi, 1             ; stdout
    mov     rdx, rcx
    syscall

    ; exit(0)
    mov     eax, 60            ; sys_exit
    xor     edi, edi
    syscall

.error:
    ; exit(1)
    mov     eax, 60
    mov     edi, 1
    syscall
