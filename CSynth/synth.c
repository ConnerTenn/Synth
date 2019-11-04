
#include "synth.h"
#include "audioiface.h"
#include <math.h>

u16 WC=0;
u16 INCR;

void Tick()
{
	//static u16 i = 0;
	//i16 off = 10*sin(6*i*TAU/65535); i++;
	if (WC+INCR>65535) { WC=0; }
	else { WC+=INCR; }

}

void Output()
{
	u16 v = (65535/10);
	//u16 s = (v*WC+65535*32768-v*32768)/65535;
	i16 s = (v*WC-v*32768)/65535;

	PulseWrite((u8 *)&s, 1*sizeof(i16));
}

