
//#include <math.h>
#include <signal.h>
#include <time.h>
#include "globals.h"
#include "audioiface.h"
#include "sequencer.h"
#include "synth.h"



u8 Run=1;

void InteruptHandler(int arg) { Run=0; }
int main(int argc, char **argv)
{
	printf("\nSetting up...\n");
	signal(SIGINT, InteruptHandler); signal(SIGKILL, InteruptHandler);
	//set_conio_terminal_mode();
	srand(time(0));


	InitPulseAudio();
	InitSynth();

	if (argc!=2) { printf("\nError: need input synth file\n"); }
	else
	{
		if (InitSequencer(argv[1]))
		{
			PlaySequence();
		}
	}
	

	printf("\nClosing...\n");
	CloseSequencer();
	DestroyPulseAudio();
	//reset_terminal_mode();
	printf("\nDone\n");

}
