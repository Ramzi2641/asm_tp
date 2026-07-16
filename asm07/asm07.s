; Read a positive integer from stdin.
; Exit 0 if the number is prime.
; Exit 1 if the number is not prime or the input is invalid.

section .bss
    buffer resb 32

section .text
    global _start

_start:
    ; read(stdin, buffer, 32)
    mov     rax, 0              ; sys_read
    mov     rdi, 0              ; stdin
    lea     rsi, [rel buffer]
    mov     rdx, 32
    syscall

    ; Read error or empty input
    test    rax, rax
    jle     .not_prime

    mov     rcx, rax            ; number of bytes read
    lea     rsi, [rel buffer]

    xor     rbx, rbx            ; parsed number
    xor     r8, r8              ; number of digits read

.parse_loop:
    test    rcx, rcx
    jz      .parse_done

    movzx   rdx, byte [rsi]

    ; Stop at newline
    cmp     dl, 10              ; '\n'
    je      .parse_done

    cmp     dl, 13              ; '\r'
    je      .parse_done

    ; Check that the character is a digit
    cmp     dl, '0'
    jb      .not_prime

    cmp     dl, '9'
    ja      .not_prime

    ; number = number * 10 + digit
    imul    rbx, rbx, 10
    jo      .not_prime          ; integer overflow

    sub     rdx, '0'
    add     rbx, rdx
    jo      .not_prime

    inc     r8
    inc     rsi
    dec     rcx
    jmp     .parse_loop

.parse_done:
    ; Reject input containing no digits
    test    r8, r8
    jz      .not_prime

    ; Numbers below 2 are not prime
    cmp     rbx, 2
    jb      .not_prime

    ; 2 is prime
    je      .prime

    ; Any other even number is not prime
    test    rbx, 1
    jz      .not_prime

    ; Test odd divisors starting from 3
    mov     rcx, 3

.test_divisor:
    ; Stop when divisor² > number
    mov     rax, rcx
    mul     rcx                 ; rdx:rax = rcx * rcx

    ; Overflow means divisor² is larger than the number
    test    rdx, rdx
    jnz     .prime

    cmp     rax, rbx
    ja      .prime

    ; Calculate number % divisor
    mov     rax, rbx
    xor     rdx, rdx
    div     rcx

    ; A remainder of zero means the number is divisible
    test    rdx, rdx
    jz      .not_prime

    add     rcx, 2
    jmp     .test_divisor

.prime:
    mov     rax, 60             ; sys_exit
    mov     rdi, 0
    syscall

.not_prime:
    mov     rax, 60             ; sys_exit
    mov     rdi, 1
    syscall
