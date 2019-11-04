
SampleRate=44800
UpdateFreq=1000000
Bits=24

out=[]
for n in range(1,92+1):
	f=(2**((n-49)/12))*440
	i=round((f*(2**Bits))/UpdateFreq)
	print("Note: "+str(n)+"  Freq: "+str(round(f,3))+"  Incr:"+str(i))
	out+=[i]

n=1
for i in out:
	print(str(i)+",", end=('\n' if n%12==0 else ''))
	n+=1
print()
