import sys

if (len(sys.argv)!=3):
	print("Error: command must be in format parse.py [in file] [outfile]")
	exit(0)


ifile=open(sys.argv[1], "r")
ofile=open(sys.argv[2], "wb")

#lines = f.readlines()

notes={
	"A0" :231  ,"A$0":244  ,"B0" :259  ,"C0" :274  ,"C$0":291  ,"D0" :308  ,"D$0":326  ,"E0" :346  ,"F0" :366  ,"F$0":388  ,"G0" :411  ,"G$0":435  ,
	"A1" :461  ,"A$1":489  ,"B1" :518  ,"C1" :549  ,"C$1":581  ,"D1" :616  ,"D$1":652  ,"E1" :691  ,"F1" :732  ,"F$1":776  ,"G1" :822  ,"G$1":871  ,
	"A2" :923  ,"A$2":978  ,"B2" :1036 ,"C2" :1097 ,"C$2":1163 ,"D2" :1232 ,"D$2":1305 ,"E2" :1383 ,"F2" :1465 ,"F$2":1552 ,"G2" :1644 ,"G$2":1742 ,
	"A3" :1845 ,"A$3":1955 ,"B3" :2071 ,"C3" :2195 ,"C$3":2325 ,"D3" :2463 ,"D$3":2610 ,"E3" :2765 ,"F3" :2930 ,"F$3":3104 ,"G3" :3288 ,"G$3":3484 ,
	"A4" :3691 ,"A$4":3910 ,"B4" :4143 ,"C4" :4389 ,"C$4":4650 ,"D4" :4927 ,"D$4":5220 ,"E4" :5530 ,"F4" :5859 ,"F$4":6207 ,"G4" :6577 ,"G$4":6968 ,
	"A5" :7382 ,"A$5":7821 ,"B5" :8286 ,"C5" :8779 ,"C$5":9301 ,"D5" :9854 ,"D$5":10440,"E5" :11060,"F5" :11718,"F$5":12415,"G5" :13153,"G$5":13935,
	"A6" :14764,"A$6":15642,"B6" :16572,"C6" :17557,"C$6":18601,"D6" :19708,"D$6":20879,"E6" :22121,"F6" :23436,"F$6":24830,"G6" :26306,"G$6":27871,
	"A7" :29528,"A$7":31284,"B7" :33144,"C7" :35115,"C$7":37203,"D7" :39415,"D$7":41759,"E7" :44242,"F7" :46873,"F$7":49660,"G7" :52613,"G$7":55741,
	}

waveforms={"SAW":0,"SQU":1,"TRI":2,"RND":3,"SIN":4,"SAM":5}

cmdout=[] #command list to be written

regnames={"null":0, "oscillator":0, "incr":1, "waveform":2, "attack":3, "decay":4, "sustain":5, "release":6, "trigger":7, "pulsewidth":8, "volume":10}
def setcmd(regset,name,value): #3 value command
	global cmdout
	cmdout+=[ [regset,regnames[name], value] ]

def setcmd2(regset,value): #2 value command
	global cmdout
	cmdout+=[ [regset, value] ]

def setcmd1(regset): #1 value command
	global cmdout
	cmdout+=[ [regset] ]

def parseint(numstr, hx=True):
	numstr=numstr.strip()
	try:
		return int(numstr)
	except:
		if hx:
			try:
				return int(numstr, 16)
			except:
				return numstr
		else:
			return numstr

nodel=False #no delay

lines=[]
for line in ifile:
	lines+=line.strip().split("#")[0].split("|")

for line in lines:
	for cmd in line.split(";"):
		cmd=cmd.strip().upper()
		if len(cmd):
			nodel=False #only reset after a valid command
			voice="0"; ins=""; arg=[]
			s=cmd.split(":") #seperate into 2 sections
			
			voices=s[0].split(",") #allow multiple voices at once
			
			if len(s)==2:#Should almost always be true
				s=s[1].split(",") 
				ins=s[0] #instruction
				if len(s)>=2:
					arg=s[1:] #list of comma arguments
			
			for voice in voices: #do for each voice
				voice=parseint(voice)
				
				if voice=="DELAY":
					setcmd2(17,parseint(ins))
				elif ins.upper() in waveforms:
					#cmdout+=[ [voice,waveforms[ins.upper()]] ]
					setcmd(voice+1,"waveform",waveforms[ins.upper()])
				elif type(parseint(ins,False))==type(0):
					if len(arg)>0:
						setcmd(voice+1,"incr",parseint(ins,False))
					else:
						#cmdout+=[ [voice,notes[ins]] ]
						setcmd(voice+1,"oscillator",0)
						setcmd(voice+1,"incr",parseint(ins,False))
						setcmd(voice+1,"trigger",1)
				elif ins in notes:
					if len(arg)>0:
						setcmd(voice+1,"incr",notes[ins])
					else:
						#cmdout+=[ [voice,notes[ins]] ]
						setcmd(voice+1,"oscillator",0)
						setcmd(voice+1,"incr",notes[ins])
						setcmd(voice+1,"trigger",1)
				elif ins=="OFF":
					setcmd(voice+1,"trigger",0)
				elif ins=="STOP":
					setcmd(voice+1,"trigger",0)
					setcmd(voice+1,"oscillator",0)
					setcmd(voice+1,"incr",0)
				elif ins=="VOL":
					setcmd(voice+1,"volume",parseint(arg[0]))
				elif ins=="ADSR":
					setcmd(voice+1,"attack",parseint(arg[0]))
					setcmd(voice+1,"decay",parseint(arg[1]))
					setcmd(voice+1,"sustain",parseint(arg[2]))
					setcmd(voice+1,"release",parseint(arg[3]))
				elif ins=="PW":
					setcmd(voice+1,"pulsewidth",parseint(arg[0]))
				elif cmd=="\\":
					nodel=True
				elif cmd=="END":
					setcmd1(255)

				print("\"{}\"  [{}]:{} {}".format(cmd,voice,ins,arg))
	if len(line) and not nodel:
		setcmd1(0)
		print()


print(cmdout)

for cmd in cmdout:
	if len(cmd)==1:
		ofile.write(cmd[0].to_bytes(1,"little"))
	if len(cmd)==2:
		ofile.write(cmd[0].to_bytes(1,"little"))
		ofile.write(cmd[1].to_bytes(4,"little"))
	if len(cmd)==3:
		ofile.write(cmd[0].to_bytes(1,"little"))
		ofile.write(cmd[1].to_bytes(1,"little"))
		ofile.write(cmd[2].to_bytes(4,"little"))

