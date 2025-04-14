`timescale 1ns/1ps

module axi_write_tb();
    logic clk, rst, start, done_master, done_slave;

    axi_signals_if axi_if(clk);

    always #5 clk = ~clk;

    master_fsm master_inst(.clk(clk), .rst(rst), .start(start), .done(done_master), .axi(axi_if.master));

    dummy_slave slave_inst(.clk(clk), .rst(rst), .start(start), .done(done_slave), .axi(axi_if.slave));

    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        start = 0;

        // Apply reset
        #20;
        rst = 1;
        #20;

        // Start transaction
        start = 1;
        #20;

        // Timing control for clock edge
        @(posedge clk);

        // Wait for master to complete transaction
        while (!done_master) @(posedge clk);
        $display("AXI WRITE TRANSACTION COMPLETED.");

        // Timing control for clock edge
        @(posedge clk);

        // Wait for master acknowledgment
        while (!done_master) @(posedge clk);
        $display("AXI WRITE TRANSACTION ACKNOWLEDGED BY SLAVE.");

        // Finish simulation with waveform dump
        #20;
        $dumpfile("waveform.vcd");
        $dumpvars(0, axi_write_tb);
        $finish;
    end
endmodule
