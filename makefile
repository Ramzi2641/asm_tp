N ?= 0

NAME := $(shell printf "asm%02d" $(N))
SRC  := $(NAME)/$(NAME).s
OBJ  := build/$(NAME).o
BIN  := build/$(NAME)

NASM := nasm
LD   := ld

all: $(BIN)

build:
	mkdir -p build

$(OBJ): $(SRC) | build
	$(NASM) -f elf64 $< -o $@

$(BIN): $(OBJ)
	$(LD) $< -o $@

run: $(BIN)
	./$(BIN)

clean:
	rm -f build/*.o

fclean: clean
	rm -f build/asm*

re: fclean all

.PHONY: all run clean fclean re
