module Fetch_Stage_1#(parameter width = 32)(
    input clk,
    input rst,
    input stall_if,
    input flush_if,
    input [width-1:0] inst_if,
    input [width-1:0] pc_if,
    input [width-1:0] pc_plus_4_if,
    
    output [width-1:0] instruction_if_id,
    output [width-1:0] programc_if_id,
    output [width-1:0] programc_plus_4_if_id
    );
    
    reg [width-1:0] instruction_if_id_reg;
    reg [width-1:0] pc_if_id_reg;
    reg [width-1:0] pc_plus_4_if_id_reg;
    
    assign instruction_if_id    = instruction_if_id_reg;
    assign programc_if_id             = pc_if_id_reg;
    assign programc_plus_4_if_id      = pc_plus_4_if_id_reg;
    
    always @(posedge clk)begin
        if(rst)begin            // clear
            instruction_if_id_reg   <= 32'b0;
            pc_if_id_reg            <= 32'b0;
            pc_plus_4_if_id_reg     <= 32'b0;
        end
        else if (flush_if)begin // clear
            instruction_if_id_reg   <= 32'b0;
            pc_if_id_reg            <= 32'b0;
            pc_plus_4_if_id_reg     <= 32'b0;
        end
        else if (stall_if)begin // do nothing - stop
            instruction_if_id_reg   <= instruction_if_id_reg;
            pc_if_id_reg            <= pc_if_id_reg;
            pc_plus_4_if_id_reg     <= pc_plus_4_if_id_reg;
        end
        else begin              // upload values
            instruction_if_id_reg   <= inst_if;
            pc_if_id_reg            <= pc_if;
            pc_plus_4_if_id_reg     <= pc_plus_4_if;
        end
    end
endmodule
