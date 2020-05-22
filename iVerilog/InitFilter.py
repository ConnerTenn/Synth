
from math import *

FFilterVals="FilterVals.txt"

try: f = open(FFilterVals, 'w')
except: print("Error opening file \"{0}\"".format(FFilterVals)); exit(-1)
FFilterVals=f

d=10
sinc=[1/d]
for i in range(1,512):
	sinc += [ ( sin(pi*(i)/d) / (pi*(i)/d) )/d ] #sinc

for i in range(0, 0x8000):
    FFilterVals.write("0\n")

for s in sinc:
    binary = round(s*0x100000)
    if binary < 0: binary += (1<<24)
    high = (binary&0xFF0000)>>16
    mid = (binary&0x00FF00)>>8
    low = binary&0x0000FF
    FFilterVals.write(hex(low)[2:] + "\n")
    FFilterVals.write(hex(mid)[2:] + "\n")
    FFilterVals.write(hex(high)[2:] + "\n")
    FFilterVals.write("0\n")
    print("0x{:06X}  [0x{:02X},0x{:02X},0x{:02X}]".format(binary, low, mid, high))

for i in range(0x8000+len(sinc)*4, 0x10000):
    FFilterVals.write("0\n")

FFilterVals.close()

