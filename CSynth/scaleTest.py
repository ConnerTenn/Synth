
def scale(val, s, bits):
	result=0
	for i in range(0,bits):
		en=(1 if s&(1<<(bits-i-1)) else 0) #true  if the (bits-index-1)th bit is set. (bits-index-1) is the index running backwars.
		v=(val>>i) #find the value right-shifted by the index
		#print(">>"+str(i)+" "+"{:08b}".format(1<<(8-i-1))+" "+str(en)+" "+"{:3d}".format(val)+" "+"{:08b}".format(val))
		result=result+en*v #sum the result if the bit first test was true
	return r

if __name__ == "__main__":
	l1=-1
	l2=-1
	l3=-1
	lt=-1
	print()
	print("Integer Scaling    Integer Scaling    Multiply Scale     Decimal Scaling")
	print("Scale | Val | D    Scale | Val | D    Scale | Val | D    Scale | Val | D")
	print("---------------    ---------------    ---------------    ---------------")
	n=255 #100
	for i in range(0xFF,-1,-1):

		v1=scale(n,i,8) #Using scale function
		v2=scale((n<<1)+(1<<1),i,9)>>1 #Using scale function with bit shifts improve approximation
		v3=(n*i+(1<<7))>>8 #fixed point math (uses multiply)
		vt=round(i*n/0xFF) #'True' floating point math

		print(" {:3d}  | {:3d} | {:1s}".format(i, v1, (str(l1-v1) if l1>=0 else "")), end="")
		print("    ",end="")
		print(" {:3d}  | {:3d} | {:1s}".format(i, v2, (str(l2-v2) if l2>=0 else "")), end="")
		print("    ",end="")
		print(" {:3d}  | {:3d} | {:1s}".format(i, v3, (str(l3-v3) if l3>=0 else "")), end="")
		print("    ",end="")
		print(" {:0.2f} | {:3d} | {:1s}".format(i/255, vt, (str(lt-vt) if lt>=0 else "")), end="")
		print()
		l1=v1; l2=v2; l3=v3; lt=vt

	print()
