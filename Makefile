AS=nasm
LD=ld
CC=gcc
CFLAGS=-fno-builtin -ffreestanding -O2 -m64 -fno-stack-protector
ASFLAGS=-felf64
LDFLAGS=-T kernel/linker.ld -nostdlib
OBJDIR=obj
KERNEL=kernel.bin

all: $(KERNEL) iso

$(KERNEL): $(OBJDIR)/start.o $(OBJDIR)/entry.o $(OBJDIR)/printk.o $(OBJDIR)/kmain.o $(OBJDIR)/gdt_idt.o $(OBJDIR)/task_switch.o $(OBJDIR)/kalloc.o $(OBJDIR)/timer.o $(OBJDIR)/vga.o
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJDIR)/%.o: kernel/%.asm | $(OBJDIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/entry.o: kernel/entry.S
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJDIR)/kmain.o: kernel/kmain.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJDIR):
	mkdir -p $(OBJDIR)

iso: $(KERNEL)
	mkdir -p iso/boot/grub
	cp $(KERNEL) iso/boot/aresk.kernel
	cp boot/grub.cfg iso/boot/grub/grub.cfg
	grub-mkrescue -o aresk.iso iso

clean:
	rm -rf obj $(KERNEL) iso aresk.iso

.PHONY: all iso clean