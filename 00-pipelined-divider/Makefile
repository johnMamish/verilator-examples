all: pipelined_divider_tb.vvd verilator

pipelined_divider_tb.vvd: pipelined_divider.v pipelined_divider_tb.v
	iverilog pipelined_divider.v pipelined_divider_tb.v -Wall -o pipelined_divider_tb.vvd

verilator: pipelined_divider.v #pipelined_divider_tb.cpp
	@echo TODO
