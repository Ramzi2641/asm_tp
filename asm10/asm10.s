; asm10.s
; Find the maximum of three numbers passed as command-line arguments.
; Prints the result to stdout followed by a newline.

section .bss
    buffer resb 32           ; buffer to hold the printed number

section .text
global _start

_start:
    ; Stack layout at program entry (System V x86-64 ABI):
    ;   [rsp]      = argc
    ;   [rsp+8]    = argv[0]  (program name)
    ;   [rsp+16]   = argv[1]
    ;   [rsp+24]   = argv[2]
    ;   [rsp+32]   = argv[3]

    mov rax, [rsp]
    cmp rax, 4                ; expect exactly 3 arguments (+ program name)
    jne exit_error

    mov rdi, [rsp+16]         ; argv[1]
    call atoi
    mov r8, rax                ; num1

    mov rdi, [rsp+24]         ; argv[2]
    call atoi
    mov r9, rax                ; num2

    mov rdi, [rsp+32]         ; argv[3]
    call atoi
    mov r10, rax                ; num3

    ; --- find max of r8, r9, r10 ---
    mov rax, r8
    cmp r9, rax
    jle .skip1
    mov rax, r9
.skip1:
    cmp r10, rax
    jle .skip2
    mov rax, r10
.skip2:

    call print_int
    call print_newline

    xor rdi, rdi
    call exit_program

exit_error:
    mov rdi, 1
    call exit_program

; ----------------------------------------------------
; atoi: convert null-terminated decimal string to int
; in:  rdi = pointer to string
; out: rax = integer value
; ----------------------------------------------------
atoi:
    push rbx
    mov rbx, rdi
    xor rcx, rcx              ; rcx = 1 if negative

    mov al, [rbx]
    cmp al, '-'
    jne .loop_init
    mov rcx, 1
    inc rbx

.loop_init:
    xor rax, rax
.loop:
    movzx rdx, byte [rbx]
    cmp rdx, 0
    je .done
    cmp rdx, '0'
    jl .done
    cmp rdx, '9'
    jg .done
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rbx
    jmp .loop

.done:
    cmp rcx, 1
    jne .end
    neg rax
.end:
    pop rbx
    ret

; ----------------------------------------------------
; print_int: print integer in rax (decimal) to stdout
; handles negative numbers too
; ----------------------------------------------------
print_int:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rbx, buffer
    add rbx, 31
    mov byte [rbx], 0         ; null terminator (not used by write, just tidy)

    xor rcx, rcx              ; digit counter
    mov r11, 0                ; sign flag

    cmp rax, 0
    jge .convert
    mov r11, 1
    neg rax

.convert:
    mov r9, 10
.divloop:
    xor rdx, rdx
    div r9                    ; rax / 10 -> rax, remainder rdx
    add rdx, '0'
    dec rbx
    mov [rbx], dl
    inc rcx
    cmp rax, 0
    jne .divloop

    cmp r11, 1
    jne .noSign
    dec rbx
    mov byte [rbx], '-'
    inc rcx

.noSign:
    ; write(1, rbx, rcx)
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, rcx
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; ----------------------------------------------------
; print_newline: write a single '\n' to stdout
; ----------------------------------------------------
print_newline:
    push rax
    push rdi
    push rsi
    push rdx

    mov byte [buffer], 10     ; '\n'
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 1
    syscall

    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; ----------------------------------------------------
; exit_program: exit(rdi)
; ----------------------------------------------------
exit_program:
    mov rax, 60                ; sys_exit
    syscall
