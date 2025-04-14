# Makefile for AXI4 Lite Write-Only Master simulation

TOP_MODULE = axi_write_tb
SRC = axi_signals_if.sv dummy_slave.sv master_fsm.sv axi_write_tb.sv
OUT = sim.out
VCD = waveform.vcd

all: run

compile:
	iverilog -g2012 -o $(OUT) $(SRC)

run: compile
	vvp $(OUT)

wave:
	gtkwave $(VCD) &

clean:
	rm -f $(OUT) $(VCD)
