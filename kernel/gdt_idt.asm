; gdt_idt.asm - minimal GDT and IDT setup
BITS 64
global kinit

kinit:
    ; Setup GDT
    lgdt [gdt_descriptor]
    ; Load data selectors (we use flat model)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    ; Setup IDT with simple handlers
    lidt [idt_descriptor]
    ; Remap PIC and enable interrupts
    call pic_remap
    sti
    ret

SECTION .data
gdt_start:
    ; null descriptor
    dq 0
    ; kernel code (base 0, limit 0xfffff, 0x9A)
    dq 0x00AF9A000000FFFF
    ; kernel data (0x92)
    dq 0x00AF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dq gdt_start

SECTION .bss
idt_table: times 256 dq 0
idt_descriptor:  dw 256*16-1
                dq idt_table