`timescale 1ns/1ps

module axi_write_tb();
    logic clk, rst, start;
    logic done_master, done_slave;

    // AXI Master to Slave Signals
    logic [31:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;

    logic [31:0] WDATA;
    logic [3:0]  WSTRB;
    logic        WVALID;
    logic        WREADY;

    logic        BREADY;
    logic        BVALID;
    logic [1:0]  BRESP;

    // Clock Generation
    always #5 clk = ~clk;

    // DUT Instantiation
    master_fsm master_inst(
        .clk(clk), .rst(rst), .start(start), .done(done_master),
        .AWADDR(AWADDR), .AWVALID(AWVALID), .AWREADY(AWREADY),
        .WDATA(WDATA), .WSTRB(WSTRB), .WVALID(WVALID), .WREADY(WREADY),
        .BREADY(BREADY), .BVALID(BVALID), .BRESP(BRESP)
    );

    dummy_slave slave_inst(
        .clk(clk), .rst(rst), .start(start), .done(done_slave),
        .AWADDR(AWADDR), .AWVALID(AWVALID), .AWREADY(AWREADY),
        .WDATA(WDATA), .WSTRB(WSTRB), .WVALID(WVALID), .WREADY(WREADY),
        .BREADY(BREADY), .BVALID(BVALID), .BRESP(BRESP)
    );

    // Test Procedure
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, axi_write_tb);

        // Initialize signals
        clk = 0;
        rst = 0;
        start = 0;

        // Reset Pulse
        #10; rst = 1;
        #10;

        // Start AXI transaction
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for master to complete transaction
        wait(done_master);
        $display("AXI WRITE TRANSACTION COMPLETED BY MASTER.");

        wait(done_slave);
        $display("AXI WRITE TRANSACTION ACKNOWLEDGED BY SLAVE.");
        $dumpfile("waveform.vcd");
        $dumpvars(0, axi_write_tb);

        #20;
        $finish;
    end
endmodule
