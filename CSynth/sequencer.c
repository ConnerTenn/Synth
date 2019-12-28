
#include "sequencer.h"

FILE *SFile;
void InitSequencer(char *file)
{
	FILE *SFile = fopen(file, "rb");
}

/*

Regset
0: Signal Delay
1-16: Synth Reserved
17: delay value
18-19: Sequencer reserved
20-..: Synth Reserved

*/

u64 Delay;

void PlaySequence()
{
	u64 sample=0;
	u64 delaytimer; 

	while (Run)
	{
		if (sample>=delaytimer)
		{
			u8 regset;
			u8 update=1;
			while (update)
			{
				fread(&regset, sizeof(u8), 1, SFile);
				if (!regset)
				{
					delaytimer=sample+Delay;
					update=0;
				}
				else if (regset==17)
				{
					u64 value;
					fread(&value, sizeof(u64), 1, SFile);
					Delay=value;
				}
				else
				{
					u8 reg; u64 value;
					fread(&reg, sizeof(u8), 1, SFile);
					fread(&value, sizeof(u64), 1, SFile);

					SetReg(regset, reg, value);
				}
			}
		}

		//5000 SampleRate * 20 = 1,000,000 (1GHz) Update Frequency 
		for (int i=0; i<20; i++) { Tick(); sample++; }
		Output(); 
	}
}


