`timescale 1ns/1ps

module dummy_slave #(
    parameter ADDR_WIDTH = 32, 
    parameter DATA_WIDTH = 32, 
    parameter STRB_WIDTH = DATA_WIDTH/8)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic done,

    input logic [ADDR_WIDTH-1:0]  AWADDR,
    input logic                   AWVALID,
    input logic [DATA_WIDTH-1:0]  WDATA,
    input logic [STRB_WIDTH-1:0]  WSTRB,
    input logic                   WVALID,
    input logic                   BREADY,


    output logic                   AWREADY,
    output logic                   WREADY,
    output logic                   BVALID,
    output logic [1:0]             BRESP
    
);

    typedef enum logic [2:0]{
        IDLE, SEND_AR, SEND_WR, SEND_BVALID, DONE
    } state_t;

    state_t cur_state, nxt_state;
    assign done = (cur_state == DONE);
//SEQUENTIAL FSM: this always block tells what to do if rst or not
    always_ff @(posedge clk) begin
        if(!rst) begin
            cur_state <= IDLE;
        end
        else begin
            cur_state <= nxt_state;
        end
    end
//this always comb block tells where to go next on what condition
    always_comb begin
        nxt_state = cur_state;
        case (cur_state)
            IDLE : begin
                if(start) nxt_state = SEND_AR;
                else nxt_state = IDLE;
            end

            SEND_AR : begin
                if(AWVALID) nxt_state = SEND_WR;
                else nxt_state = SEND_AR;
            end

            SEND_WR : begin
                if(WVALID) nxt_state = SEND_BVALID;
                else nxt_state = SEND_WR;
            end

            SEND_BVALID : begin
                nxt_state = DONE;
            end

            DONE    : begin
                nxt_state = DONE;
            end
            default;
        endcase
    end

//this always block does slave function
    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            AWREADY  <= 0;
            WREADY   <= 0;
            BVALID   <= 0;
            BRESP    <= 0; 
        end
        else begin
            AWREADY <= 0;
            WREADY <= 0;
            BVALID  <= 0;
            BRESP   <= 2'b00;

            case (cur_state)
                SEND_AR: begin
                    AWREADY <= 1;
                end

                SEND_WR: begin
                    WREADY  <= 1;
                end

                SEND_BVALID: begin
                    BVALID  <= 1;
                    BRESP   <= 2'b00;
                end
            endcase
        end
    end
endmodule
