
#include "sequencer.h"

FILE *SFile=0;
u8 InitSequencer(char *file)
{
	SFile = fopen(file, "rb");

	if (!SFile)
	{
		printf("\nError: Failed to open file\n");
		return 0;
	}
	return 1;
}

void CloseSequencer()
{
	fclose(SFile);
}

/*

Regset
0: Signal Delay
1-16: Synth Reserved
17: delay value
18-19: Sequencer reserved
20-.254: Synth Reserved
255: End of sequence
*/

u64 Delay=500000;

void PlaySequence()
{
	u64 sample=0;
	u64 delaytimer=0;
	u8 eof=0;
	
	printf("\nBegin\n");

	while (Run)
	{
		if (sample>=delaytimer)
		{
			u8 regset;
			u8 update=1;
			while (update && Run && !eof)
			{
				if (fread(&regset, sizeof(u8), 1, SFile))
				{
					if (!regset)
					{
						printf("Delay %d.%dms\n", Delay/1000, (Delay/100)%10);
						delaytimer=sample+Delay;
						update=0;
					}
					else if (regset==255)
					{
						update=0;
						Run=0;
					}
					else if (regset==17)
					{
						u32 value;
						if (fread(&value, sizeof(u32), 1, SFile) != 1) { printf("Error: Sequence read error\n"); return; }
						Delay=value;
						printf("Delay: %d\n", Delay);
					}
					else
					{
						u8 reg; u32 value;
						if (fread(&reg, sizeof(u8), 1, SFile) != 1) { printf("Error: Sequence read error\n"); return; }
						if (fread(&value, sizeof(u32), 1, SFile) != 1) { printf("Error: Sequence read error\n"); return; }

						SetReg(regset, reg, value);
					}
				}
				else { printf("End of sequence file\n"); eof=1; }
			}
		}

		//5000 SampleRate * 20 = 1,000,000 (1GHz) Update Frequency 
		for (int i=0; i<20; i++) { Tick(); sample++; }
		Output(); 
	}

	printf("Finished Sequence\n");
}


