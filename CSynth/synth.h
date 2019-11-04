
#include "globals.h"


#define Sawtooth 0
#define Square 1
#define Triangle 2
#define Noise 3
#define Sine 4
#define Sample(n) (5+n)

typedef struct
{
	u8 Bits;
	u64 Value;
} Reg;

void RegSet(Reg *a, Reg b);
Reg RegAdd(Reg a, Reg b, u8 bits);
Reg RegSub(Reg a, Reg b, u8 bits);
Reg RegMul(Reg a, Reg b, u8 bits);
Reg RegDiv(Reg a, Reg b, u8 bits);
Reg RegMod(Reg a, Reg b, u8 bits);

typedef struct 
{
	Reg Incr;
	Reg Oscillator;
	Reg PulseWidth;
	Reg Bend;
	u8 Type;
	
} Waveform;

typedef struct 
{
	Waveform HFO;
	Waveform LFO;
	u8 LFOMod;
} WaveformGenerator;

u16 Amplitude16(u16 val, u16 amp);

void InitSynth();

void Tick();

void Output();

void NoteOn(Reg freq);
void NoteOff();

