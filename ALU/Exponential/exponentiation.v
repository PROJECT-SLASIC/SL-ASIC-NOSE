module exponentiation(
    input clk, rst, start,
    input [31:0] exp,
    output reg [31:0] result,
    output reg valid,
    output reg busy
);
    reg [31:0] temp;
    reg [31:0] exp_temp;
    reg [31:0] rs1, rs2;
    reg start_received;
    reg mult_start;
    reg no_mult;
    reg [2:0] state;
    wire [31:0] next_exp_temp = exp_temp >> 1;
    
    wire [31:0] mult_result;
    wire mult_valid, mult_busy;
    
    // Instantiate the multiplier module
    ieee_754_multiplier multiplier(
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .start(mult_start),
        .result(mult_result),
        .valid(mult_valid),
        .busy(mult_busy)
    );
    
    // State Encoding
    parameter IDLE = 3'b000;
    parameter START = 3'b001;
    parameter WAIT_VALID = 3'b010;
    parameter WAIT_VALID_2 = 3'b011;
    parameter FINISHED = 3'b100;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            exp_temp <= 0;
            valid <= 0;
            busy <= 0;
            start_received <= 0;
            mult_start <= 0;
            rs1 <= 0;
            rs2 <= 0;
            no_mult <= 0;
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start) begin
                        result <= 32'h3F800000; // 1.0 in IEEE 754
                        temp <= 32'h402DF854; // e in IEEE 754
                        exp_temp <= exp;
                        valid <= 0;
                        busy <= 1;
                        state <= START;
                    end
                end
                
                START: begin
                    mult_start <= 0;
                    if(exp_temp == 0) begin
                        state <= FINISHED;
                    end
                    else if(exp_temp[0]) begin
                        rs2 <= temp;
                        rs1 <= result;
                        mult_start <= 1;
                        no_mult <= 0;
                        state <= WAIT_VALID;
                    end
                    else begin
                        no_mult <= 1;
                        state <= WAIT_VALID;
                    end
                end
                
                WAIT_VALID: begin
                    mult_start <= 0;
                    if(mult_valid || no_mult) begin
                        if(!no_mult) result <= mult_result;
                        if(next_exp_temp != 0) begin
                            rs2 <= temp;
                            rs1 <= temp;
                            mult_start <= 1;
                            no_mult <= 0;
                            state <= WAIT_VALID_2;
                        end
                        else begin
                            exp_temp <= next_exp_temp;
                            state <= START;
                        end
                    end
                end
                
                WAIT_VALID_2: begin
                    mult_start <= 0;
                    if(mult_valid || no_mult) begin
                        if(!no_mult) temp <= mult_result;
                        exp_temp <= next_exp_temp;
                        state <= START;
                    end
                end
                
                FINISHED: begin
                    valid <= 1;
                    busy <= 0;
                end
            endcase
        end
    end
endmodule
