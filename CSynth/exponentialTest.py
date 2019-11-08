
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

#Repeated scale
v=0xFF
out=[]
for i in range(0,150):
	out+=[v]
	
	v=int(v*0.96)
plt.plot(out)
plt.legend()

#Exponential
out=[]
for i in range(0,150):
	out+=[int(255*(2**(0.05*-i)))]
plt.plot(out)


plt.legend(["Divide by 2", "Repeated Subtract", "Repeated Scale", "Exponential"])
plt.show()
