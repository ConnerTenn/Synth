
import matplotlib.pyplot as plt
from scaleTest import scale

v=0xFF

#Divide by 2
out=[]
for i in range(0,150):
	v=(v>>1)
	out+=[v]
plt.plot(out)

# #Convolution
# v=0xFF
# out=[]
# for i in range(0,150):
# 	v=0
# 	for j in range(100-i):
# 		v+=j/100
# 	v=2*255*v/100
# 	out+=[v]
# plt.plot(out)

# #Repeated scale
# v=0xFF
# out=[]
# for i in range(0,150):
# 	out+=[v]
# 	v=v-(scale(v,10,8)|1)
# plt.plot(out)

v=255
m=4#0
c=0
#Repeated subtract
out=[]
for i in range(0,150):
	out+=[v]
	if (c>=m):
		d=(v>>3)+1
		v-=d
		c=0
		#m+=1
	c+=1
plt.plot(out)
plt.legend()


v=255
d=0
c=0
m=0
#sqrt
out=[]
for i in range(0,150):
	
	vo = d
	if (c>=m):
		m+=1#m=d&(2**5-1)
		d=d+(d>>4)+1
		c=0
	out+=[vo]
	c+=1

plt.plot(out)
plt.legend()

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


#Exponential
out=[]
for i in range(0,150):
	out+=[int(255*(2**(0.05*-i)))]
plt.plot(out)


plt.legend(["Divide by 2", "Repeated Subtract", "sqrt", "Repeated Subtract 2", "Inverse x scale", "Exponential"])
plt.show()
