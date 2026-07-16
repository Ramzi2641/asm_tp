; asm05/asm05.s
; Print the string passed as the first argument.

section .data
    newline db 10

section .text
    global _start

_start:
    ; At program start:
    ; [rsp]      = argc
    ; [rsp + 8]  = argv[0]
    ; [rsp + 16] = argv[1]

    mov     rax, [rsp]          ; argc
    cmp     rax, 2
    jb      .missing_argument

    mov     rsi, [rsp + 16]     ; argv[1]
    xor     rdx, rdx            ; string length = 0

.find_length:
    cmp     byte [rsi + rdx], 0
    je      .print_string

    inc     rdx
    jmp     .find_length

.print_string:
    ; write(STDOUT, argv[1], length)
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    syscall

    ; Print '\n'
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; exit(0)
    mov     rax, 60             ; sys_exit
    xor     rdi, rdi
    syscall

.missing_argument:
    ; exit(1) when argv[1] is missing
    mov     rax, 60
    mov     rdi, 1
    syscall
