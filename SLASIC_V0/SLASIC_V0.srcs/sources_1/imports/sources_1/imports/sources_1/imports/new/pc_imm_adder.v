module pc_imm_adder_1#(parameter width = 32)(
    input [width-1:0] i_pc,
    input [width-1:0] imm,
    output [width-1:0] pc_imm
    );
    
    assign pc_imm = i_pc + imm;
endmodule
