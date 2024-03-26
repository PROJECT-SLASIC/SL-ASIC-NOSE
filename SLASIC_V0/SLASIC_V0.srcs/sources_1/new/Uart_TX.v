
module Uart_TX(
    input clk,
    input rst,
    input [7:0] din_i,
    input tx_start_i,
    output reg tx_o,
    output reg tx_busy,
    output reg tx_done_tick_o
);

    parameter c_clkfreq = 100000000;
    parameter c_baudrate = 115200;
    parameter c_stopbit = 1;
    
    localparam c_bittimerlim = c_clkfreq / c_baudrate;
    localparam c_stopbitlim = (c_clkfreq / c_baudrate) * c_stopbit;
    
    reg [2:0] state;
    parameter S_IDLE = 0;
    parameter S_START = 1;
    parameter S_DATA = 2;
    parameter S_STOP = 3;
    
    reg [31:0] bittimer;
    reg [2:0] bitcntr;
    reg [7:0] shreg;

    always @(posedge clk) begin
        if(rst)begin
            state <= S_IDLE;
            bittimer <= 32'b0;
            bitcntr <= 3'b0;
            shreg <= 8'b0;
            tx_busy <= 1'b0;
            tx_done_tick_o <= 1'b0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    tx_o <= 1'b1;
                    bitcntr <= 0;
                    if (tx_start_i == 1'b1) begin
                        tx_busy <= 1'b1;
                        state <= S_START;
                        tx_o <= 1'b0;
                        shreg <= din_i;
                        tx_done_tick_o <= 1'b0;
                    end
                end
        
                S_START: begin
                    if (bittimer == c_bittimerlim - 1) begin
                        state <= S_DATA;
                        tx_o <= shreg[0];
                        shreg <= {shreg[0], shreg[7:1]};
                        bittimer <= 0;
                    end else begin
                        bittimer <= bittimer + 1;
                    end
                end
        
                S_DATA: begin
                    if (bitcntr == 7) begin
                        if (bittimer == c_bittimerlim - 1) begin
                            bitcntr <= 0;
                            state <= S_STOP;
                            tx_o <= 1'b1;
                            bittimer <= 0;
                        end else begin
                            bittimer <= bittimer + 1;
                        end
                    end else begin
                        if (bittimer == c_bittimerlim - 1) begin
                            shreg <= {shreg[0], shreg[7:1]};
                            tx_o <= shreg[0];
                            bitcntr <= bitcntr + 1;
                            bittimer <= 0;
                        end else begin
                            bittimer <= bittimer + 1;
                        end
                    end
                end
        
                S_STOP: begin
                    if (bittimer == c_stopbitlim - 1) begin
                        state <= S_IDLE;
                        tx_busy <= 1'b0;
                        tx_done_tick_o <= 1'b1;
                        bittimer <= 0;
                    end else begin
                        bittimer <= bittimer + 1;
                    end
                end
            endcase
        end
    end
endmodule