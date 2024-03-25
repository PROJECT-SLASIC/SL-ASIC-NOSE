module mlp(
    input clk,
    input rst,
    
    // Control Signals
    input start,
    output reg busy,
    output reg valid,
    output reg memory_ready,
    
    output [31:0] data_req_address,
    input [31:0] data,
    
    output reg [3:0] decsion_result
    );

    reg [4:0] layer_1_size;
    reg [4:0] layer_2_size;
    reg [4:0] layer_3_size;
    reg [4:0] layer_4_size;

endmodule