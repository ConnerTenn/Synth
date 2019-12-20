
import matplotlib.pyplot as plt
from scaleTest import scale
from math import *

legend=[]

src=[]
for i in range(0,1500):
	if i%200>100:
		src+=[255]
	else:
		src+=[0]
	#src += [ 1 if i>500 else 0]

handle,=plt.plot(src, label="Src"); legend+=[handle]

out=[]
d=2
for i in range(0,len(src)):
	s=src[i]
	for j in range(0,i):
		s += 2*src[j] * ( sin(pi*(i-j)/d) / (pi*(i-j)/d) ) #sinc
	s = s/(d)
	out+=[s]
handle,=plt.plot(out, label="causal"); legend+=[handle]

out=[]

d=2
sinc=[1]
for i in range(1,256):
	sinc += [ sin(pi*(i)/d) / (pi*(i)/d) ] #sinc

for i in range(0,len(src)):
	s=sinc[0]*src[i]
	for j in range(1,len(sinc)):
		if i-j >= 0:
			s += 2*src[i-j] * sinc[j]
	s = s/(d)
	out+=[s]
handle,=plt.plot(out, label="FiniteFilterSystem"); legend+=[handle]

plt.legend(handles=legend)

plt.show()


