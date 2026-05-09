ASM=nasm
CC=cc
BUILD_DIR=build

all: floppy commit run

# Create the floppy IMG file
floppy: $(BUILD_DIR)/floppy.img
$(BUILD_DIR)/floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/floppy.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

# Bootloader
bootloader: $(BUILD_DIR)/bootloader.bin
$(BUILD_DIR)/bootloader.bin: always
	$(ASM) kernel/boot/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin

# Kernel
kernel: $(BUILD_DIR)/kernel.bin
$(BUILD_DIR)/kernel.bin: always
	$(ASM) kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/main.bin: main.asm
	$(ASM) main.asm -f bin -o $(BUILD_DIR)/main.bin

always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)/*

run:
	qemu-system-i386 -fda $(BUILD_DIR)/pos.img -display curses

commit:
	git add .
	git commit -m "autocommit"
