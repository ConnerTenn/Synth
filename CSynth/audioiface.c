


#include "audioiface.h"

#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <pulse/simple.h>
#include <pulse/error.h>


pa_simple *PulseStream=0;
int InitPulseAudio() 
{
    /* The Sample format to use */
    static const pa_sample_spec ss = {
			.format = PA_SAMPLE_S16LE,
			.rate = 44800,
			.channels = 1 };
    
	int error;	
    PulseStream = pa_simple_new(NULL, "CSynth", PA_STREAM_PLAYBACK, NULL, "playback", &ss, NULL, NULL, &error);
    if (!PulseStream) 
	{ 
		fprintf(stderr, "pa_simple_new() failed: %s\n", pa_strerror(error)); 
		return -1;
	}
    
}

void DestroyPulseAudio()
{
	int error;	
	if (pa_simple_drain(PulseStream, &error) < 0) 
	{
        fprintf(stderr, ": pa_simple_drain() failed: %s\n", pa_strerror(error));
    }
	if (PulseStream) { pa_simple_free(PulseStream); }
}

u8 PulseBuffer[PULSEBUFSIZE];
u32 PulseBufferI=0;
int PulseWrite(u8 *data, u64 bytes)
{
	int error;

	for (int i=0; i<bytes; i++)
	{
		PulseBuffer[PulseBufferI] = data[i]; PulseBufferI++;

		if (PulseBufferI==PULSEBUFSIZE)
		{
			if (pa_simple_write(PulseStream, PulseBuffer, PULSEBUFSIZE, &error) < 0) 
			{
				fprintf(stderr, "pa_simple_write() failed: %s\n", pa_strerror(error));
				return -1;
			}

			PulseBufferI=0;
		}
	}

	return 0;
}
