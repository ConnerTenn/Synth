

.PHONY: all TopBench runTop FilterBench runFilter

# all: clean TopBench 

TopBench: clean
	iverilog -s TopBench *.v -o TopBench

runTop: TopBench
	@echo -e "\033[32;1mBegin Simulation\033[0m"
	@echo
	@vvp TopBench
	@echo
	@echo -e "\033[32;1mEnd Simulation\033[0m"

FilterVals.txt:
	python InitFilter.py

FilterBench: clean FilterVals.txt
	iverilog -s FilterBench *.v -o FilterBench

runFilter: FilterBench
	@echo -e "\033[32;1mBegin Simulation\033[0m"
	@echo
	@vvp FilterBench
	@echo
	@echo -e "\033[32;1mEnd Simulation\033[0m"

clean:
	rm -f TopBench FilterBench *.vcd FilterVals.txt

