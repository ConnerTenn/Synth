
import matplotlib.pyplot as plt
from scaleTest import scale
from math import *

src=[]
for i in range(0,1000):
	if i%200>100:
		src+=[255]
	else:
		src+=[0]
	#src += [ 1 if i>500 else 0]


plt.plot(src)

out=[]
f=0
v=0
for s in src:
	out+=[f]
	d=s-f
	# if d>0:
	# 	v+=0.01
	# elif d<0:
	# 	v-=0.01
	# v=v*0.8
	v+=0.05*d
	v=v*0.9
	f+=v
plt.plot(out)

out=[]
f=0
v=0
for s in src:
	out+=[f]
	d=s-f
	v+=0.001*d
	v=v*0.9
	f+=v
plt.plot(out)

out2=[]
f=0
v=0
for s in out:
	out2+=[f]
	d=s-f
	v+=0.001*d
	v=v*0.9
	f+=v
plt.plot(out2)


out=[]
f=0
v=0
for s in src:
	out+=[f]
	d=s-f
	# if d>0:
	# 	v+=0.01
	# elif d<0:
	# 	v-=0.01
	# v=v*0.8
	v+=int(0.2*(s-f))
	v=(v>>1)+(v>>2)
	f+=v
plt.plot(out)

pi=3.14159265358979323

# out=[]
# d=10
# for i in range(0,len(src)):
# 	s=0
# 	for j in range(0,len(src)):
# 		s += src[j] *  ( (sin(pi*(i-j)/d)/(pi*(i-j)/d)) if i-j!=0 else 1) #sinc
# 	s = s/(d)
# 	out+=[s]
# plt.plot(out)

out=[]
d=10
for i in range(0,len(src)):
	s=src[i]
	for j in range(0,i):
		s += 2*src[j] * ( sin(pi*(i-j)/d) / (pi*(i-j)/d) ) #sinc
	s = s/(d)
	out+=[s]
plt.plot(out)

out=[127,127,127,127,127]
# dt=2
# rc=-0.5
# a=dt/(rc+dt)
a=1.5#0.01
for i in range(1,len(src)):
	s=src[i]
	out+=[ a*src[i] + (1-a)*out[i-6] ]

plt.plot(out)

plt.legend(["Src", "Damped Filter", "1st order", "2nd order", "kindabitwise"''', "noncausal"''', "causal", "wiki"])
plt.show()


