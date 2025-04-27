TOP_MODULE = tb_wrSlave
SRC = wrSlave.sv wrSlave_tb.sv
OUT = sim.out
VCD = waveform.vcd

all: run

compile:
	iverilog -g2012 -Wall -o $(OUT) $(SRC)

run: compile
	vvp $(OUT)

waves:
	gtkwave $(VCD) &

clean:
	rm -f $(OUT) $(VCD)

