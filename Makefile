ASM=nasm
LD=i686-elf-ld
CC=i686-elf-gcc
CC_FLAGS=-ffreestanding


SRC_DIR=src
BUILD_DIR=build
OBJ_DIR=obj

BOOT_SECTOR_SRC=$(SRC_DIR)/boot_sector

KERNEL_SRC=$(SRC_DIR)/kernel
KERNEL_SRCS=$(wildcard $(KERNEL_SRC)/*.c)
KERNEL_OBJS=$(patsubst $(KERNEL_SRC)/%.c,$(OBJ_DIR)/kernel/%.o,$(KERNEL_SRCS))
#KERNEL_HEADERS=$(wildcard $(KERNEL_SRC)/*.h)
#KERNEL_HEADERS_FLAG=$(patsubst $(KERNEL_SRC)/%.h,-I$(KERNEL_SRC)/%.h,$(KERNEL_HEADERS))

DRIVERS_SRC=$(SRC_DIR)/drivers
DRIVERS_SRCS=$(wildcard $(DRIVERS_SRC)/*.c)
DRIVERS_OBJS=$(patsubst $(DRIVERS_SRC)/%.c,$(OBJ_DIR)/drivers/%.o,$(DRIVERS_SRCS))
#DRIVERS_HEADERS=$(wildcard $(DRIVERS_SRC)/*.h)
#DRIVERS_HEADERS_FLAG=$(patsubst $(DRIVERS_SRC)/%.h,-I$(DRIVERS_SRC)/%.h,$(DRIVERS_HEADERS))

EMU=qemu-system-x86_64


$(BUILD_DIR)/os_image.img: $(BUILD_DIR)/boot_sector.bin $(BUILD_DIR)/kernel.bin
	cat $(BUILD_DIR)/boot_sector.bin $(BUILD_DIR)/kernel.bin > $(BUILD_DIR)/os_image.img
	truncate -s 1440k $(BUILD_DIR)/os_image.img
	
$(BUILD_DIR)/boot_sector.bin: $(BOOT_SECTOR_SRC)/main.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(BOOT_SECTOR_SRC)/main.asm -f bin -o $(BUILD_DIR)/boot_sector.bin


# Build the kernel binary
$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel_entry.o $(KERNEL_OBJS) $(DRIVERS_OBJS)
	$(LD) -o $(BUILD_DIR)/kernel.bin -Ttext 0x1000 $(BUILD_DIR)/kernel_entry.o $(KERNEL_OBJS) $(DRIVERS_OBJS) --oformat binary
# Build the kernel object file
#$(BUILD_DIR)/kernel.o : $(KERNEL_SRC)/*.c
#	$(CC) $(CC_FLAGS) -I$(DRIVERS_SRC) -c $(KERNEL_SRC)/kernel.c -o $(BUILD_DIR)/kernel.o
# $(BUILD_DIR)/kernel_merged.o : $(KERNEL_OBJS)
# 	$(LD) $< -o $@
# kernel generic build
$(OBJ_DIR)/kernel/%.o: $(KERNEL_SRC)/%.c
	$(CC) $(CC_FLAGS) -I$(DRIVERS_SRC)/ -I$(KERNEL_SRC)/ -c $< -o $@

# Build the kernel entry object file.
$(BUILD_DIR)/kernel_entry.o : $(KERNEL_SRC)/kernel_entry.asm
	$(ASM) $(KERNEL_SRC)/kernel_entry.asm -f elf -o $(BUILD_DIR)/kernel_entry.o

# build drivers binary
#$(BUILD_DIR)/drivers.o : $(DRIVERS_SRC)/*.c
#	$(CC) $(CC_FLAGS) -I$(DRIVERS_SRC) -c $(DRIVERS_SRC)/*.c -o $(BUILD_DIR)/drivers.o
# $(BUILD_DIR)/drivers_merged.o : $(DRIVERS_OBJS)
# 	$(LD) $< -o $@
# drivers generic build
$(OBJ_DIR)/drivers/%.o: $(DRIVERS_SRC)/%.c
	$(CC) $(CC_FLAGS) -I$(DRIVERS_SRC)/*.h -c $< -o $@



run:
	$(EMU) $(BUILD_DIR)/os_image.img



clean:
	rm -fr $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.dis $(BUILD_DIR)/*.o $(BUILD_DIR)/os_image.img $(BUILD_DIR)/*.map
