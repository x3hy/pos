ASM=nasm
CC=cc
BUILD_DIR=build

$(BUILD_DIR)/pos.img: $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/pos.img
	truncate -s 1440k $(BUILD_DIR)/pos.img

$(BUILD_DIR)/main.bin: main.asm
	$(ASM) main.asm -f bin -o $(BUILD_DIR)/main.bin
