// kmain.c - kernel main in C; small stdlib replacements
#include <stdint.h>
extern void kinit(void);
extern void kprintf(const char *fmt, ...);
extern void clear_screen(void);
extern void timer_init(void);
extern void kinit_alloc(void);

void kmain(void) {
    kinit();
    clear_screen();
    kprintf("AresK v0.1\n");
    kprintf("Initializing allocator...\n");
    kinit_alloc();
    kprintf("Starting timer...\n");
    timer_init();
    kprintf("Entering main loop. Try 'help' at aresk> (not implemented)\n");
    while (1) __asm__("hlt");
}