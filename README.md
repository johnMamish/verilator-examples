# verilator testbench examples

[Verilator](https://www.veripool.org/wiki/verilator) is a tool which converts synthesizable Verilog into c++ code that simulates the described circuits, which can then be compiled. By being compiled instead of interpreted, Verilator outperforms interpreted tools like iverilog by a factor of 10 - 100.

The downside to Verilator is that - because Verilator only works on synthesizable Verilog code - you can't write behavioral testbenches and run them with verilator. To test your "verilated" designs, you need to write a "testbench" in c++ that can interface with the c++ code that Verilator generated for your design.

This repo contains example Verilator "testbenches".
