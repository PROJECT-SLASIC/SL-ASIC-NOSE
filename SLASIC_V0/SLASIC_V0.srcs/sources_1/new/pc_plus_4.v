module pc_plus_4_1#(parameter width = 32)(
    input [width-1:0] i_pc,
    output [width-1:0] pc_plus_4
    );
    assign pc_plus_4 = i_pc + 4 ;
endmodule
