
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
	Reg Oscillator;
	Reg Incr;
	Reg Value;

	u8 Waveform;

	Reg ADSR[4];
	Reg ADSRState;
	Reg Amp;

	Reg PulseWidth;
	Reg Bend;
	Reg Volume;
} Voice;

typedef struct 
{
	Reg Oscillator;
	Reg Incr;
	Reg Value;

	u8 Waveform;

	Reg PulseWidth;
	Reg Amplitude;
} LFO;

/* LFO matrix

            voice 0->7            voice 7->16
       frequency pulsewidth | frequency pulsewidth
LFO 0      0         1      |     2         3
LFO 1      4         5      |     x         x

*/

void InitSynth();

void Tick();

void Output();

void NoteOn(Reg freq, u8 voice);
void NoteOff(u8 voice);
//void Ctrl(u8 voice, Reg frequency, Reg 

void SetReg(u8 regset, u8 reg, Reg value);
Reg GetReg(u8 regset, u8 reg);


/*
== Voice ==
Oscillator -> Waveform -> ADSR -> volume -> Out
    |                      |
  bend                    gate


== Synth ==

Voice 0-7  -> [+] -> filter -[+] -> out
Voice 8-15 -> [+] -> filter --^
*/