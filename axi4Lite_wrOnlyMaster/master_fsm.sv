`timescale 1ns/1ps

module master_fsm #(
    parameter ADDR_WIDTH = 32, 
    parameter DATA_WIDTH = 32, 
    parameter STRB_WIDTH = DATA_WIDTH/8)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic done,
    output logic [ADDR_WIDTH-1:0]  AWADDR,
    output logic                   AWVALID,
    output logic [DATA_WIDTH-1:0]  WDATA,
    output logic [STRB_WIDTH-1:0]  WSTRB,
    output logic                   WVALID,
    output logic                   BREADY,


    input logic                   AWREADY,
    input logic                   WREADY,
    input logic                   BVALID,
    input logic [1:0]             BRESP
    
);

    typedef enum logic [2:0]{
        IDLE, SEND_AW, SEND_W, WAIT_B, DONE
    } state_t;
    
    state_t cur_state, nxt_state;
    assign done = (cur_state == DONE);
//this always block tells what to do if rst or not
    always_ff @(posedge clk) begin
        if(!rst) begin
            cur_state <= IDLE;
        end
        else begin
            cur_state <= nxt_state;
        end
    end
//this always block basically tells that what state is the next one

    always_comb begin
        nxt_state = cur_state;
        case (cur_state)
            IDLE : begin
                if(start) nxt_state = SEND_AW;
                else nxt_state = IDLE;
            end
            SEND_AW : begin
                if(AWREADY) nxt_state = SEND_W;
                else nxt_state = SEND_AW;
            end
            SEND_W : begin
                if(WREADY) nxt_state = WAIT_B;
                else nxt_state = SEND_W;
            end
            WAIT_B : begin
                if(BVALID) nxt_state = DONE;
                else nxt_state = WAIT_B;
            end
            DONE : begin
                if(!start) nxt_state = IDLE;
                else nxt_state = DONE;
            end
            default: nxt_state = IDLE;
        endcase
    end
//master function
// this always comb block tells what operation has to be performed when it is in the particular state
    always_ff @( posedge clk or negedge rst ) begin 
        if(!rst) begin
            AWADDR  <= 0;
            AWVALID <= 0;
            WDATA   <= 0;
            WSTRB   <= 0;
            WVALID  <= 0;
            BREADY  <= 0;    
        end
        else begin
            AWVALID <= 0;
            WVALID  <= 0;
            BREADY  <= 0;

            case (cur_state)
                SEND_AW: begin
                    AWVALID <= 1;
                    AWADDR  <= 32'h0000_0000;
                end

                SEND_W: begin
                    WVALID  <= 1;
                    WDATA   <= 32'hDEADFEED;
                    WSTRB   <= 4'b1111;
                end

                WAIT_B: begin
                    BREADY  <= 1;
                end
                default;
            endcase
        end
    end
endmodule