

.PHONY: all TestBench run

all: clean TestBench

TestBench:
	iverilog *.v -o TestBench

run: all
	@echo -e "\033[32;1mBegin Simulation\033[0m"
	@echo
	@vvp TestBench
	@echo
	@echo -e "\033[32;1mEnd Simulation\033[0m"

clean:
	rm -f TestBench

