
import matplotlib.pyplot as plt
from scaleTest import scale


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


plt.legend(["Src", "Damped Filter", "1st order", "2nd order"])
plt.show()

