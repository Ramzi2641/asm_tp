; asm04.s
; Read an integer from stdin.
; Exit 0 if even, 1 if odd, 2 if input is invalid.

section .bss
    buffer resb 64

section .text
    global _start

_start:
    ; read(0, buffer, 64)
    xor     eax, eax
    xor     edi, edi
    lea     rsi, [rel buffer]
    mov     edx, 64
    syscall

    ; No input or read error
    test    rax, rax
    jle     .invalid

    mov     rcx, rax            ; number of bytes read
    lea     rsi, [rel buffer]
    xor     r8d, r8d            ; number of digits found
    xor     r9d, r9d            ; last digit

    ; Accept an optional + or - sign
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

    ; End of line
    cmp     al, 10              ; '\n'
    je      .check_result
    cmp     al, 13              ; '\r'
    je      .check_result

    ; Character must be between '0' and '9'
    cmp     al, '0'
    jb      .invalid
    cmp     al, '9'
    ja      .invalid

    sub     al, '0'
    mov     r9b, al             ; remember the last digit
    inc     r8d                 ; at least one digit was found

    inc     rsi
    dec     rcx
    jmp     .parse

.check_result:
    test    r8d, r8d
    jz      .invalid

    ; The parity of the number is the parity of its last digit
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
    mov     eax, 60             ; sys_exit
    syscall
