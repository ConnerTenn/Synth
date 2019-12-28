
GCC=gcc
CFLAGS= -O3
LIBS=-lX11 -lm -lpulse -lpulse-simple

.PHONY: all program

all: program


%.o: %.c
	$(GCC) $(CFLAGS) $< -c -o $@


program: main.o globals.o audioiface.o synth.o sequencer.o
	$(GCC) $(CFLAGS) $(LIBS) $? -o $@


clean:
	rm -f *.elf *.hex *.o

play:
	./program
	#| aplay -r 44000 -f U16_LE --buffer-time=1 --buffer-size=1

