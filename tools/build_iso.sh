#!/bin/bash
set -e

# Paths
BUILD_DIR=build
ISO_DIR=iso
GRUB_DIR=$ISO_DIR/boot/grub

# Clean old build
rm -rf "$BUILD_DIR" "$ISO_DIR"
mkdir -p "$BUILD_DIR" "$GRUB_DIR"

# Build kernel
echo "[+] Building kernel..."
make

# Copy kernel to ISO structure
cp "$BUILD_DIR/kernel.elf" "$ISO_DIR/boot/"

# Create GRUB config
echo "[+] Creating GRUB config..."
cat > "$GRUB_DIR/grub.cfg" <<EOF
set timeout=0
set default=0

menuentry "AresK" {
    multiboot2 /boot/kernel.elf
    boot
}
EOF

# Create bootable ISO
echo "[+] Creating ISO..."
grub-mkrescue -o AresK.iso "$ISO_DIR" --xorriso=xorriso

echo "[+] Done. ISO created: AresK.iso"
echo "Run with: qemu-system-x86_64 -cdrom AresK.iso"
