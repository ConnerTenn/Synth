
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

plt.plot(out)

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


#Buffered Sums
out=[]
buff=[255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
coeff=[[1,1],[1,2],[1,4],[1,4],[2,5]]
for i in range(0,150):
	v=0
	for j in range(0, len(coeff)):
		v += buff[coeff[j][0]]>>coeff[j][1]
	print(v)
	buff = [v]+buff[:-1]
	out += [v]

plt.plot(out)

#Overlapping differences
out=[]
v=255
s1=4
s2=s1-1
t=15
tm=15
tc=0
for i in range(0,150):
	out+=[v]
	print("s1:{} s2:{}  t:{} tc:{} tm:{}".format(s1,s2,t,tc,tm))
	if tc<=t:
		v-=s1
	else:
		v-=s2
	
	tc+=1
	if (tc>tm):
		tc=0
		t-=1
	if(t<0):
		tm+=1
		t=tm
		s1=s2
		s2=s1-1

plt.plot(out)


#LinearBastart
out=[]
dx=255
dy=255
D=2*dy-dx
y=0
for x in range(0,1000):
	out+=[y]
	print(dx)
	if D > 0:
		y = y + 1
		D = D - 2*dx
		dx=dx+255
	D = D + 2*dy

plt.plot(out)

#True Exponential
out=[]
for i in range(0,150):
	out+=[int(255*(2**(0.05*-i)))] # out = 255 * 2^(0.05*(-i))
	
plt.plot(out)


plt.legend(["Repeated Subtract", "Repeated Subtract 2", "Inverse x scale", "Double V", "Buffered Sums", "Overlapping differences", "LinearBastart", "Exponential"])
plt.show()

p=255
for i in range(0,255):
	v=int(255*2**(-i/50))
	d=p-v
	print(" {:08b}  | {:2d} | {:7s}".format(v, d, " "*(7-d)+str(d)))
	p=v

'''
New algorithm?:

base_subtract_value
occasional_period
next_value = value - base_subtract_value - (1 if occasional_period else 0)
occasional_period++
if occasional_period > too_long: reset occasional_period


-----,                                                            
      `-----,                                                     
             \                                                    
==================================================================
             ,------,                                             
      ,-----`        `--------,                                   
     /                         \                                  
==================================================================
                               ,---------,                        
                     ,--------`           `----------,            
                    /                                 \           
==================================================================
                                                      ,-----------
                                          ,----------`            
                                         /                        

Rate Counter
	Updated every cycle

A Sub Val
B Sub Val

Transition Variable


Transition variable increments 

'''
