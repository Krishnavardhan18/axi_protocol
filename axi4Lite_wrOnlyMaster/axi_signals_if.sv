interface axi_signals_if #(
    parameter ADDR_WIDTH = 32, 
    parameter DATA_WIDTH = 32, 
    parameter STRB_WIDTH = DATA_WIDTH/8)
    (input pclk);
    
    //wr_addr_channel
    logic [ADDR_WIDTH-1:0]  AWADDR;
    logic                   AWVALID;
    logic                   AWREADY;

    //wr_data_channel
    logic [DATA_WIDTH-1:0]  WDATA;
    logic [STRB_WIDTH-1:0]  WSTRB;
    logic                   WVALID;
    logic                   WREADY;

    //resp_channel
    logic [1:0]             BRESP;
    logic                   BVALID;
    logic                   BREADY;

    modport master (
        output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY,
        input AWREADY, WREADY, BVALID, BRESP
    );

    modport slave (
        input AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY,
        output AWREADY, WREADY, BVALID, BRESP
    );
endinterface