
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

Voice Voices[16];

void InitSynth()
{
	for (u8 i=0; i<16; i++)
	{
		Voices[i] = (Voice){
				.Oscillator=REG(0x7FFFFF,24),
				.Incr=REG(0,24),
				.Value=REG(0x7FFFFF,24),

				.Waveform=Sawtooth,

				.ADSR={100, 100, 0xFFFFFF, 0xFFFF10},
				.ADSRState=0,
				.Amp=0,
				.Gate=0,

				.PulseWidth=REG(0x7FFFFF,24),
				.Bend=REG(0,24),
				.Volume=REG(0xFFFFFF,24) 
				};
	}
}

void Tick()
{
	for (u8 i=0; i<16; i++)
	{
		Voice *voice = &Voices[i];
		
		//Waveform Oscillator
		//If Oscillator overflows with Incr
		if(RegAdd(RegAdd(voice->Oscillator, voice->Incr,25), voice->Bend, 25).Value & (1<<24))
		{
			//reset to 0
			RegSet(&voice->Oscillator, REG(0,24));
		}
		else
		{
			//Else add
			voice->Oscillator = RegAdd(RegAdd(voice->Oscillator, voice->Incr,24), voice->Bend, 24);
		}
	
		//Waveform Generator
		if (voice->Waveform==Sawtooth)
		{
			voice->Value=voice->Oscillator;
		}
		else if (voice->Waveform==Square)
		{
			voice->Value.Value = voice->Oscillator.Value > voice->PulseWidth.Value ? 0xFFFFFF : 0;
		}
		else if (voice->Waveform==Triangle)
		{
			voice->Value.Value = voice->Oscillator.Value > voice->PulseWidth.Value ? 0xFFFFFF : 0;
		}
		
		//ADSR
		if (voice->Gate)
		{
			if (voice->ADSRState==0)
			{
				voice->Amp += voice->ADSR[0];
				if (voice->Amp>=0xFFFFFF) { voice->Amp=0xFFFFFF; voice->ADSRState=1; }
				voice->Value.Value = Amplitude24(voice->Value.Value, voice->Amp);
			}
			else if (voice->ADSRState==1)
			{
				voice->Amp -= voice->ADSR[1];
				if (voice->Amp<=voice->ADSR[2]) { voice->Amp=voice->ADSR[2]; voice->ADSRState=2; }
				voice->Value.Value = Amplitude24(voice->Value.Value, voice->Amp);
			}
			else
			{
				voice->Value.Value = Amplitude24(voice->Value.Value, voice->ADSR[2]);
			}
		}
		else
		{
			voice->Amp = voice->Amp * voice->ADSR[3] / 0xFFFFFF; //Fix
			voice->Value.Value = Amplitude24(voice->Value.Value, voice->Amp);
		}

		//Volume
		voice->Value.Value = Amplitude24(voice->Value.Value, voice->Volume.Value);
	}
}

void Output()
{
	i32 sum=0;
	for (u8 i=0; i<16; i++)
	{
		sum += ((u64)U16MAX*Voices[i].Value.Value/0xFFFFFF-0x7FFF);
	}
	i16 s=sum/16;

	PulseWrite((u8 *)&s, 1*sizeof(i16));
}

void NoteOn(Reg freq, u8 voice)
{
	RegSet(&Voices[voice].Incr, freq);
	RegSet(&Voices[voice].Oscillator, REG(0x7FFFFF,24));
	Voices[voice].ADSRState=0;
	Voices[voice].Amp=0;
	Voices[voice].Gate=1;
}

void NoteOff(u8 voice)
{
	//RegSet(&Voices[voice].Incr, REG(0,24));
	//RegSet(&Voices[voice].Oscillator, REG(0x7FFFFF,24));
	Voices[voice].Gate=0;
}


