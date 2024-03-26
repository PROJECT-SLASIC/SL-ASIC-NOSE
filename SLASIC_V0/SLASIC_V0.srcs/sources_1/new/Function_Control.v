module Function_Control(
    input [4:0] op,
    output reg arith_op,            // 0 for addition, 1 for subtraction
    output reg [1:0] logic_op,      // 00 for and, 01 for xor, 10 for or
    output reg [1:0] shifter_op,    // 00 shift left, 01 shift right logical, 10 shift right arithmetic
    output reg [2:0] cmp_op,        // 000 for equal, 001 for not equal, 010 for greater, 011 for greater than, 100 for less than
    output reg [2:0] unit_select,
    output reg mul_op,
    output reg div_op
    );
    
    localparam [4:0] ADD            = 5'd0;    
    localparam [4:0] SUB            = 5'd1;    
    localparam [4:0] AND            = 5'd2;    
    localparam [4:0] XOR            = 5'd3;    
    localparam [4:0] OR             = 5'd4;    
    localparam [4:0] EQUAL          = 5'd5;    
    localparam [4:0] GREATER_EQUAL  = 5'd6;    
    localparam [4:0] LESS_THAN      = 5'd7;   
    localparam [4:0] NOT_EQUAL      = 5'd8;    
    localparam [4:0] GREATER        = 5'd9;    
    localparam [4:0] SLL            = 5'd10;    
    localparam [4:0] SRL            = 5'd11;    
    localparam [4:0] SRA            = 5'd12;
    localparam [4:0] GREATER_EQUAL_SIGNED  = 5'd13;    
    localparam [4:0] LESS_THAN_SIGNED      = 5'd14; 
    
    localparam [4:0] MULHU          = 5'd15;
    localparam [4:0] DIVU           = 5'd16;
    localparam [4:0] REMU           = 5'd17;
    
    always @(*)begin
        case (op)
            // Arithmetic Unit - unit_select = 2'b00;
            ADD:begin
                arith_op = 1'b0;
                unit_select = 3'b000;
            end
            SUB:begin
                arith_op = 1'b1;
                unit_select = 3'b000;
            end
            // Logic Unit - unit_select = 3'b01;
            AND:begin
                logic_op = 2'b00;
                unit_select = 3'b001;
            end
            XOR:begin
                logic_op = 2'b01;
                unit_select = 3'b001;
            end
            OR:begin
                logic_op = 2'b10;
                unit_select = 3'b001;
            end
            // Comparison Unit - unit_select = 3'b10;
            EQUAL:begin
                cmp_op = 3'b000;
                unit_select = 3'b010;
            end
            NOT_EQUAL:begin
                cmp_op = 3'b001;
                unit_select = 3'b010;
            end
            GREATER:begin
                cmp_op = 3'b010;
                unit_select = 3'b010;
            end
            GREATER_EQUAL:begin
                cmp_op = 3'b011;
                unit_select = 3'b010;
            end
            LESS_THAN:begin
                cmp_op = 3'b100;
                unit_select = 3'b010;
            end
            // Shifter Unit - unit_select = 3'b11;
            SLL:begin
                shifter_op = 2'b00;
                unit_select = 3'b011;
            end
            SRL:begin
                shifter_op = 2'b01;
                unit_select = 3'b011;
            end
            SRA:begin
                shifter_op = 2'b10;
                unit_select = 3'b011;
            end
            GREATER_EQUAL_SIGNED:begin
                cmp_op = 3'b110;
                unit_select = 3'b010;
            end
            LESS_THAN_SIGNED:begin
                cmp_op = 3'b101;
                unit_select = 3'b010;
            end
            MULHU:begin
                mul_op = 1'b1;
                unit_select = 3'b100;
            end
            DIVU:begin
                div_op = 1'b0;
                unit_select = 3'b101;
            end
            REMU:begin
                div_op = 1'b1;
                unit_select = 3'b101;
            end
            default:begin
                mul_op = 1'b0;
                div_op = 1'b0;
                arith_op = 1'b0;
                logic_op = 2'b11;
                shifter_op = 2'b11;
                cmp_op = 3'b111;
                unit_select = 3'b000;
            end
        endcase
    end
endmodule
