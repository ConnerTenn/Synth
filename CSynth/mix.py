
from math import *
import matplotlib.pyplot as plt
from scaleTest import scale

v=0xFF


out=[[],[],[]]
for i in range(0,250):
	a=round(10*sin(i*2*3.14159265458979323/51))
	b=round(10*sin(i*2*3.14159265458979323/77))
	out[0]+=[a]
	out[1]+=[b]
	out[2]+=[(a+b)/2]

plt.plot(out[0])
plt.plot(out[1])
plt.plot(out[2])
plt.legend(["A","B","A&B"])
plt.show()
