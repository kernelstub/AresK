; start.asm - 64-bit entry stub (multiboot-friendly)
BITS 64
global start
section .text

start:
    ; We expect GRUB to load this in 64-bit mode; set up stack and call kernel entry
    cli
    xor rbp, rbp
    mov rsp, stack_top
    call kernel_entry
.halt:
    hlt
    jmp .halt

section .bss
align 16
stack: resb 16384
stack_top: