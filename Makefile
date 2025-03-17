CXX = g++

CXXFLAGS = -g3 -ggdb -lm

all: run


run: build main.o printf
	@$(CXX) $(CXXFLAGS) build/*.o -o printf_check -z noexecstack  -no-pie


build:
	@mkdir -p build

printf: compile_asm myprintf.o
	@

compile_asm: build
	@nasm -f elf64 -l build/printf.lst printf.asm -o build/printf.o -g -F dwarf

myprintf.o: myprintf.cpp
	@$(CXX) $(CXXFLAGS) -c myprintf.cpp -o build/myprintf.o

main.o: main.cpp
	@$(CXX) $(CXXFLAGS) -c main.cpp -o build/main.o


clean: rmdir_build
	rm -rf printf_check

rmdir_build: clean_build
	rmdir build

clean_build:
	rm -rf build/*

