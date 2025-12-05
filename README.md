# AresK

AresK is a 64 bit kernel written in **x86\_64 assembly** with a minimal **C runtime** for higher level abstractions. It is designed for fundamental **operating system internals**.

The kernel boots via **GRUB** using the **Multiboot2** specification and runs in **long mode**, providing hardware level control of the CPU, memory, and I/O devices.

---

## Features

* **Boot Process**

  * Multiboot2-compliant header for GRUB loading
  * Transition from **16-bit real mode** → **32-bit protected mode** → **64-bit long mode**
  * Custom GDT and IDT setup
* **Memory Management**

  * Physical memory map retrieval via BIOS **E820**
  * Identity paging for kernel space
  * Control register manipulation (`CR0`, `CR3`, `CR4`, `EFER`) to enable paging and long mode
* **Interrupt Handling**

  * PIC remapping to avoid IRQ conflicts
  * Hardware interrupt handlers for timer and keyboard
  * Exception handlers for CPU faults
* **Drivers**

  * VGA text mode driver for direct screen output
  * PS/2 keyboard driver with interrupt-based input
* **Multitasking**

  * Basic cooperative task switching
  * Full CPU context save/restore (general registers, segment registers, stack pointer, instruction pointer)
* **Shell**

  * Minimal interactive prompt (`aresk>`) with commands:

    * `help` – show available commands
    * `info` – show CPU mode, memory map, and interrupt status
    * `echo` – print provided text

---

## Assembly Language and Tooling

### Assembly

The kernel uses **NASM** (Intel syntax) for low-level control. Notable techniques include:

* **Bootstrapping:**

  ```asm
  cli                     ; disable interrupts
  lgdt [gdt_descriptor]   ; load GDT
  mov eax, cr0
  or eax, 1
  mov cr0, eax            ; enable protected mode
  ```
* **Enabling Long Mode:**

  ```asm
  mov ecx, 0xC0000080     ; EFER MSR
  rdmsr
  or eax, 0x00000100      ; set LME bit
  wrmsr
  ```
* **IDT Entry Setup:**

  ```asm
  set_idt_entry:
      mov word [rdi], dx           ; offset low
      mov word [rdi+2], cs         ; code segment
      mov byte [rdi+5], type_attr  ; type and attributes
      mov word [rdi+6], bx         ; offset mid
      mov dword [rdi+8], eax       ; offset high
      mov dword [rdi+12], 0        ; reserved
  ```

### Build Tools

* **GNU Make** — orchestrates compilation, linking, and ISO creation
* **GCC (cross-compiler)** — compiles C code with:

  ```bash
  -ffreestanding -m64 -nostdlib -O2
  ```
* **NASM** — assembles `.asm` source files:

  ```bash
  nasm -f elf64 file.asm -o file.o
  ```
* **GRUB (grub-mkrescue)** — creates bootable ISO
* **xorriso** — ISO image manipulation

---

## Build Requirements

* GNU Make
* GCC cross-compiler or host GCC with bare-metal build flags
* NASM assembler
* GRUB tools (`grub-mkrescue`)
* xorriso
* QEMU (optional, for testing)

---

## Building

```bash
make
```

Produces:

```
build/kernel.elf
```

---

## Creating a Bootable ISO

```bash
./build_iso.sh
```

Outputs:

```
AresK.iso
```

---

## Running in QEMU

```bash
qemu-system-x86_64 -cdrom AresK.iso
```

---

## Running on Real Hardware

1. Write ISO to USB:

   ```bash
   sudo dd if=AresK.iso of=/dev/sdX bs=4M status=progress && sync
   ```
2. Boot from USB in BIOS mode.
3. Test on a non-critical system or virtual machine to avoid unintended hardware effects.

---

## Technical Overview

### 1. Boot and Mode Switching

When the system powers on, GRUB loads the kernel using the Multiboot2 specification. The kernel’s entry point is in **16-bit real mode**. It first disables interrupts, loads a **temporary GDT** that supports 32-bit code, and sets the **PE (Protection Enable)** bit in `CR0` to enter **protected mode**.

From protected mode, the kernel enables **PAE (Physical Address Extension)** via `CR4` and sets the **LME (Long Mode Enable)** bit in the `EFER` MSR. Paging is enabled in `CR0`, and control is transferred to a **64-bit long mode** code segment.

---

### Boot Flow Diagram

```
+---------------------+
|   Power On / BIOS   |
+---------------------+
           |
           v
+---------------------+
| BIOS Loads GRUB     |
| (from disk or ISO)  |
+---------------------+
           |
           v
+---------------------+
| GRUB Loads AresK    |
| (Multiboot2 spec)   |
+---------------------+
           |
           v
+---------------------+
| 16-bit Real Mode    |
| - BIOS calls        |
| - Load GDT          |
+---------------------+
           |
           v
+---------------------+
| 32-bit Protected    |
| Mode                |
| - Enable PAE        |
| - Load Page Tables  |
+---------------------+
           |
           v
+---------------------+
| 64-bit Long Mode    |
| - IDT setup         |
| - Drivers init      |
| - Shell ready       |
+---------------------+
```

---

### 2. GDT and IDT

* **GDT**: Defines flat memory model with separate code/data segments for 64-bit and compatibility mode.
* **IDT**: Defines interrupt service routines for CPU exceptions and hardware IRQs. Each entry is configured with privilege level, gate type, and handler address.

---

### 3. Paging

The paging system uses a **4-level hierarchy**:

* PML4 → PDPT → Page Directory → Page Table
* Each mapping is identity-mapped for the kernel space initially.
* `CR3` is loaded with the PML4 base address.

---

### Memory Layout Diagram

```
Virtual Memory Layout (initial kernel mapping):

0x0000000000000000  ----------------------------
                    Identity-mapped physical memory
                    (used for early boot & drivers)

0x0000000000100000  ----------------------------
                    Kernel .text, .rodata, .data, .bss

0x00000000F0000000  ----------------------------
                    MMIO region (VGA, serial ports, etc.)

0x0000000100000000  ----------------------------
                    Higher-half kernel mapping (optional future)

0xFFFFFFFF80000000  ----------------------------
                    Kernel mapped at high virtual addresses
                    (future relocation for isolation)
```

---

### 4. Interrupt Handling

The kernel remaps the **PIC** so that hardware IRQs do not overlap CPU exception vectors. For example, IRQ0 (timer) is mapped to vector 32, IRQ1 (keyboard) to vector 33. Handlers are written in assembly for precise register preservation.

---

### 5. Drivers

* **VGA Text Driver**: Directly writes characters to `0xB8000` memory with attribute bytes for color.
* **Keyboard Driver**: Reads scancodes from port `0x60` and translates them to ASCII characters.

---

### 6. Multitasking

The kernel maintains a list of tasks with saved CPU contexts. The scheduler switches tasks by saving the current register state to the task’s control block and restoring the next task’s registers before `iretq`.

---

## License

AresK is released under the **MIT License**.