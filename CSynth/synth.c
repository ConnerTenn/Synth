
#include "synth.h"
#include "audioiface.h"
#include <math.h>

u32 WC=0;
u32 INCR;

void Tick()
{
	//static u16 i = 0;
	//i16 off = 10*sin(6*i*TAU/65535); i++;
	if (WC+INCR>0xFFFFFF) { WC=0; }
	else { WC+=INCR; }

}

void Output()
{
	u32 v = (0xFFFFFF/10);
	//u16 s = (v*WC+65535*32768-v*32768)/65535;
	//i16 s = (v*WC-v*32768)/65535;
	//i16 s = Amplitude16(WC, v)-U16MAX/2;
	//i16 s = (0xFFFF*((u64)v*WC-v*0xFFFFFF/2)/0xFFFFFF)/0xFFFFFF;
	i16 s = (u64)U16MAX*Amplitude24(WC, v)/0xFFFFFF-32768;

	PulseWrite((u8 *)&s, 1*sizeof(i16));
}

