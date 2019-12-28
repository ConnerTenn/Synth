
import matplotlib.pyplot as plt
from scaleTest import scale
from math import *
import sys

legend=[]

ifile=open(sys.argv[1], "r")



print("reading samples from " + sys.argv[1])

i=0
samples=[]
for l in ifile:
	try:
		samples+=[int(l)]
		i+=1
	except:
		pass
print("Plotting {} samples...".format(i))
print()

handle,=plt.plot(samples, label="Src"); legend+=[handle]

plt.legend(handles=legend)

print("Show")
plt.show()


