
import matplotlib.pyplot as plt
from scaleTest import scale
from math import *

legend=[]

print("Generating Samples")
src=[]
for i in range(0,10000):
	if i%2000>1000:
		src+=[255]
	else:
		src+=[0]
	#src += [ 1 if i>500 else 0]

handle,=plt.plot(src, label="Src"); legend+=[handle]

# print("Filter 1")
# out=[]
# d=50
# for i in range(0,len(src)):
# 	s=src[i]
# 	for j in range(0,i):
# 		s += 2*src[j] * ( sin(pi*(i-j)/d) / (pi*(i-j)/d) ) #sinc
# 	s = s/(d)
# 	out+=[s]
# handle,=plt.plot(out, label="causal"); legend+=[handle]


print("Filter 2")
out=[]
d=100
skip=4
sinc=[1/d]
for i in range(1,255):
	sinc += [ ( sin(pi*(i)/d) / (pi*(i)/d) )/d ] #sinc

for i in range(0,len(src)):
	s=sinc[0]*src[i]
	for j in range(1,len(sinc)):
		if i-skip*j >= 0:
			s += 2*src[i-skip*j] * sinc[j]
	out+=[s]
handle,=plt.plot(out, label="FiniteFilterSystem"); legend+=[handle]

print("Filter 3")
out=[src[0]]
a=0.001
for i in range(1,len(src)):
	out+=[ a*src[i] + (1-a)*out[i-1] ]
handle,=plt.plot(out, label="2ValFilter"); legend+=[handle]

plt.legend(handles=legend)


print("Show")
plt.show()


