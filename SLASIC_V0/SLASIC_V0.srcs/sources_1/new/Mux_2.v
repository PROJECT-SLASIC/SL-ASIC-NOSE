module Mux_2#(parameter width = 32)(
    input [2:0] ResultSrc,
    input [width-1:0] alu_result_mux,
    input [width-1:0] data_memory_mux,
    input [width-1:0] i_pc_plus4_mux,
    input [width-1:0] ext_imm_mux,
    input [width-1:0] pc_target2_mux,
    output reg [width-1:0] output_mux
    );
    
    always @(*)begin
        if(ResultSrc==3'b000)begin
            output_mux = alu_result_mux;
        end
        else if(ResultSrc==3'b001)begin
            output_mux = data_memory_mux;
        end
        else if(ResultSrc==3'b010)begin
            output_mux = i_pc_plus4_mux;
        end
        else if(ResultSrc==3'b011)begin
            output_mux = ext_imm_mux;
        end
        else if(ResultSrc==3'b100)begin
            output_mux = pc_target2_mux;
        end
        else begin
            output_mux = {(width){1'b0}};
        end
    end
endmodule
