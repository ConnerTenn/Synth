
#SampleRate=44800
UpdateFreq=1000000
Bits=24

notes=["A","A$","B","C","C$","D","D$","E","F","F$","G","G$"]
out=[]
for n in range(0,95+1):
	f=(2**((n-60)/12))*440
	i=round((f*(2**Bits))/UpdateFreq)
	print("Note: "+notes[n%12]+str(int(n/12))+" ("+str(n)+")  Freq: "+str(round(f,3))+"  Incr:"+str(i))
	out+=[i]

print("{")
for i in range(0,len(out)):
	print("{:5}".format("\""+notes[i%12]+str(int(i/12))+"\"")+":{:<5}".format(out[i])+",", end=('\n' if i%12==11 else ''))
print("}")
