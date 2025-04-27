`timescale 1ns/1ps

module wrSlave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8
)(
    input logic clk, 
    input logic rst,
    input logic start,
    output logic done,

    input logic [ADDR_WIDTH-1:0] AWADDR,
    input logic AWVALID,
    output logic AWREADY,

    input logic [DATA_WIDTH-1:0] WDATA,
    input logic WVALID,
    output logic WREADY,

    output logic BVALID,
    output logic [1:0] BRESP,
    input logic BREADY
);

    typedef enum logic [2:0] {
        IDLE, WAIT_VALID, SEND_READY, ACCEPT_DATA, SEND_BRESP, DONE
    } state_t;

    state_t cur_state, nxt_state;
    assign done = (cur_state == DONE);

    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            cur_state <= IDLE;
        else
            cur_state <= nxt_state;
    end
    always_comb begin
        nxt_state = cur_state;
        case (cur_state)
            IDLE: begin
                if (start)
                    nxt_state = WAIT_VALID;
            end

            WAIT_VALID: begin
                if (AWVALID && WVALID)
                    nxt_state = SEND_READY;
            end

            SEND_READY: begin
                nxt_state = ACCEPT_DATA;
            end

            ACCEPT_DATA: begin
                nxt_state = SEND_BRESP;
            end

            SEND_BRESP: begin
                if (BREADY)
                    nxt_state = DONE;
            end

            DONE: begin
                nxt_state = IDLE;
            end

            default: nxt_state = IDLE;
        endcase
    end
    always_comb begin
        AWREADY = 0;
        WREADY = 0;
        BVALID = 0;
        BRESP  = 2'b00; 

        case (cur_state)
            SEND_READY: begin
                AWREADY = 1;
                WREADY  = 1;
            end

            SEND_BRESP: begin
                BVALID = 1;
                BRESP  = 2'b00;
            end

            default: ;
        endcase
    end

endmodule
