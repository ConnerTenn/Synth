
#include "synth.h"
#include "audioiface.h"
#include <math.h>

u32 WC=0;
u32 INCR;

//#define ASSERTBITDEPTH { if (a.Bits!=b.Bits) { fprintf(stderr,"Error::%s: Bit depths do not match\n", __FUNCTION__); exit(1); } }
void RegSet(Reg *a, Reg b)
{
	b.Value=b.Value&(~(U64MAX<<b.Bits));
	a->Value=b.Value&(~(U64MAX<<a->Bits));
}
Reg RegAdd(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&(~(U64MAX<<a.Bits));
	b.Value=b.Value&(~(U64MAX<<b.Bits));
	return (Reg){.Bits=bits, (a.Value+b.Value)&(~(U64MAX<<bits))};
}
Reg RegSub(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&(~(U64MAX<<a.Bits));
	b.Value=b.Value&(~(U64MAX<<b.Bits));
	return (Reg){.Bits=bits, (a.Value-b.Value)&(~(U64MAX<<bits))};
}
Reg RegMul(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&(~(U64MAX<<a.Bits));
	b.Value=b.Value&(~(U64MAX<<b.Bits));
	return (Reg){.Bits=bits, (a.Value*b.Value)&(~(U64MAX<<bits))};
}
Reg RegDiv(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&(~(U64MAX<<a.Bits));
	b.Value=b.Value&(~(U64MAX<<b.Bits));
	return (Reg){.Bits=bits, (a.Value/b.Value)&(~(U64MAX<<bits))};
}
Reg RegMod(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&(~(U64MAX<<a.Bits));
	b.Value=b.Value&(~(U64MAX<<b.Bits));
	return (Reg){.Bits=bits, (a.Value%b.Value)&(~(U64MAX<<bits))};
}

u16 Amplitude16(u16 val, u16 amp)
{
	return (u16)(((u32)amp*val+(u32)U16MAX*U16MAX/2-(u32)amp*U16MAX/2)/(u32)U16MAX);
}
u32 Amplitude24(u32 val, u32 amp)
{
	return (u32)(((u64)amp*val+(u64)0xFFFFFF*0xFFFFFF/2-(u64)amp*0xFFFFFF/2)/(u64)0xFFFFFF);
}

Waveform WF0;

void InitSynth()
{
	WF0.Bend.Bits=24;
	WF0.Incr.Bits=24;
	WF0.Oscillator.Bits=24;
	NoteOff();
}

void Tick()
{
	//static u16 i = 0;
	//i16 off = 10*sin(6*i*TAU/65535); i++;
	if (WC+INCR>0xFFFFFF) { WC=0; }
	else { WC+=INCR; }

	if(RegAdd(WF0.Oscillator, WF0.Incr,25).Value&(1<<25))
	{
		RegSet(&WF0.Oscillator, (Reg){.Bits=24,.Value=0});
	}
	else
	{
		WF0.Oscillator=RegAdd(WF0.Oscillator, WF0.Incr,24);
	}
}

void Output()
{
	u32 v = (0xFFFFFF/10);
	//u16 s = (v*WC+65535*32768-v*32768)/65535;
	//i16 s = (v*WC-v*32768)/65535;
	//i16 s = Amplitude16(WC, v)-U16MAX/2;
	//i16 s = (0xFFFF*((u64)v*WC-v*0xFFFFFF/2)/0xFFFFFF)/0xFFFFFF;
	//i16 s = (u64)U16MAX*Amplitude24(WC, v)/0xFFFFFF-32768;
	i16 s = (u64)U16MAX*Amplitude24(WF0.Oscillator.Value, v)/0xFFFFFF-32768;

	PulseWrite((u8 *)&s, 1*sizeof(i16));
}

void NoteOn(Reg freq)
{
	RegSet(&WF0.Incr, freq);
	RegSet(&WF0.Oscillator, (Reg){.Bits=24,.Value=0x1000000/2});
}

void NoteOff()
{
	RegSet(&WF0.Incr, (Reg){.Bits=24,.Value=0});
	RegSet(&WF0.Oscillator, (Reg){.Bits=24,.Value=0x1000000/2});
}


