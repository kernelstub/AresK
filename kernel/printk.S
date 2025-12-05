; printk.S - simple printf-like function (very small)
BITS 64
global kprintf
extern kputs

kprintf:
    ; rdi = fmt, ...
    ; Very small implementation: only supports %s and %d
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    mov rsi, rdi ; pointer to fmt
.next:
    mov al, [rsi]
    test al, al
    jz .done
    cmp al, '%'
    je .percent
    ; normal char path
    movzx edi, al
    mov esi, 0x07
    call kputc
    inc rsi
    jmp .next
.percent:
    inc rsi
    mov al, [rsi]
    cmp al, 's'
    je .str
    cmp al, 'd'
    je .dec
    jmp .next
.str:
    ; load next arg from stack (first arg at [rbp+16]) crude but works
    mov rax, [rbp+16]
    mov rdi, rax
    call kputs
    add qword [rbp+16], 8
    inc rsi
    jmp .next
.dec:
    ; not fully implemented - placeholder
    inc rsi
    jmp .next
.done:
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret