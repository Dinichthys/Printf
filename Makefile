all: run


run: build main.o compile_asm
	@g++ build/*.o -o printf_check -z noexecstack


build:
	@mkdir -p build


compile_asm: build
	@nasm -f elf64 -l build/printf.lst printf.asm -o build/printf.o

# link_asm:
# 	@ld -s -o build/printf.a build/printf.o

main.o: main.cpp
	@g++ -c main.cpp -o build/main.o


clean: rmdir_build
	rm -rf printf_check

rmdir_build: clean_build
	rmdir build

clean_build:
	rm -rf build/*

