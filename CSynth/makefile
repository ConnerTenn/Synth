
GCC=gcc
CFLAGS= -O3

.PHONY: all program

all: program


%.o: %.c
	$(GCC) $(CFLAGS) $< -c -o $@


program: main.o globals.o audioiface.o
	$(GCC) $(CFLAGS) $? -lX11 -lpulse -lpulse-simple -o $@


clean:
	rm -f *.elf *.hex *.o

play:
	./program
	#| aplay -r 44000 -f U16_LE --buffer-time=1 --buffer-size=1

