
#include "synth.h"
#include "audioiface.h"
#include <math.h>

void RegSet(Reg *a, Reg b)
{
	b.Value=b.Value&RIGHTMASK(U64MAX,b.Bits);
	a->Value=b.Value&RIGHTMASK(U64MAX,a->Bits);
}
Reg RegAdd(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&RIGHTMASK(U64MAX,a.Bits);
	b.Value=b.Value&RIGHTMASK(U64MAX,b.Bits);
	return REG((a.Value+b.Value)&RIGHTMASK(U64MAX,bits), bits);
}
Reg RegSub(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&RIGHTMASK(U64MAX,a.Bits);
	b.Value=b.Value&(~(U64MAX<<b.Bits));
	return REG((a.Value-b.Value)&RIGHTMASK(U64MAX,bits), bits);
}
Reg RegMul(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&RIGHTMASK(U64MAX,a.Bits);
	b.Value=b.Value&RIGHTMASK(U64MAX,b.Bits);
	return REG((a.Value*b.Value)&RIGHTMASK(U64MAX,bits), bits);
}
Reg RegDiv(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&RIGHTMASK(U64MAX,a.Bits);
	b.Value=b.Value&RIGHTMASK(U64MAX,b.Bits);
	return REG((a.Value/b.Value)&RIGHTMASK(U64MAX,bits), bits);
}
Reg RegMod(Reg a, Reg b, u8 bits)
{
	a.Value=a.Value&RIGHTMASK(U64MAX,a.Bits);
	b.Value=b.Value&RIGHTMASK(U64MAX,b.Bits);
	return REG((a.Value%b.Value)&RIGHTMASK(U64MAX,bits), bits);
}

u64 RegScaleRaw(u64 val, u64 scale, u8 bits)
{
	u64 r=0;
	for (u8 i=0; i<bits; i++)
	{
		r += (scale&(1<<(bits-i-1))?1:0) * (val>>i);
	}
	return r;
}

Reg RegScale(Reg val, Reg scale, u8 bits)
{
	val.Value=val.Value&RIGHTMASK(U64MAX,val.Bits);
	scale.Value=scale.Value&RIGHTMASK(U64MAX,scale.Bits);

	u64 r=RegScaleRaw(val.Value, scale.Value, bits);

	r=r&RIGHTMASK(U64MAX,bits+1);
	return REG(r, bits+1);
}
Reg RegScaleShft(Reg val, Reg scale, u8 bits, u8 shift)
{
	val.Value=val.Value&RIGHTMASK(U64MAX,val.Bits);
	scale.Value=scale.Value&RIGHTMASK(U64MAX,scale.Bits);

	u64 r=RegScaleRaw((val.Value<<shift)+(1<<shift), scale.Value, bits+1)>>shift;
	
	r=r&RIGHTMASK(U64MAX,bits);
	return REG(r, bits);
}

u16 Amplitude16(u16 val, u16 amp)
{
	return (u16)(((u32)amp*val+(u32)U16MAX*U16MAX/2-(u32)amp*U16MAX/2)/(u32)U16MAX);
}
u32 Amplitude24(u32 val, u32 amp)
{
	return (u32)(((u64)amp*val+(u64)0xFFFFFF*0xFFFFFF/2-(u64)amp*0xFFFFFF/2)/(u64)0xFFFFFF);
}

Waveform WF[6];

void InitSynth()
{
	for (u8 i=0; i<6; i++)
	{
		WF[i] = (Waveform){
				.Incr=REG(0,24),
				.Oscillator=REG(0,24),
				.PulseWidth=REG(0,24),
				.Bend=REG(0,24) };
		NoteOff(6);
	}

}

void Tick()
{
	for (u8 i=0; i<6; i++)
	{
		//If Oscillator overflows with Incr
		if(RegAdd(WF[i].Oscillator, WF[i].Incr,25).Value&(1<<25))
		{
			//reset to 0
			RegSet(&WF[i].Oscillator, REG(0,24));
		}
		else
		{
			//Else add
			WF[i].Oscillator=RegAdd(WF[i].Oscillator, WF[i].Incr,24);
		}
	}
}

void Output()
{
	u32 v = (0xFFFFFF/5);
	//i16 s = (0xFFFF*((u64)v*WC-v*0xFFFFFF/2)/0xFFFFFF)/0xFFFFFF;
	
	i32 sum=0;
	for (u8 i=0; i<6; i++)
	{
		u64 val = WF[i].Oscillator.Value;
		//val=val>8388608?0xFFFFFF:0;
		sum += ((u64)U16MAX*Amplitude24(val, v)/0xFFFFFF-32768);
	}
	i16 s=sum/6;

	PulseWrite((u8 *)&s, 1*sizeof(i16));
}

void NoteOn(Reg freq, u8 voice)
{
	RegSet(&WF[voice].Incr, freq);
	RegSet(&WF[voice].Oscillator, REG(0x1000000/2,24));
}

void NoteOff(u8 voice)
{
	RegSet(&WF[voice].Incr, REG(0,24));
	RegSet(&WF[voice].Oscillator, REG(0x1000000/2,24));
}


