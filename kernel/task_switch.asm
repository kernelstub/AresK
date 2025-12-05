; task_switch.asm - save/restore full context. Small scheduler demo.
BITS 64
global schedule, task_init, yield
SECTION .data
current_task: dq 0

SECTION .text
task_init:
    ; rdi = task_struct ptr, rsi = entry
    mov [rdi], rsi
    ret

yield:
    call schedule
    ret

schedule:
    ; Very small round-robin between two demo stacks (addresses placed by kmain)
    ; Save callee-saved regs
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rax, [current_task]
    cmp rax, 0
    je .switch_to_1
    mov [current_task], 0
    jmp .restore_0
.switch_to_1:
    mov [current_task], 1
.restore_0:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret