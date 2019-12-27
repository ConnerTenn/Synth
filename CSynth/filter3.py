
import matplotlib.pyplot as plt
from scaleTest import scale
from math import *

legend=[]

print("Generating Samples")
src=[]
for i in range(0,500):
	# if i%200>100:
	# 	src+=[255]
	# else:
	# 	src+=[0]
	src += [ 1 if i==100 else 0]

handle,=plt.plot(src, label="Src"); legend+=[handle]



print("Filter 2")
out=[0]
d=20
# sinc=[1/d]
# for i in range(1,255):
# 	sinc += [ ( sin(pi*(i)/d) / (pi*(i)/d) )/d ] #sinc
sinc=[]
for r in range(0,5):
	sinc+=[(1/(r+1)) * 1/d]
	for i in range(1,64):
		sinc+=[ (1/(r+1)) * ( sin(pi*(i)/d) / (pi*(i)/d) )/d ] #sinc
print(len(sinc))

for i in range(0,len(src)):
	s=sinc[0]*src[i]
	for j in range(1,len(sinc)):
		if i-j >= 0:
			s += 2*src[i-j] * sinc[j]
	out+=[s]
handle,=plt.plot(out, label="FiniteFilterSystem"); legend+=[handle]


plt.legend(handles=legend)

print("Show")
plt.show()


