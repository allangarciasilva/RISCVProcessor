CC = clang
CFLAGS = --target=riscv32 -march=rv32g -nostdlib -fpic -ffunction-sections -Wl,--gc-sections -O3

SRC_DIR = software
BUILD_DIR = build/software
DEPS_DIR = $(SRC_DIR)/dependencies

LINKER_FILE = $(DEPS_DIR)/linking.ld
START_FILE = $(DEPS_DIR)/start.asm
DEPS_FILES = $(wildcard $(DEPS_DIR)/*.c $(DEPS_DIR)/**/.c)

CFLAGS += -T $(LINKER_FILE)

%.elf : $(SRC_DIR)/%.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(START_FILE) $(DEPS_FILES) $^ -o $(BUILD_DIR)/$@

%.bin : %.elf
	llvm-objdump $(BUILD_DIR)/$^ -d > $(BUILD_DIR)/$^.text.dump
	llvm-objdump $(BUILD_DIR)/$^ -s > $(BUILD_DIR)/$^.sections.dump
	llvm-objcopy -O binary --only-section=.text --only-section=.data $(BUILD_DIR)/$^ $(BUILD_DIR)/$@

% : %.bin
	echo "$(BUILD_DIR)/$^" | python scripts/binary_to_memory.py
	python scripts/compile_vcom.py