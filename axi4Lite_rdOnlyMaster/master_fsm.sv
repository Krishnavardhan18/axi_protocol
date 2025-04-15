`timescale 1ns/1ps

module master_fsm #(
    parameter ADDR_WIDTH = 32, 
    parameter DATA_WIDTH = 32, 
    parameter STRB_WIDTH = DATA_WIDTH/8)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic done,
    output logic [ADDR_WIDTH-1:0]   ARADDR,
    output logic                    ARVALID,
    output logic [DATA_WIDTH-1:0]   READ_DATA,
    output logic                    RREADY,

    input  logic                    ARREADY,
    input  logic [DATA_WIDTH-1:0]   RDATA,
    input  logic [1:0]              RRESP,
    input  logic                    RVALID              
    
);

    typedef enum logic [1:0] {
        IDLE, SEND_AR, WAIT_RDATA, DONE
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
                if(start) nxt_state = SEND_AR;
                
            end
            SEND_AR : begin
                if(ARREADY) nxt_state = WAIT_RDATA;
               
            end
            WAIT_RDATA : begin
                if(RVALID) nxt_state = DONE;
               
            end
            DONE : begin
                if(!start) nxt_state = IDLE;
                
            end

        endcase
    end
//master function
// this always comb block tells what operation has to be performed when it is in the particular state
    always_ff @( posedge clk or negedge rst ) begin 
        if(!rst) begin
            ARADDR  <= 0;
            ARVALID <= 0;
            READ_DATA   <= 0;
            RREADY  <= 0;    
        end
        else begin
            ARVALID <= 0;
            RREADY  <= 0;

            case (cur_state)
                SEND_AR: begin
                    ARADDR  <= 32'h0000_0000;
                    ARVALID <= 1;
                end

                WAIT_RDATA: begin
                    if(RVALID)begin
                        RREADY  <= 1;
                        if(RRESP==2'b00) begin
                            READ_DATA   <= RDATA;
                        end
                    end
                end
                default: ;
            endcase
        end
    end
endmodule