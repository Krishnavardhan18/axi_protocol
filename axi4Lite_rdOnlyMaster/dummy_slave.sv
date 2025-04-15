`timescale 1ns/1ps

module dummy_slave #(
    parameter ADDR_WIDTH = 32, 
    parameter DATA_WIDTH = 32)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic done,

    input  logic [ADDR_WIDTH-1:0] ARADDR,
    input  logic                  ARVALID,
    input  logic                  RREADY,

    output logic                  ARREADY,
    output logic                  RVALID,
    output logic [DATA_WIDTH-1:0] RDATA,
    output logic [1:0]            RRESP
);

    typedef enum logic [2:0]{
        IDLE, SEND_RR, SEND_RDATA, DONE
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
                if(ARVALID) nxt_state = SEND_RR;

            end

            SEND_RR : begin
                if(ARVALID  && ARREADY) nxt_state = SEND_RDATA;

            end

            SEND_RDATA : begin
                nxt_state = DONE;

            end

            DONE    : begin
                if(RREADY && RVALID) nxt_state = IDLE;
            end
            default: ;
        endcase
    end

//this always block does slave function
    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            ARREADY  <= 0;
            RVALID   <= 0;
            RRESP    <= 0; 
            RDATA    <= 0;   
        end
        else begin
            ARREADY <= 0;
            RVALID  <= 0;
            RRESP   <= 2'b00;

            case (cur_state)
                SEND_RR: begin
                    ARREADY <= 1;
                end

                SEND_RDATA: begin
                    RVALID  <= 1;
                    RDATA   <= 32'h1000_0000;
                    RRESP   <= 2'b00;
                end

            endcase
        end
    end
endmodule
