`timescale 1ns/1ps

module axi_read_tb;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    logic clk, rst;
    logic start, done;
    logic [ADDR_WIDTH-1:0]   ARADDR;
    logic                    ARVALID;
    logic                    RREADY;
    logic [DATA_WIDTH-1:0]   READ_DATA;

    logic                    ARREADY;
    logic                    RVALID;
    logic [DATA_WIDTH-1:0]   RDATA;
    logic [1:0]              RRESP;

    always #5 clk = ~clk;

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
    dummy_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut_slave (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(), //not used
        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .RREADY(RREADY),
        .ARREADY(ARREADY),
        .RVALID(RVALID),
        .RDATA(RDATA),
        .RRESP(RRESP)
    );

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, axi_read_tb);

        clk = 0;
        rst = 0;
        start = 0;

        #10 rst = 1;
        #10 rst = 0;
        #10 rst = 1;

        #10 start = 1;
        #20 start = 0;

        wait(done);

        $display("[TB] Read Completed. Data Received = %h", READ_DATA);

        #20 $finish;
    end

endmodule
