
import matplotlib.pyplot as plt
from scaleTest import scale

value=255
maximum=4
counter=0
#Repeated subtract
out=[] #list of output points
for i in range(0,150):
	out+=[value]
	if (counter>=maximum): #after counter overflows, 
		decrement = (value>>3)+1 # value/8 + 1
		value = value - decrement
		counter = 0 #Reset counter
	counter += 1 #increment counter


v=255
s=0
d=0
dx=0
dy=10
c=0
#Repeated subtract 2
out=[]
for i in range(0,150):
	out+=[v-d]
	if s==0:
		d+=dy
		dy-=1
	else:
		#d+=1
		if c>=dx:
			dx+=1
			d+=1
			c=0
		c+=1
	if dy==0: s=1

plt.plot(out)
plt.legend()

v=255
c=0
m=0
#Inverse x scale
out=[]
for i in range(0,150):
	out+=[v]
	if (c>=m):
		m=255-v
		v-=1
		c=0
	c+=1

plt.plot(out)
plt.legend()

v=255
corner=5
c=0
#Double V
out=[]
for i in range(0,150):
	out+=[v]
	u=(v>>corner)
	l=(2**corner) - (v&(2**corner)-1)
	if u:
		v-=u
	else:
		if (c>=l):
			v-=1
			c=0
		c+=1

plt.plot(out)
plt.legend()


#True Exponential
out=[]
for i in range(0,150):
	out+=[int(255*(2**(0.05*-i)))] # out = 255 * 2^(0.05*(-i))
	
plt.plot(out)


plt.legend(["Repeated Subtract", "Repeated Subtract 2", "Inverse x scale", "Double V", "Exponential"])
plt.show()
