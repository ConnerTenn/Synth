
//#include <math.h>
#include <signal.h>
#include "globals.h"
#include "audioiface.h"
#include "synth.h"

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>


u8 Run=1;

u8 Octave=2;
char Keys[127];
char KeyMap[][2] = 
	{
		{'a', 0}, //C
		{'w', 1}, //C#
		{'s', 2}, //D
		{'e', 3}, //D#
		{'d', 4}, //E
		{'f', 5}, //F
		{'t', 6}, //F#
		{'g', 7}, //G
		{'y', 8}, //G#
		{'h', 9}, //A
		{'u', 10}, //A#
		{'j', 11}, //B

		{'k', 12}, //C
		{'o', 13}, //C#
		{'l', 14}, //D
		{'p', 15}, //D#
		{';', 16}, //E
		{'\'', 17}, //F
		{']', 18}, //F#
		{'\\', 19}, //G
	};

u32 NoteMap[] = 
	{
		274,291,308,326,346,366,388,411,435,461,489,518,
		549,581,616,652,691,732,776,822,871,923,978,1036,
		1097,1163,1232,1305,1383,1465,1552,1644,1742,1845,1955,2071,
		2195,2325,2463,2610,2765,2930,3104,3288,3484,3691,3910,4143,
		4389,4650,4927,5220,5530,5859,6207,6577,6968,7382,7821,8286,
		8779,9301,9854,10440,11060,11718,12415,13153,13935,14764,15642,16572,
		17557,18601,19708,20879,22121,23436,24830,26306,27871,29528,31284,33144,
		35115,37203,39415,41759,44242,46873,49660,52613,55741,
	};


void PlayKey(u8 key)
{
	u8 keyNum = -1;
	for (int i=0; i<20; i++) { if (key==KeyMap[i][0]) { keyNum=KeyMap[i][1]+12*Octave; } }
	if (keyNum!=(u8)-1)
	{
		NoteOn((Reg){.Bits=24,.Value=NoteMap[keyNum]});
		printf("Play %d [%d]  %d\n", keyNum+1, Octave+1, NoteMap[keyNum]);
	}
	else
	{
		NoteOff();
	}
}
void HandleKeyEvent(u8 key, u8 press)
{
	if (press)
	{
		if (key=='.' && Octave<6) { Octave++; printf("Octave %d\n", Octave+1); }
		if (key==',' && Octave>0) { Octave--; printf("Octave %d\n", Octave+1); }
		PlayKey(key);
	}
	else
	{
		u8 key=0;
		for (int i=0; i<127; i++) { if(Keys[i]) {key=i;} }
		PlayKey(key);
	}
}

Display *Disp;
Window Win;
void InteruptHandler(int arg) { Run=0; }
int main()
{
	signal(SIGINT, InteruptHandler); signal(SIGKILL, InteruptHandler);
	set_conio_terminal_mode();

	Disp = XOpenDisplay(0);
	Win = (Window)atoi(getenv("WINDOWID"));
	XSelectInput(Disp, Win, KeyPressMask | KeyReleaseMask);
	XMapWindow(Disp, Win);
	XFlush(Disp);

	for (int i=0; i<127; i++) { Keys[i]=0; }

	InitPulseAudio();
	InitSynth();

	printf("Octave %d\n", Octave+1);
	//OV=11;
	while(Run) 
	{
		XEvent event;
		while (XPending(Disp))
		{
			XNextEvent(Disp, &event);
			u64 key = (long)XLookupKeysym(&event.xkey, 0);

			if (event.type == KeyPress )
			{
				if (0<=key && key<=127 && Keys[key]==0)
				{
					Keys[key]=1;
					//printf("Press #%ld\n", key);
					HandleKeyEvent(key, 1);
				}
			}
			if (event.type == KeyRelease)
			{
				u8 repeat=0;
				if (XEventsQueued(Disp, QueuedAfterReading))
				{
					XEvent nev;
					XPeekEvent(Disp, &nev);

					if (nev.type==KeyPress && nev.xkey.time==event.xkey.time && nev.xkey.keycode==event.xkey.keycode)
					{
						repeat=1;
					}
				}
				if (0<=key && key<=127 && Keys[key]==1 &&!repeat)
				{
					Keys[key]=0;
					//printf("Release #%ld\n", key);
					HandleKeyEvent(key, 0);
				}
			}

		}

		for (int i=0; i<20; i++) { Tick(); } //5000 SampleRate * 20 = 1000000 MHz Update Frequency

		Output();
	}

	printf("\nClosing...\n");
	DestroyPulseAudio();
	reset_terminal_mode();
	printf("\nDone\n");

}
