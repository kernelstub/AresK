; kalloc.asm - tiny slab-like allocator (fixed-size buckets)
BITS 64
global kinit_alloc, kalloc, kfree
SECTION .bss
heap_base: resb 65536
heap_next: dq 0

SECTION .text
kinit_alloc:
    mov qword [heap_next], heap_base
    ret

kalloc:
    ; rdi = size
    mov rax, [heap_next]
    add qword [heap_next], rdi
    ret

kfree:
    ; no-op for demo
    ret