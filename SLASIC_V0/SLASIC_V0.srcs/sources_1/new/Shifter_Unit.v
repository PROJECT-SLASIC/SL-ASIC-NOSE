module Shifter_Unit#(parameter width = 32)(
    input [width-1:0] A_i,
    input [width-1:0] B_i,
    input [1:0] shifter_op,     // 00 shift left, 01 shift right logical, 10 shift right arithmetic
    output [width-1:0] Result_o
    );
    
    wire [width-1:0] mux_one_output;    
    wire [width-1:0] mux_two_output;    
    wire [width-1:0] mux_four_output;    
    wire [width-1:0] mux_eight_output;    
    wire [width-1:0] mux_sixteen_output;
    
    assign Result_o = ((A_i[width-1] && (shifter_op==2'b10) && B_i[3]) ? (mux_sixteen_output | 32'hffff0000):(mux_sixteen_output));
    
    mux mux_one_1(
        . A_i(A_i),
        . sel_bit(B_i[0]),          // for 1 make operation, for 0 buffer the input as it is
        . shifter_op(shifter_op),
        . x(5'b00001),
        . Result_o(mux_one_output)
    ); 
       
    mux mux_one_2(
        . A_i((A_i[width-1] && (shifter_op==2'b10) && B_i[0]) ? (mux_one_output | 32'h80000000):(mux_one_output)),
        . sel_bit(B_i[1]),          // for 1 make operation, for 0 buffer the input as it is
        . shifter_op(shifter_op),
        . x(5'b00010),
        . Result_o(mux_two_output)
    );
       
    mux mux_one_4(
        . A_i((A_i[width-1] && (shifter_op==2'b10) && B_i[1]) ? (mux_two_output | 32'hf0000000):(mux_two_output)),
        . sel_bit(B_i[2]),          // for 1 make operation, for 0 buffer the input as it is
        . shifter_op(shifter_op),
        . x(5'b00100),
        . Result_o(mux_four_output)
    );
       
    mux mux_one_8(
        . A_i((A_i[width-1] && (shifter_op==2'b10) && B_i[2]) ? (mux_four_output | 32'hff000000):(mux_four_output)),
        . sel_bit(B_i[3]),          // for 1 make operation, for 0 buffer the input as it is
        . shifter_op(shifter_op),
        . x(5'b01000),
        . Result_o(mux_eight_output)
    );
       
    mux mux_one_16(
        . A_i((A_i[width-1] && (shifter_op==2'b10) && B_i[3]) ? (mux_eight_output | 32'hffff0000):(mux_eight_output)),
        . sel_bit(B_i[4]),          // for 1 make operation, for 0 buffer the input as it is
        . shifter_op(shifter_op),
        . x(5'b10000),
        . Result_o(mux_sixteen_output)
    );
endmodule

module mux #(parameter width = 32)(
    input [width-1:0] A_i,
    input sel_bit,          // for 1 make operation, for 0 buffer the input as it is
    input [1:0] shifter_op,
    input [4:0] x,
    output [width-1:0] Result_o
    );
    assign Result_o = (sel_bit) ? ((shifter_op!=2'b00) ? (A_i >> x) : (A_i << x)): (A_i);
endmodule
