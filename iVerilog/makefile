

.PHONY: all TopBench runTop FilterBench runFilter

# all: clean TopBench 


WaveBench: clean
	iverilog -s WaveBench *.v -o WaveBench

runWave: WaveBench
	@echo -e "\033[32;1mBegin Simulation\033[0m"
	@echo
	@vvp WaveBench
	@echo
	@echo -e "\033[32;1mEnd Simulation\033[0m"

ADSRBench: clean
	iverilog -s ADSRBench *.v -o ADSRBench


runADSR: ADSRBench
	@echo -e "\033[32;1mBegin Simulation\033[0m"
	@echo
	@vvp ADSRBench
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

