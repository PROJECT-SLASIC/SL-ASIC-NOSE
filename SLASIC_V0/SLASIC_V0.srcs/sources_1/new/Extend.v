module Extend_1#(parameter width = 32)(
    input [20:0] ins_immediate,
    input [2:0] ImmSrc,
    output reg [width-1:0] immediate_extended
    );
    
    always @(*)begin
        case (ImmSrc)
            3'b000: begin   // I - Type
                immediate_extended = {{20{ins_immediate[11]}},ins_immediate[11:0]};
            end
            3'b001: begin   // S - Type
                immediate_extended = {{20{ins_immediate[11]}},ins_immediate[11:0]};
            end
            3'b010: begin   // B - Type
                immediate_extended = {{19{ins_immediate[12]}},ins_immediate[12:0]};
            end
            3'b011: begin   // U - Type
                immediate_extended = {ins_immediate[19:0],{12{1'b0}}};
            end
            3'b100: begin   // J - Type
                immediate_extended = {{11{ins_immediate[20]}},ins_immediate[20:0]};
            end
        endcase
    end
endmodule
