
#ifndef __GLOBALS_H_
#define __GLOBALS_H_

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define MIN(a,b) ((a)<=(b)?(a):(b))
#define MAX(a,b) ((a)>=(b)?(a):(b))
#define ABS(a) ((a)<0?-(a):(a))
#define PI (3.14159265358979323L)
#define TAU (2.0*PI)
#define MOD(a,b) ((a)%(b)+((a)<0?(b):0))
#define CEILDIV(a,b) ( (((long int)(a))/((long int)(b))) + (((long int)(a))%((long int)(b))?1:0))

#define ARRACC(buff,x,y,width,size,type) *(type)((buff)+(y)*(width)*(size)+(x)*(size))


typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long u64;
typedef char i8;
typedef short i16;
typedef int i32;
typedef long i64;

extern u8 Run;

union Ksequ
{
	u8 seq[8];
	u32 val;
};

int kbhit();
u8 getch();

void set_conio_terminal_mode();
void reset_terminal_mode();

#endif

