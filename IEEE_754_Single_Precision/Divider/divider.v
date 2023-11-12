module divider #(parameter width=32)(
input clk,
input rst,
input start,
input[width-1:0] dividened ,
input[width-1:0] divisor,
output reg busy,
output reg valid,
output reg [width-1:0] out_reg
    );
    parameter idle=4'd0;
    parameter initialize=4'd1;
    parameter compute=4'd2;
    parameter final=4'd3;
    
    wire[4:0] count;
    leading_finder first(
    .data(divisor[22:0]),
    .count(count)
);
    wire[31:0] out;
    wire [7:0] out_wire;
    reg finish;
    reg control;
    reg start_reg;
    reg [3:0]state;
    wire [8:0] diff ; 
    assign out[width-1] = dividened[width-1] ^ divisor[width-1];
    assign diff = {1'b0,dividened[30:23]} - {1'b0,divisor[30:23]};
    assign out_wire= diff[8] ? diff[7:0]+127  : diff[7:0]+127 ; 
    assign out[30:23] = control ? (out_wire-8'd1) : out_wire ;
    wire [24:0] temp_mantissa1,temp_mantissa2;
    reg [5:0]i ;
    reg [48:0]mantissa1,mantissa2;
    reg [23:0]result;
    assign temp_mantissa1 = mantissa1[48:24];
    assign temp_mantissa2 = mantissa2[48:24];
    assign out [22:0]=result[22:0];
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mantissa1<=0;
            mantissa2<=0;
            result<=0;
            control<=0;
            i<=0;
            state<=idle;
            start_reg<=0;
            finish<=0;
            busy<=0;
            valid<=0;
        end
        
        else begin
            if(start)start_reg<=1;
                case(state) 
                    idle:begin  
                         if( dividened==0 || divisor==0 || dividened[30:23]==255 || divisor[30:23]==255 ) begin
                               if(dividened==0)out_reg<=0;
                               if(divisor==0)out_reg<=32'h7f800000;
                               if(dividened[30:23]==255)out_reg<=32'h7f800000;
                               if(divisor[30:23]==255)out_reg<=0;
                               valid<=1;
                        end
                        else begin
                            mantissa1<={25'b0,1'b1,dividened[22:0]};
                            mantissa2<={25'b0,1'b1,divisor[22:0]};
                            valid<=0;
                            if (start_reg)begin 
                                state<=initialize; 
                            end  
                        end        
                    end
          
                    initialize:begin
                        mantissa1<=mantissa1<<count;
                        mantissa2<=mantissa2<<count;
                        state<=compute;
                        busy<=1;
                    end
                    
                    final:begin
                        out_reg<=out;
                        state<=idle;
                        start_reg<=0;
                        i<=0;
                        control<=0;
                        valid<=1;
                        busy<=0;
                    end
                 
                    compute:begin
                        if(i<24)begin
                            if(temp_mantissa1>=temp_mantissa2)begin 
                                mantissa1[48:25]<= temp_mantissa1[23:0]-temp_mantissa2[23:0];
                                mantissa1[24:0]<= mantissa1[24:0]<<1;
                                result<= result<<1;
                                result[0]<=1;
                                i<=i+1;
                            end
                            else begin
                                if(i==0)control<=1;
                                mantissa1<= mantissa1<<1;
                                result<= result<<1;
                                result[0]<=0;     
                                i<=i+1;       
                            end
                        end
                        else begin
                            if(control)begin
                                result<=result<<1;        
                            end
                            state<=final;
                        end
                    end
                    endcase
            end
        end
endmodule

module leading_finder(
    input [22:0] data,
    output reg [4:0] count
);

always @(*) begin
        if       (data[0]) count =  5'd24;
        else if  (data[1]) count =  5'd23;
        else if  (data[2]) count =  5'd22;
        else if  (data[3]) count =  5'd21;
        else if  (data[4]) count =  5'd20;
        else if  (data[5]) count =  5'd19;
        else if  (data[6]) count =  5'd18;
        else if  (data[7]) count =  5'd17;
        else if  (data[8]) count =  5'd16;
        else if  (data[9]) count =  5'd15;
        else if  (data[10]) count = 5'd14;
        else if  (data[11]) count = 5'd13;
        else if  (data[12]) count = 5'd12;
        else if  (data[13]) count = 5'd11;
        else if  (data[14]) count = 5'd10;
        else if  (data[15]) count = 5'd9;
        else if  (data[16]) count = 5'd8;
        else if  (data[17]) count = 5'd7;
        else if  (data[18])  count = 5'd6;
        else if  (data[19])  count = 5'd5;
        else if  (data[20])  count = 5'd4;
        else if  (data[21])  count = 5'd3;
        else if  (data[22])  count = 5'd2;
        else count = 5'd1;
    end
endmodule
