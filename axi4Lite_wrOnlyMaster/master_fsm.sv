`timescale 1ns/1ps

module master_fsm (
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic done,
    axi_signals_if.master axi
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
                if(axi.AWREADY) nxt_state = SEND_W;
                else nxt_state = SEND_AW;
            end
            SEND_W : begin
                if(axi.WREADY) nxt_state = WAIT_B;
                else nxt_state = SEND_W;
            end
            WAIT_B : begin
                if(axi.BVALID) nxt_state = DONE;
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
            axi.AWADDR  <= 0;
            axi.AWVALID <= 0;
            axi.WDATA   <= 0;
            axi.WSTRB   <= 0;
            axi.WVALID  <= 0;
            axi.BREADY  <= 0;    
        end
        else begin
            axi.AWVALID <= 0;
            axi.WVALID  <= 0;
            axi.BREADY  <= 0;

            case (cur_state)
                SEND_AW: begin
                    axi.AWVALID <= 1;
                    axi.AWADDR  <= 32'h0000_0000;
                end

                SEND_W: begin
                    axi.WVALID  <= 1;
                    axi.WDATA   <= 32'hDEADFEED;
                    axi.WSTRB   <= 4'b1111;
                end

                WAIT_B: begin
                    axi.BREADY  <= 1;
                end
                default;
            endcase
        end
    end
endmodule