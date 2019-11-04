
//#include <math.h>
#include <signal.h>
#include "globals.h"
#include "audioiface.h"
#include "synth.h"

u8 Run=1;


u8 Octave=2;
char Keys[127];
char KeyMap[][2] = 
	{
		{'a', 0}, //A
		{'w', 1}, //A#
		{'s', 2}, //B
		{'d', 3}, //C
		{'r', 4}, //C#
		{'f', 5}, //D
		{'t', 6}, //D#
		{'g', 7}, //E
		{'h', 8}, //F
		{'u', 9}, //F#
		{'j', 10}, //G
		{'i', 11}, //G#

		{'k', 12}, //A
		{'o', 13}, //A#
		{'l', 14}, //B
		{';', 15}, //C
		{'[', 16}, //C#
		{'\'', 17}, //D
		{']', 18}, //D#
		{'\\', 19}, //E
	};

u16 NoteMap[] = 
	{
		40,43,45,48,51,54,57,60,64,68,72,76,
		80,85,90,96,101,107,114,121,128,135,143,152,
		161,170,181,191,203,215,228,241,255,271,287,304,
		322,341,361,383,405,430,455,482,511,541,573,608,
		644,682,722,765,811,859,910,964,1022,1082,1147,1215,
		1287,1364,1445,1531,1622,1718,1821,1929,2043,2165,2294,2430
	};

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>


void PlayKey(u8 key)
{
	u8 keyNum = -1;
	for (int i=0; i<20; i++) { if (key==KeyMap[i][0]) { keyNum=KeyMap[i][1]+12*Octave; } }
	if (keyNum!=(u8)-1)
	{
		INCR=NoteMap[keyNum];
		WC=0;
		printf("Play %d [%d]  %d\n", keyNum+1, Octave+1, INCR);
	}
	else
	{
		INCR=0;
		WC=32768;
	}
}
void HandleKeyEvent(u8 key, u8 press)
{
	if (press)
	{
		if (key=='.' && Octave<5) { Octave++; printf("Octave %d\n", Octave+1); }
		if (key==',' && Octave>0) { Octave--; printf("Octave %d\n", Octave+1); }
		else
		{
			PlayKey(key);
		}
	}
	else
	{
		u8 key=0;
		for (int i=0; i<127; i++) { if(Keys[i]) {key=i;} }
		if (key)
		{
			PlayKey(key);
		}
		else
		{
			PlayKey(key);
		}
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

		Tick();
		//Tick();
		Output();
		//static u64 i=0;
		//if (i++%50==0) { OV=(OV+1)%800; }
	}

	printf("\nClosing...\n");
	//DestroyPulseAudio();
	reset_terminal_mode();
	printf("\nDone\n");

}
