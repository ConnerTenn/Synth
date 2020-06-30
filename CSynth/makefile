
GCC=gcc
CFLAGS= -O3
LIBS=-lX11 -lm -lpulse -lpulse-simple

.PHONY: all sequencer

all: sequencer


%.o: %.c
	$(GCC) $(CFLAGS) $< -c -o $@


sequencer: main.o globals.o audioiface.o synth.o sequencer.o
	$(GCC) $(CFLAGS) $(LIBS) $? -o $@


clean:
	rm -f *.elf *.hex *.o sequencer

play:
	./sequencer
	#| aplay -r 44000 -f U16_LE --buffer-time=1 --buffer-size=1

