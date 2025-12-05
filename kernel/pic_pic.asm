; pic_pic.asm - PIC remap
BITS 64
global pic_remap
pic_remap:
    ; Implement standard PIC remap sequence (I/O ports)
    ; Use outb via io wrappers
    mov al, 0x11
    out 0x20, al
    out 0xA0, al
    mov al, 0x20
    out 0x21, al
    mov al, 0x28
    out 0xA1, al
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al
    mov al, 0x01
    out 0x21, al
    out 0xA1, al
    ret