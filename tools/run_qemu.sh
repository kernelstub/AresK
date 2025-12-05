#!/bin/bash
set -e
qemu-system-x86_64 -m 512M -cdrom aresk.iso -boot d -serial stdio -s -enable-kvm