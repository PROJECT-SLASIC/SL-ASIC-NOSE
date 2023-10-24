module comparator #(parameter width=8)(
    input [31:0] X,
    input [31:0] Y,
    output [8:0] dif,
    output [31:0] outB,
    output [31:0] outL
    );
    wire [8:0] exp1,exp2;
    wire [23:0] mantis1,mantis2;
    wire [8:0] diffexp;
    wire [23:0] diffmantis;
    wire control;
    assign exp1 = {1'b0,X[30:23]};
    assign exp2 = {1'b0,Y[30:23]};
    assign mantis1 ={1'b0,X[22:0]};
    assign mantis2 ={1'b0,Y[22:0]};
    
    
    assign diffexp = exp1-exp2;
    assign diffmantis = mantis1-mantis2;
    assign control = (diffexp==0)&& diffmantis[23];
    
    assign outB = (diffexp[8]|| control) ? (Y) : (X);    
    assign outL = (diffexp[8]|| control) ? (X) : (Y);  
    assign dif  = (diffexp[8]) ?  (~diffexp+1):(diffexp)    ;
endmodule
