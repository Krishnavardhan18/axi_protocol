TOP_MODULE = axi_write_tb
SRC = dummy_slave.sv master_fsm.sv axi_read_tb.sv
OUT = sim.out
VCD = waveform.vcd

all: run

compile:
	iverilog -g2012 -o $(OUT) $(SRC)

run: compile
	vvp $(OUT)

waves:
	gtkwave $(VCD) &

clean:
	rm -f $(OUT) $(VCD)
