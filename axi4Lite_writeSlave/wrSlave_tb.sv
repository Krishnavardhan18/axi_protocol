`timescale 1ns/1ps

module tb_wrSlave;

    logic clk;
    logic rst;
    logic start;
    logic done;

    logic [31:0] AWADDR;
    logic AWVALID;
    logic AWREADY;

    logic [31:0] WDATA;
    logic WVALID;
    logic WREADY;

    logic BVALID;
    logic [1:0] BRESP;
    logic BREADY;
    
    wrSlave dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        .WDATA(WDATA),
        .WVALID(WVALID),
        .WREADY(WREADY),
        .BVALID(BVALID),
        .BRESP(BRESP),
        .BREADY(BREADY)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; //100MHz clock
    end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_wrSlave);
        rst = 0;
        start = 0;
        AWADDR = 0;
        AWVALID = 0;
        WDATA = 0;
        WVALID = 0;
        BREADY = 0;

        #20;
        rst = 1;

        #20;
        start = 1;
        AWADDR = 32'h0000_1234;
        WDATA  = 32'hABCD_EF01;
        AWVALID = 1;
        WVALID = 1;

        #10;
        //wait for AWREADY and WREADY to be seen
        //assume handshake done in one cycle
        AWVALID = 0;
        WVALID = 0;

        wait (BVALID == 1);
        BREADY = 1;
        #10;
        BREADY = 0;
        #50;
        $display("Test completed");
        $finish;
    end

/*FIXME: KRISHNA: Assertion Property to check AWVALID deassertion followed by BVALID assertion*/
    property p_awvalid_bvalid_handshake;
        @(posedge clk)
        disable iff (rst)
        AWVALID == 0 |-> (BVALID == 1);
    endproperty

    assert property (p_awvalid_bvalid_handshake)
        else $fatal("AWVALID not properly followed by BVALID.");
        
/*FIXME: KRISHNA: This covergroup checks: "Was the write address phase ever started?"*/
    covergroup cg_awvalid_assertion @(posedge clk);
        AWVALID : coverpoint AWVALID;
    endgroup

    covergroup cg_bvalid_assertion @(posedge clk);
        BVALID : coverpoint BVALID;
    endgroup
    cg_awvalid_assertion cg_awvalid = new;
    cg_bvalid_assertion cg_bvalid = new;

endmodule
