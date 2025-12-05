; vga_text.asm - minimal VGA text console
BITS 64
global kputc, kputs, clear_screen
SECTION .data
vga_base: dq 0xB8000
cursor_pos: dq 0

SECTION .text
kputc:
    ; rdi = character, rsi = attribute
    push rax
    mov rax, [cursor_pos]
    mov rbx, [vga_base]
    mov rcx, rax
    shl rcx, 1
    add rbx, rcx
    mov word [rbx], di
    add qword [cursor_pos], 1
    pop rax
    ret

kputs:
    ; rdi = pointer to string
    push rsi
.loop:
    mov al, [rdi]
    test al, al
    jz .done
    movzx edi, al
    mov esi, 0x07
    call kputc
    inc rdi
    jmp .loop
.done:
    pop rsi
    ret

clear_screen:
    ; simple clear by writing spaces
    mov rcx, 80*25
    mov rdi, 0
.clear_loop:
    push rcx
    mov edi, ' '
    mov esi, 0x07
    call kputc
    pop rcx
    dec rcx
    jnz .clear_loop
    ret