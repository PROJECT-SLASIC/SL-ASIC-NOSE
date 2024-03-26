module Execute_Stage_1#(parameter width = 32)(
    input clk,
    input rst,
    input stall_ex,
    input flush_ex,
    //
    input [width-1:0] i_alu_result_ex,
    input [width-1:0] i_rs2_ex,
    input [4:0] i_rd_addr_ex,
    input [width-1:0] i_pc_plus_4_ex,
    input [width-1:0] i_pc_target_ex,
    input [width-1:0] i_immediate_extended_ex,
    // Control Unit 
    input i_Reg_Write_ex,
    input [2:0] i_ResultSrc_ex,
    input i_Mem_Write_ex,
    //
    output [width-1:0] alu_result_ex_mem,
    output [width-1:0] rs2_ex_mem,
    output [4:0] rd_addr_ex_mem,
    output [width-1:0] pc_plus_4_ex_mem,
    output [width-1:0] pc_target_ex_mem,
    output [width-1:0] immediate_extended_ex_mem,
    // Control Unit 
    output Reg_Write_ex_mem,
    output [2:0] ResultSrc_ex_mem,
    output Mem_Write_ex_mem
    );
       
    assign alu_result_ex_mem = alu_result_ex_reg;
    assign rs2_ex_mem = rs2_ex_reg;
    assign rd_addr_ex_mem = rd_addr_ex_reg;
    assign pc_plus_4_ex_mem = pc_plus_4_ex_reg;
    assign pc_target_ex_mem = pc_target_ex_reg;
    assign immediate_extended_ex_mem = immediate_extended_ex_reg;
    // Control Unit 
    assign Reg_Write_ex_mem = Reg_Write_ex_reg;
    assign ResultSrc_ex_mem = ResultSrc_ex_reg;
    assign Mem_Write_ex_mem = Mem_Write_ex_reg;
    
    reg [width-1:0] alu_result_ex_reg;
    reg [width-1:0] rs2_ex_reg;
    reg [4:0] rd_addr_ex_reg;
    reg [width-1:0] pc_plus_4_ex_reg;
    reg [width-1:0] pc_target_ex_reg;
    reg [width-1:0] immediate_extended_ex_reg;
    // Control Unit 
    reg Reg_Write_ex_reg;
    reg [2:0] ResultSrc_ex_reg;
    reg Mem_Write_ex_reg;
    
    always @(posedge clk)begin
        if(rst)begin            // clear
            alu_result_ex_reg           <= 32'b0;
            rs2_ex_reg                  <= 32'b0;
            rd_addr_ex_reg              <= 5'b0;
            pc_plus_4_ex_reg            <= 32'b0;
            pc_target_ex_reg            <= 32'b0;
            immediate_extended_ex_reg   <= 32'b0;
            
            Reg_Write_ex_reg            <= 1'b0;
            ResultSrc_ex_reg            <= 3'b0;
            Mem_Write_ex_reg            <= 1'b0;
        end
        else if (flush_ex)begin // clear
            alu_result_ex_reg           <= 32'b0;
            rs2_ex_reg                  <= 32'b0;
            rd_addr_ex_reg              <= 5'b0;
            pc_plus_4_ex_reg            <= 32'b0;
            pc_target_ex_reg            <= 32'b0;
            immediate_extended_ex_reg   <= 32'b0;
            
            Reg_Write_ex_reg            <= 1'b0;
            ResultSrc_ex_reg            <= 3'b0;
            Mem_Write_ex_reg            <= 1'b0;
        end
        else if (stall_ex)begin // do nothing - stop
            alu_result_ex_reg           <= alu_result_ex_reg;
            rs2_ex_reg                  <= rs2_ex_reg;
            rd_addr_ex_reg              <= rd_addr_ex_reg;
            pc_plus_4_ex_reg            <= pc_plus_4_ex_reg;
            pc_target_ex_reg            <= pc_target_ex_reg;
            immediate_extended_ex_reg   <= immediate_extended_ex_reg;
            
            Reg_Write_ex_reg            <= Reg_Write_ex_reg;
            ResultSrc_ex_reg            <= ResultSrc_ex_reg;
            Mem_Write_ex_reg            <= Mem_Write_ex_reg;
        end
        else begin              // upload values
            alu_result_ex_reg           <= i_alu_result_ex;
            rs2_ex_reg                  <= i_rs2_ex;
            rd_addr_ex_reg              <= i_rd_addr_ex;
            pc_plus_4_ex_reg            <= i_pc_plus_4_ex;
            pc_target_ex_reg            <= i_pc_target_ex;
            immediate_extended_ex_reg   <= i_immediate_extended_ex;
            
            Reg_Write_ex_reg            <= i_Reg_Write_ex;
            ResultSrc_ex_reg            <= i_ResultSrc_ex;
            Mem_Write_ex_reg            <= i_Mem_Write_ex;
        end
    end
endmodule
