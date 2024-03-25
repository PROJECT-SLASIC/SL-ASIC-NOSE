module Memory_Access_Stage_1#(parameter width = 32)(
    input clk,
    input rst,
    input stall_mem,
    input flush_mem,
    //
    input [width-1:0] i_alu_result_mem,
    input [width-1:0] i_rd_mem,
    input [4:0] i_rd_addr_mem,
    input [width-1:0] i_pc_plus_4_mem,
    input [width-1:0] i_pc_target_mem,
    input [width-1:0] i_immediate_extended_mem,
    // Control Unit
    input i_Reg_Write_mem,
    input [2:0] i_ResultSrc_mem,
    //
    output [width-1:0] alu_result_mem_wb,
    output [width-1:0] rd_mem_wb,
    output [4:0] rd_addr_mem_wb_wb,
    output [width-1:0] pc_plus_4_mem_wb,
    output [width-1:0] pc_target_mem_wb,
    output [width-1:0] immediate_extended_mem_wb,
    // Control Unit 
    output Reg_Write_mem_wb,
    output [2:0] ResultSrc_mem_wb
    );
    
    assign alu_result_mem_wb = alu_result_mem_reg;
    assign rd_mem_wb = rd_mem_reg;
    assign rd_addr_mem_wb_wb = rd_addr_mem_reg;
    assign pc_plus_4_mem_wb = pc_plus_4_mem_reg;
    assign pc_target_mem_wb = pc_target_mem_reg;
    assign immediate_extended_mem_wb = immediate_extended_mem_reg;
    // Control Unit 
    assign Reg_Write_mem_wb = Reg_Write_mem_reg;
    assign ResultSrc_mem_wb = ResultSrc_mem_reg;
    
    reg [width-1:0] alu_result_mem_reg;
    reg [width-1:0] rd_mem_reg;
    reg [4:0] rd_addr_mem_reg;
    reg [width-1:0] pc_plus_4_mem_reg;
    reg [width-1:0] pc_target_mem_reg;
    reg [width-1:0] immediate_extended_mem_reg;
    // Control Unit 
    reg Reg_Write_mem_reg;
    reg [2:0] ResultSrc_mem_reg;
    
    always @(posedge clk)begin
            if(rst)begin            // clear
                alu_result_mem_reg          <= 32'b0;
                rd_mem_reg                  <= 32'b0;
                rd_addr_mem_reg             <= 5'b0;
                pc_plus_4_mem_reg           <= 32'b0;
                pc_target_mem_reg           <= 32'b0;
                immediate_extended_mem_reg  <= 32'b0;
                
                Reg_Write_mem_reg           <= 1'b0;
                ResultSrc_mem_reg           <= 3'b0;
            end
            else if (flush_mem)begin // clear
                alu_result_mem_reg          <= 32'b0;
                rd_mem_reg                  <= 32'b0;
                rd_addr_mem_reg             <= 5'b0;
                pc_plus_4_mem_reg           <= 32'b0;
                pc_target_mem_reg           <= 32'b0;
                immediate_extended_mem_reg  <= 32'b0;
                
                Reg_Write_mem_reg           <= 1'b0;
                ResultSrc_mem_reg           <= 3'b0;
            end
            else if (stall_mem)begin // do nothing - stop
                alu_result_mem_reg          <= alu_result_mem_reg;
                rd_mem_reg                  <= rd_mem_reg;
                rd_addr_mem_reg             <= rd_addr_mem_reg;
                pc_plus_4_mem_reg           <= pc_plus_4_mem_reg;
                pc_target_mem_reg           <= pc_target_mem_reg;
                immediate_extended_mem_reg  <= immediate_extended_mem_reg;
                
                Reg_Write_mem_reg           <= Reg_Write_mem_reg;
                ResultSrc_mem_reg           <= ResultSrc_mem_reg;
            end
            else begin
                alu_result_mem_reg          <= i_alu_result_mem;
                rd_mem_reg                  <= i_rd_mem;
                rd_addr_mem_reg             <= i_rd_addr_mem;
                pc_plus_4_mem_reg           <= i_pc_plus_4_mem;
                pc_target_mem_reg           <= i_pc_target_mem;
                immediate_extended_mem_reg  <= i_immediate_extended_mem;
                
                Reg_Write_mem_reg           <= i_Reg_Write_mem;
                ResultSrc_mem_reg           <= i_ResultSrc_mem;
            end
        end
endmodule
