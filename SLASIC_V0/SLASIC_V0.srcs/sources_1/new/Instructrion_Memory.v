module Instruction_Memory_1#(parameter width = 32)(
    input [width-1:0] address,
    output [width-1:0] instruction
    );
    
//    reg [width-1:0] memory_big [0:1920];
//    reg [width-1:0] uart_mem [0:2000];
//    reg [width-1:0] memory_bubble [0:31];
    reg [width-1:0] report_mem_Reg [0:100];
    
    initial begin
//        $readmemh("bubble_sort.s",memory_bubble);
//        $readmemh("instruction_memory_file.mem",memory_big);
//        $readmemh("uart_mem_file.mem",uart_mem);
        $readmemh("report_mem.mem",report_mem_Reg);
    end
    
    wire [11:0] indexed_value = address[30:0] / 4;
//    assign instruction = memory_bubble [indexed_value];
//    assign instruction = memory_big [indexed_value];
//    assign instruction = uart_mem [indexed_value];
    assign instruction = report_mem_Reg [indexed_value];
endmodule
