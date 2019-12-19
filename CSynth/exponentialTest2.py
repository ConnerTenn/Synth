
import matplotlib.pyplot as plt
from scaleTest import scale

value=255
maximum=20
counter=0
#Repeated subtract
out=[] #list of output points
for i in range(0,2000):
	out+=[value]
	if (counter>=maximum): #after counter overflows, 
		decrement = (value>>4)+1 # value/8 + 1
		value = value - decrement
		counter = 0 #Reset counter
	counter += 1 #increment counter

plt.plot(out)

#DualSword 
out=[]
value=255
maximum=21
mid=-1
method=1
for i in range(0,2000):
	out+=[value]
	if method==1:
		if (counter>=maximum): #after counter overflows, 
			decrement = (value>>4)+1 # value/8 + 1
			value = value - decrement
			counter = 0 #Reset counter
			if decrement==1:
				method=2
				mid=value
				maximum=mid-value+maximum
		counter += 1 #increment counter
	else:
		if (counter>=maximum):
			if (value): value-=1
			counter=0
			maximum+=mid-value
		counter+=1

plt.plot(out)

#True Exponential
out=[]
for i in range(0,2000):
	out+=[int(255*(2**(0.005*-i)))] # out = 255 * 2^(0.05*(-i))
	
plt.plot(out)


plt.legend(["Repeated Subtract", "DualSword", "Exponential"])
plt.show()

