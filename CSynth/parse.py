import sys

f=open(sys.argv[1], "r")

#lines = f.readlines()

notes={"A":0,"B":1,"C":2,"D":3,"E":4,"F":5,"G":6}

notes={
	"A0" :231  ,"A#0":244  ,"B0" :259  ,"C0" :274  ,"C#0":291  ,"D0" :308  ,"D#0":326  ,"E0" :346  ,"F0" :366  ,"F#0":388  ,"G0" :411  ,"G#0":435  ,
	"A1" :461  ,"A#1":489  ,"B1" :518  ,"C1" :549  ,"C#1":581  ,"D1" :616  ,"D#1":652  ,"E1" :691  ,"F1" :732  ,"F#1":776  ,"G1" :822  ,"G#1":871  ,
	"A2" :923  ,"A#2":978  ,"B2" :1036 ,"C2" :1097 ,"C#2":1163 ,"D2" :1232 ,"D#2":1305 ,"E2" :1383 ,"F2" :1465 ,"F#2":1552 ,"G2" :1644 ,"G#2":1742 ,
	"A3" :1845 ,"A#3":1955 ,"B3" :2071 ,"C3" :2195 ,"C#3":2325 ,"D3" :2463 ,"D#3":2610 ,"E3" :2765 ,"F3" :2930 ,"F#3":3104 ,"G3" :3288 ,"G#3":3484 ,
	"A4" :3691 ,"A#4":3910 ,"B4" :4143 ,"C4" :4389 ,"C#4":4650 ,"D4" :4927 ,"D#4":5220 ,"E4" :5530 ,"F4" :5859 ,"F#4":6207 ,"G4" :6577 ,"G#4":6968 ,
	"A5" :7382 ,"A#5":7821 ,"B5" :8286 ,"C5" :8779 ,"C#5":9301 ,"D5" :9854 ,"D#5":10440,"E5" :11060,"F5" :11718,"F#5":12415,"G5" :13153,"G#5":13935,
	"A6" :14764,"A#6":15642,"B6" :16572,"C6" :17557,"C#6":18601,"D6" :19708,"D#6":20879,"E6" :22121,"F6" :23436,"F#6":24830,"G6" :26306,"G#6":27871,
	"A7" :29528,"A#7":31284,"B7" :33144,"C7" :35115,"C#7":37203,"D7" :39415,"D#7":41759,"E7" :44242,"F7" :46873,"F#7":49660,"G7" :52613,"G#7":55741,
	}

waveforms={"saw":0,"squ":1,"tri":2,"rnd":4,"sin":3,"sam":5}

cmdout=[]
for line in f:
	line=line.split("#")[0]
	for cmd in line.split(";"):
		cmd=cmd.strip()
		if len(cmd):

			voice,ins=cmd.split(":")
			voice=int(voice)

			if ins in waveforms:
				cmdout+=[ [voice,waveforms[ins]] ]
			if ins in notes:
				cmdout+=[ [voice,notes[ins]] ]

			print(cmd)
	if len(line):
		cmdout+=[0]


print(cmdout)

