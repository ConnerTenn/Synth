
#include "globals.h"


#define Sawtooth 0
#define Square 1
#define Triangle 2
#define Noise 3
#define Sine 4
#define Sample(n) (5+n)

typedef struct
{
	u64 Value;
	u8 Bits;
} Reg;

#define REG(v,b) ((Reg){.Value=(v),.Bits=(b)})
#define RIGHTMASK(m,n) (~((m)<<(n)))

void RegSet(Reg *a, Reg b);
Reg RegAdd(Reg a, Reg b, u8 bits);
Reg RegSub(Reg a, Reg b, u8 bits);
Reg RegMul(Reg a, Reg b, u8 bits);
Reg RegDiv(Reg a, Reg b, u8 bits);
Reg RegMod(Reg a, Reg b, u8 bits);

Reg RegScale(Reg val, Reg scale, u8 bits);
Reg RegScaleShft(Reg val, Reg scale, u8 bits, u8 shift);

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

void InitSynth();

void Tick();

void Output();

void NoteOn(Reg freq, u8 voice);
void NoteOff(u8 voice);

