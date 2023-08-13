`timescale 1ns/1ps

module tb_clamping;

    // Define signals for input and output data
    reg [31:0] in_data;
    wire [31:0] out_data_wire;
    reg [31:0] out_data_reg;

    // Instantiate the clamping module
    clamping uut(
        .in_data(in_data),
        .out_data(out_data_wire)
    );

    // Connect out_data_wire to out_data_reg for observing in the testbench
    always @(out_data_wire) begin
        out_data_reg = out_data_wire;
    end

    // Testbench logic
    initial begin
        // Test below the lower bound
        in_data = 32'hFFFFFFFF; // Example: -1 in 32-bit two's complement
        #10; // Delay for 10ns
        // Test above the upper bound
        in_data = 32'h80000000; // Example: Minimum value in 32-bit two's complement
        #10; // Delay for 10ns
       // Test within bounds
        in_data = 32'h40000000; // Example: Some value within bounds
        #10; // Delay for 10ns

        // End the simulation
        $finish;
    end

endmodule

