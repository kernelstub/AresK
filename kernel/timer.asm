; timer.asm - PIT setup for IRQ0
BITS 64
global timer_init
timer_init:
    ; PIT channel 0, rate divisor for ~100Hz
    mov al, 0x34
    out 0x43, al
    mov ax, 1193182/100
    ; low byte
    mov al, al
    out 0x40, al
    ; high byte
    mov al, ah
    out 0x40, al
    ret