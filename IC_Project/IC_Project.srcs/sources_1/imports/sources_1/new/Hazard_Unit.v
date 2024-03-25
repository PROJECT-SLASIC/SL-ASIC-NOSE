module Hazard_Unit_1#(parameter width = 32)(
    //Forwarding Unit
    input [4:0] i_rs1_addr_id_ex_out,
    input [4:0] i_rs2_addr_id_ex_out,
    input [4:0] i_rd_addr_ex_mem_out,
    input [4:0] i_i_rd_addr_mem_wb_out,
    input i_RegWrite_ex_mem_out,
    input RegWrite_mem_wb_out,
    output reg [1:0] Forward_A,
    output reg [1:0] Forward_B,
    /////////////////
    // lw stall
    input [4:0] rs1_addr_if_id_out,
    input [4:0] rs2_addr_if_id_out,
    input [4:0] rd_addr_id_ex_out,
    input [2:0] ResultSrc_id_ex_out,
    output pc_Stall,
    output if_Stall,
    output id_Flush,
    /////////////////
    // branch 
    input PCSrc_hzd,
    output Flush_if,
    /////////////////
    input busy_alu,
    input valid_alu,
    output id_Stall,
    output ex_Stall,
    output mem_Stall
    );
    
    wire lwstall = ((ResultSrc_id_ex_out==3'b001) & ((rs1_addr_if_id_out==rd_addr_id_ex_out)|(rs2_addr_if_id_out==rd_addr_id_ex_out))) ? 
                                                  (1'b1) : (1'b0);
    assign pc_Stall = lwstall | (busy_alu && !valid_alu);
    assign if_Stall = lwstall | (busy_alu && !valid_alu);
    assign id_Stall = (busy_alu && !valid_alu);
    assign Stall_ex = 1'b0;
    assign Stall_mem = 1'b0;
//    assign Stall_ex = (busy_alu && !valid_alu);
//    assign Stall_mem = (busy_alu && !valid_alu);
    assign id_Flush = lwstall | PCSrc_hzd;
    // Branch
    assign Flush_if = PCSrc_hzd;
    
    
    always @(*)begin
        ///////////////////////////////////////////////////////////////////
        //Forwarding Unit
        ///////////////////////////////////////////////////////////////////
        if(((i_rs1_addr_id_ex_out==i_rd_addr_ex_mem_out) & i_RegWrite_ex_mem_out) & (i_rs1_addr_id_ex_out!=0))begin
            Forward_A = 2'b10;
        end
        else if (((i_rs1_addr_id_ex_out==i_i_rd_addr_mem_wb_out) & RegWrite_mem_wb_out) & (i_rs1_addr_id_ex_out!=0))begin
            Forward_A = 2'b01;
        end
        else begin
            Forward_A = 2'b00;
        end
        ///////////////////////////////////////////////////////////////////
        if(((i_rs2_addr_id_ex_out==i_rd_addr_ex_mem_out) & i_RegWrite_ex_mem_out) & (i_rs2_addr_id_ex_out!=0))begin
            Forward_B = 2'b10;
        end
        else if (((i_rs2_addr_id_ex_out==i_i_rd_addr_mem_wb_out) & RegWrite_mem_wb_out) & (i_rs2_addr_id_ex_out!=0))begin
            Forward_B = 2'b01;
        end
        else begin
            Forward_B = 2'b00;        
        end
        ///////////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////////
    end
endmodule
