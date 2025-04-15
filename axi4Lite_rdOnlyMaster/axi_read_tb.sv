`timescale 1ns/1ps

module axi_read_tb;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    // Clock and Reset
    logic clk, rst;

    // Master-Side Signals
    logic start, done;
    logic [ADDR_WIDTH-1:0]   ARADDR;
    logic                    ARVALID;
    logic                    RREADY;
    logic [DATA_WIDTH-1:0]   READ_DATA;

    // Slave-Side Signals
    logic                    ARREADY;
    logic                    RVALID;
    logic [DATA_WIDTH-1:0]   RDATA;
    logic [1:0]              RRESP;

    // Clock Generation
    always #5 clk = ~clk;

    // DUT: Read-Only AXI4-Lite Master
    master_fsm #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut_master (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .READ_DATA(READ_DATA),
        .RREADY(RREADY),
        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID)
    );

    // Dummy AXI4-Lite Slave
    dummy_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut_slave (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(), // not used
        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .RREADY(RREADY),
        .ARREADY(ARREADY),
        .RVALID(RVALID),
        .RDATA(RDATA),
        .RRESP(RRESP)
    );

    // Test Sequence
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, axi_read_tb);

        // Initialize
        clk = 0;
        rst = 0;
        start = 0;

        // Reset Pulse
        #10 rst = 1;
        #10 rst = 0;
        #10 rst = 1;

        // Start AXI Read
        #10 start = 1;
        #20 start = 0;

        // Wait for DONE
        wait(done);

        $display("[TB] Read Completed. Data Received = %h", READ_DATA);

        #20 $finish;
    end

endmodule
