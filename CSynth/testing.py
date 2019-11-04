
def scale(n, s, bits):
	r=0
	for i in range(0,bits):
		en=(1 if s&(1<<(bits-i-1)) else 0)
		val=(n>>i)
		#print(">>"+str(i)+" "+"{:08b}".format(1<<(8-i-1))+" "+str(en)+" "+"{:3d}".format(val)+" "+"{:08b}".format(val))
		r=r+en*val
	return r

l1=-1
l2=-1
l3=-1
print()
print("Integer Scaling  Integer Scaling  Decimal Scaling")
print("Scale | Val | D  Scale | Val | D  Scale | Val | D")
print("---------------  ---------------  ---------------")
n=100 #100
for i in range(0xFF,-1,-1):
	v1=scale(n,i,8)
	v2=scale((n<<1)+(1<<1),i,9)>>1
	v3=round(i*n/0xFF)
	print(" {:3d}  | {:3d} | {:1s}".format(i, v1, (str(l1-v1) if l1>=0 else "")), end="")
	print("  ",end="")
	print(" {:3d}  | {:3d} | {:1s}".format(i, v2, (str(l2-v2) if l2>=0 else "")), end="")
	print("  ",end="")
	print(" {:0.2f} | {:3d} | {:1s}".format(i/255, v3, (str(l3-v3) if l3>=0 else "")), end="")
	print()
	l1=v1
	l2=v2
	l3=v3

print()
