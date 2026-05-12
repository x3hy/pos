ASM=nasm
ASM_ARGS= -i kernel/lib -f bin
CC=cc
BUILD_DIR=build

all: clean floppy commit

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
	$(ASM) $(ASM_ARGS) kernel/boot/boot.asm -o $(BUILD_DIR)/bootloader.bin

# Kernel
kernel: $(BUILD_DIR)/kernel.bin
$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(ASM_ARGS) kernel/main.asm -o $(BUILD_DIR)/kernel.bin

always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)/*

run: $(BUILD_DIR)/floppy.img
	qemu-system-i386 -fda $(BUILD_DIR)/floppy.img -display curses

debug: $(BUILD_DIR)/floppy.img
	bochs -f .bochs

commit:
	git add .
	git commit -m "autocommit"
