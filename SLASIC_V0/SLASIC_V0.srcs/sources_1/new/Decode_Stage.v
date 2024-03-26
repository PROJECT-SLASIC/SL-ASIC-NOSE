module Decode_Stage_1#(parameter width = 32)(
    input clk,
    input rst,
    input stall_id,
    input flush_id,
    //
    input [width-1:0] i_rs1_id,
    input [width-1:0] i_rs2_id,
    input [width-1:0] i_pc_id,
    input [4:0] i_rs1_addr_id,
    input [4:0] i_rs2_addr_id,
    input [4:0] i_rd_addr_id,
    input [width-1:0] i_immediate_extended_id,
    input [width-1:0] i_pc_plus_4_id,
    
    // Control Unit 
    input i_Reg_Write_id,
    input [2:0] i_ResultSrc_id,
    input i_Mem_Write_id,
    input i_Jump_id,
    input i_Branch_id,
    input [4:0] i_Alu_Control_id,
    input i_AluSrc_id,
    input i_jalr_top_id,
    //
    output [width-1:0] rs1_id_ex,
    output [width-1:0] rs2_id_ex,
    output [width-1:0] pc_id_ex,
    output [4:0] rs1_addr_ex,
    output [4:0] rs2_addr_ex,
    output [4:0] rd_addr_id_ex,
    output [width-1:0] immediate_extended_id_ex,
    output [width-1:0] pc_plus_4_id_ex,
    
    // Control Unit 
    output Reg_Write_id_ex,
    output [2:0] ResultSrc_id_ex,
    output Mem_Write_id_ex,
    output Jump_id_ex,
    output Branch_id_ex,
    output [4:0] Alu_Control_id_ex,
    output AluSrc_id_ex,
    output jalr_top_id_ex
    );
    
    assign rs1_id_ex = rs1_id_reg;
    assign rs2_id_ex = rs2_id_reg;
    assign pc_id_ex = pc_id_reg;
    assign rs1_addr_ex = rs1_addr_id_reg;
    assign rs2_addr_ex = rs2_addr_id_reg;
    assign rd_addr_id_ex = rd_addr_id_reg;
    assign immediate_extended_id_ex = immediate_extended_id_reg;
    assign pc_plus_4_id_ex = pc_plus_4_id_reg;
    
    // Control Unit 
    assign Reg_Write_id_ex = Reg_Write_id_reg;
    assign ResultSrc_id_ex = ResultSrc_id_reg;
    assign Mem_Write_id_ex = Mem_Write_id_reg;
    assign Jump_id_ex = Jump_id_reg;
    assign Branch_id_ex = Branch_id_reg;
    assign Alu_Control_id_ex = Alu_Control_id_reg;
    assign AluSrc_id_ex = AluSrc_top_reg;
    assign jalr_top_id_ex = jalr_top_reg;
    
    
    reg [width-1:0] rs1_id_reg;
    reg [width-1:0] rs2_id_reg;
    reg [width-1:0] pc_id_reg;
    reg [4:0] rs1_addr_id_reg;
    reg [4:0] rs2_addr_id_reg;
    reg [4:0] rd_addr_id_reg;
    reg [width-1:0] immediate_extended_id_reg;
    reg [width-1:0] pc_plus_4_id_reg;
    
    // Control Unit 
    reg Reg_Write_id_reg;
    reg [2:0] ResultSrc_id_reg;
    reg Mem_Write_id_reg;
    reg Jump_id_reg;
    reg Branch_id_reg;
    reg [4:0] Alu_Control_id_reg;
    reg AluSrc_top_reg;
    reg jalr_top_reg;
    
    always @(posedge clk)begin
        if(rst)begin            // clear
            rs1_id_reg                  <= 32'b0;
            rs2_id_reg                  <= 32'b0;
            pc_id_reg                   <= 32'b0;
            rs1_addr_id_reg             <= 5'b0;
            rs2_addr_id_reg             <= 5'b0;
            rd_addr_id_reg              <= 5'b0;
            immediate_extended_id_reg   <= 32'b0;
            pc_plus_4_id_reg            <= 32'b0;
            
            Reg_Write_id_reg            <= 1'b0;
            ResultSrc_id_reg            <= 3'b0;
            Mem_Write_id_reg            <= 1'b0; 
            Jump_id_reg                 <= 1'b0;
            Branch_id_reg               <= 1'b0;
            Alu_Control_id_reg          <= 5'b0;
            AluSrc_top_reg              <= 1'b0;
            jalr_top_reg                <= 1'b0;
        end
        else if (flush_id)begin // clear
            rs1_id_reg                  <= 32'b0;
            rs2_id_reg                  <= 32'b0;
            pc_id_reg                   <= 32'b0;
            rs1_addr_id_reg             <= 5'b0;
            rs2_addr_id_reg             <= 5'b0;
            rd_addr_id_reg              <= 5'b0;
            immediate_extended_id_reg   <= 32'b0;
            pc_plus_4_id_reg            <= 32'b0;
            
            Reg_Write_id_reg            <= 1'b0;
            ResultSrc_id_reg            <= 3'b0;
            Mem_Write_id_reg            <= 1'b0; 
            Jump_id_reg                 <= 1'b0;
            Branch_id_reg               <= 1'b0;
            Alu_Control_id_reg          <= 5'b0;
            AluSrc_top_reg              <= 1'b0;
            jalr_top_reg                <= 1'b0;
        end
        else if (stall_id)begin // do nothing - stop
            rs1_id_reg                  <= rs1_id_reg;
            rs2_id_reg                  <= rs2_id_reg;
            pc_id_reg                   <= pc_id_reg;
            rs1_addr_id_reg             <= rs1_addr_id_reg;
            rs2_addr_id_reg             <= rs2_addr_id_reg;
            rd_addr_id_reg              <= rd_addr_id_reg;
            immediate_extended_id_reg   <= immediate_extended_id_reg;
            pc_plus_4_id_reg            <= pc_plus_4_id_reg;
            
            Reg_Write_id_reg            <= Reg_Write_id_reg;
            ResultSrc_id_reg            <= ResultSrc_id_reg;
            Mem_Write_id_reg            <= Mem_Write_id_reg; 
            Jump_id_reg                 <= Jump_id_reg;
            Branch_id_reg               <= Branch_id_reg;
            Alu_Control_id_reg          <= Alu_Control_id_reg;
            AluSrc_top_reg              <= AluSrc_top_reg;
            jalr_top_reg                <= jalr_top_reg;
        end
        else begin              // upload values
            rs1_id_reg                  <= i_rs1_id;
            rs2_id_reg                  <= i_rs2_id;
            pc_id_reg                   <= i_pc_id;
            rs1_addr_id_reg             <= i_rs1_addr_id;
            rs2_addr_id_reg             <= i_rs2_addr_id;
            rd_addr_id_reg              <= i_rd_addr_id;
            immediate_extended_id_reg   <= i_immediate_extended_id;
            pc_plus_4_id_reg            <= i_pc_plus_4_id;
            
            Reg_Write_id_reg            <= i_Reg_Write_id;
            ResultSrc_id_reg            <= i_ResultSrc_id;
            Mem_Write_id_reg            <= i_Mem_Write_id; 
            Jump_id_reg                 <= i_Jump_id;
            Branch_id_reg               <= i_Branch_id;
            Alu_Control_id_reg          <= i_Alu_Control_id;
            AluSrc_top_reg              <= i_AluSrc_id;
            jalr_top_reg                <= i_jalr_top_id;
        end
    end
endmodule
