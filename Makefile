ASM=nasm
LD=i686-elf-ld
GCC=i686-elf-gcc

SRC_DIR=src
BUILD_DIR=build

BOOT_SECTOR_SRC=$(SRC_DIR)/boot_sector
KERNEL_SRC=$(SRC_DIR)/kernel
DRIVERS_SRC=$(SRC_DIR)/drivers

EMU=qemu-system-x86_64



$(BUILD_DIR)/os_image.img: $(BUILD_DIR)/boot_sector.bin $(BUILD_DIR)/kernel.bin
	cat $(BUILD_DIR)/boot_sector.bin $(BUILD_DIR)/kernel.bin > $(BUILD_DIR)/os_image.img
	truncate -s 1440k $(BUILD_DIR)/os_image.img
	
$(BUILD_DIR)/boot_sector.bin: $(BOOT_SECTOR_SRC)/main.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(BOOT_SECTOR_SRC)/main.asm -f bin -o $(BUILD_DIR)/boot_sector.bin


# Build the kernel binary
$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel_entry.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/drivers.o
	$(LD) -o $(BUILD_DIR)/kernel.bin -Ttext 0x1000 $(BUILD_DIR)/kernel_entry.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/drivers.o --oformat binary
# Build the kernel object file
$(BUILD_DIR)/kernel.o : $(KERNEL_SRC)/*.c
	$(GCC) -ffreestanding -I$(DRIVERS_SRC) -c $(KERNEL_SRC)/kernel.c -o $(BUILD_DIR)/kernel.o
# Build the kernel entry object file.
$(BUILD_DIR)/kernel_entry.o : $(KERNEL_SRC)/kernel_entry.asm
	$(ASM) $(KERNEL_SRC)/kernel_entry.asm -f elf -o $(BUILD_DIR)/kernel_entry.o

$(BUILD_DIR)/drivers.o : $(DRIVERS_SRC)/*.c
	$(GCC) -ffreestanding -I$(DRIVERS_SRC) -c $(DRIVERS_SRC)/*.c -o $(BUILD_DIR)/drivers.o

run:
	$(EMU) $(BUILD_DIR)/os_image.img

clean:
	rm -fr $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.dis $(BUILD_DIR)/*.o $(BUILD_DIR)/os_image.img $(BUILD_DIR)/*.map
