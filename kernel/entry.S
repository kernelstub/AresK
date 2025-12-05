/* entry.S - C-callable entry point glue */
    .intel_syntax noprefix
    .global kernel_entry
kernel_entry:
    push rbp
    mov rbp, rsp
    ; initialize data segment registers to 0
    xor rax, rax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    ; call C runtime init
    call kinit
    call kmain
    ; if kmain returns, halt
.spin:
    hlt
    jmp .spin