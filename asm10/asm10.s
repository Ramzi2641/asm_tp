
section .bss
    buffer resb 32

section .text
global _start

_start:

    mov rax, [rsp]
    cmp rax, 4
    jne exit_error

    mov rdi, [rsp+16]
    call atoi
    mov r8, rax

    mov rdi, [rsp+24]
    call atoi
    mov r9, rax

    mov rdi, [rsp+32]
    call atoi
    mov r10, rax

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

atoi:
    push rbx
    mov rbx, rdi
    xor rcx, rcx

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

print_int:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rbx, buffer
    add rbx, 31
    mov byte [rbx], 0

    xor rcx, rcx
    mov r11, 0

    cmp rax, 0
    jge .convert
    mov r11, 1
    neg rax

.convert:
    mov r9, 10
.divloop:
    xor rdx, rdx
    div r9
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

print_newline:
    push rax
    push rdi
    push rsi
    push rdx

    mov byte [buffer], 10
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

exit_program:
    mov rax, 60
    syscall
