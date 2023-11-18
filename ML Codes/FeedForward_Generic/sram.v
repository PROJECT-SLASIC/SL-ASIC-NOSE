module sram(
input clk,
input rst,
input [31:0] data_in,
input wr,
input rd,
input [7:0]adr,
output [31:0] data_out
    );
    
reg [31:0] data [0:127];    
always@(posedge clk) begin 
if(wr) data[adr]<= data_in;
end    

assign data_out = rd ? data[adr] : 32'hzzzzzzzz ;
endmodule
