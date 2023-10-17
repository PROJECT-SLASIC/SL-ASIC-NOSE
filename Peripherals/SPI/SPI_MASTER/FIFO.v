module FIFO(
    input clk,
    input rst_n,
    input wr_en,
    input [7:0] wr_data,
    input rd_en,
    output reg [7:0] rd_data,
    output empty,
    output full
    );
    
    parameter DEPTH = 128; // Default depth, can be changed as needed
    
    reg [7:0] mem [0:DEPTH-1];
    reg [9:0] wr_ptr = 0;
    reg [9:0] rd_ptr = 0;
    reg [10:0] count = 0;
    
    always @(posedge clk) begin
        if (rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
            rd_data <= 8'b0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
                count <= count + 1'b1;
            end
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
                count <= count - 1'b1;
            end
        end
    end
    
    assign empty = (count == 0);
    assign full = (count == DEPTH);

endmodule
