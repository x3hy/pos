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
	dd if=$(BUILD_DIR)/stage1.bin of=$(BUILD_DIR)/floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/floppy.img $(BUILD_DIR)/stage2.bin "::stage2.bin"
	mcopy -i $(BUILD_DIR)/floppy.img test.txt "::text.txt"

# Bootloaders
bootloader: $(BUILD_DIR)/stage1.bin  $(BUILD_DIR)/stage2.bin

# Stage1
$(BUILD_DIR)/stage1.bin: always
	$(ASM) $(ASM_ARGS) kernel/boot/stage1.asm -o $(BUILD_DIR)/stage1.bin

# Stage 2
$(BUILD_DIR)/stage2.bin: always
	$(ASM) $(ASM_ARGS) kernel/boot/stage2.asm -o $(BUILD_DIR)/stage2.bin

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

commit:
	git add .
	git commit -m "autocommit"
