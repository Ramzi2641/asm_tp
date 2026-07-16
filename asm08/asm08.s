; Calculate the sum of integers from 1 to N-1.
; N is passed as the first command-line argument.
;
; Examples:
;   ./asm08 5    -> 10
;   ./asm08 10   -> 45
;   ./asm08 100  -> 4950

section .bss
    buffer resb 32

section .text
    global _start

_start:
    ; Initial stack:
    ; [rsp]      = argc
    ; [rsp + 8]  = argv[0]
    ; [rsp + 16] = argv[1]

    cmp     qword [rsp], 2
    jb      .error

    mov     rsi, [rsp + 16]     ; argv[1]
    xor     rbx, rbx            ; N = 0
    xor     r8, r8              ; digit counter

; Convert argv[1] from ASCII to an integer
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
    ; Reject an empty argument
    test    r8, r8
    jz      .error

    ; Calculate 1 + 2 + ... + (N - 1)
    xor     rax, rax            ; sum = 0
    mov     rcx, 1              ; current number = 1

.sum_loop:
    cmp     rcx, rbx
    jae     .convert

    add     rax, rcx
    inc     rcx
    jmp     .sum_loop

; Convert the result in RAX to ASCII
.convert:
    lea     rsi, [rel buffer + 31]

    mov     byte [rsi], 10      ; newline
    mov     rcx, 1              ; output length
    mov     rbx, 10

    test    rax, rax
    jnz     .convert_loop

    ; Special case: result is zero
    dec     rsi
    mov     byte [rsi], '0'
    inc     rcx
    jmp     .print

.convert_loop:
    xor     rdx, rdx
    div     rbx                 ; RAX / 10, remainder in RDX

    add     dl, '0'
    dec     rsi
    mov     [rsi], dl
    inc     rcx

    test    rax, rax
    jnz     .convert_loop

.print:
    ; write(stdout, buffer, length)
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    mov     rdx, rcx
    syscall

    ; exit(0)
    mov     rax, 60             ; sys_exit
    xor     rdi, rdi
    syscall

.error:
    ; Invalid or missing argument
    mov     rax, 60
    mov     rdi, 1
    syscall
