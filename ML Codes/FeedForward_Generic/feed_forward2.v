module feed_forward(
    input clk,
    input rst,
    input [31:0]data,
    input load,
    input load_neuron,
    input start,
    input [3:0]first_layer,second_layer,third_layer,fourth_layer,
    output reg oldu,
    output reg [2:0] class,
    output reg busy,
    output reg valid
    );
    
parameter initilaze= 0;
parameter rest=1;

parameter load_multiply= 0;
parameter start_multiply= 2;
parameter load_adder= 3;
parameter start_adder=4;

parameter waitt =6;

parameter adder_idle=0;
parameter add = 1;
parameter wait_add=2;
parameter store=3;

reg [1:0] ana;
reg [3:0]first_reg,second_reg,third_reg,fourth_reg;
reg counter;
reg [31:0]adder_temp1,adder_temp2;
reg adder_temp1_full,adder_temp2_full;
reg adder_load1,adder_load2;
reg start_load_mult;
reg write,read;
reg [8:0]adr;
wire [31:0] relu;
wire [31:0]sram_out,sram_in;   
reg sram_input;
sram ram1(
   .clk(clk),
   .rst(rst),
   .data_in(sram_in),
   .wr(write),
   .rd(read),
   .adr(adr),
   .data_out(sram_out)
    );    


reg [31:0] adder_input1,adder_input2;
reg adder_strt;  
wire adder_busy,adder_valid;
wire [31:0] adder_out;  

adder adder1(
   .input1(adder_input1),
   .input2(adder_input2),
   .clk(clk),
   .rst(rst),
   .strt(adder_strt),
   .valid(adder_valid),
   .busy(adder_busy),
   .out(adder_out)
    );    
    wire control;
 
    
reg [31:0] mult_input1[1:0]; 
reg [31:0] mult_input2[1:0]; 
reg mult1_start;
wire mult1_valid,mult1_busy;
wire [31:0] mult1_out;    
ieee_754_multiplier mult1(
    .clk(clk),
    .rst(rst),
    .rs1(mult_input1[0]),  
    .rs2(mult_input2[0]),  
    .start(mult1_start),
    .result(mult1_out),  
    .valid( mult1_valid),
    .busy(mult1_busy)
);

    

reg mult2_start;
wire mult2_valid,mult2_busy;
wire [31:0] mult2_out;  

ieee_754_multiplier mult2(
    .clk(clk),
    .rst(rst),
    .rs1(mult_input1[1]),  
    .rs2(mult_input2[1]),  
    .start(mult2_start),
    .result(mult2_out),  
    .valid(mult2_valid),
    .busy(mult2_busy)
);
reg control1,control2;

reg [2:0]load_mul;
reg load_reg;
 reg c,d; 



reg mult1_load,mult2_load;
reg [8:0] weight_adr=0,bias_adr,neuron_adr,neuron_adr_hold;    
reg [3:0]state;
reg [3:0]state_load;
reg [4:0]X;
reg [4:0]Y;
wire [8:0]adr_next,adr_next_weight,adr_next_neuron,adr_next_bias,next_store_adr; 
reg start_reg;

wire ok,ok_future,ok2,ok2_future;
wire next_load;

reg add_case;
reg [3:0]counter_first,counter_second,current,current2;
reg [8:0] first_layer_neuron_adr,secon_layer_neuron_adr,third_layer_neuron_adr,fourth_layer_neuron_adr,store_adr;
reg [3:0]main;
reg loaded;
reg add_finish,add_last;
assign ok = (current==counter_first);
assign ok_future= (counter_first+1 ==current );
assign ok2_future= (counter_second ==current2 );

assign adr_next = adr+1;
assign adr_next_weight= weight_adr+1;
assign adr_next_neuron= neuron_adr+1;
assign adr_next_bias= bias_adr+1;
assign next_store_adr= store_adr+1;

parameter first=0;
parameter second=1;
parameter third=2;
parameter fourth=3;
reg store_neuron;
reg [31:0] add_in_temp1,add_in_temp2;
reg [4:0]valid_counter,valid_current,valid_counter2,valid_current2;
reg [31:0]temp_bias;
reg a;
reg adder_temp_load1,adder_temp_load2;
reg finish;

  assign control= c ? 0: adder_out[31] ;
  assign relu = control ? 32'd0:adder_out ;
  assign sram_in= sram_input ? relu : data ;
  reg [3:0]decision;
  reg [31:0] bigger,temp;
  wire temp_control;
  wire sign,diff,diff_control;
  assign sign= bigger[31] ^ temp[31];
  wire bigger_control;
  wire[31:0] subs;
  assign subs={1'b0,bigger[30:0]}-{1'b0,temp[30:0]};
  assign diff= subs[31];
  assign diff_control= bigger[31] ? diff : ~diff  ; 
  assign bigger_control= sign ? ~bigger[31] : diff_control ;
  reg [2:0]index,i;
  reg load_neuron_reg;
  reg t;
 always@(posedge clk or posedge rst) begin 
 
    if (rst) begin 
        adr<=0; 
        X<=0; 
        Y<=0;  
        c<=0;
        load_mul<=0;
        start_reg<=0;
        load_reg<=0;
        start_load_mult<=0;
        state<=0;
        state_load<=0;
        load_mul<=0;
        mult1_load<=0;
        mult2_load<=0;
        counter_first<=0;
        counter_second<=0;
        adder_temp1_full<=0;
        adder_temp2_full<=0;
        current<=0;
        current2<=0;
        loaded<=0;
        first_layer_neuron_adr<=0;
        main<=0;
        adder_load1<=0;
        adder_load2<=0;
        add_finish<=0;
        add_last<=0;
        ana<=0;
        add_case<=0;
        store_neuron<=0;
        store_adr<=0;
        sram_input<=0;
        add_in_temp1<=0;
        add_in_temp2<=0;
        valid_counter<=0;
        valid_current<=0;
        valid_counter2<=0;
        valid_current2<=0;
        a<=0;
        adder_temp_load1<=0;
        adder_temp_load2<=0;
        finish<=0;
        oldu<=0;
        busy<=0;
        valid<=0;
        index<=0;
        i<=0;
        class<=0;
        decision<=0;
        load_neuron_reg<=0;
        d<=0;t<=0;
    end
    
    
    
    else begin
        
        if(valid) begin
        valid<=0;
        end  
        if(~start&&d)begin d<=0; end
        if (start&&~d)begin start_reg<=1; d<=1;end
        if (load) begin load_reg<=1; write<=1; end
        if(~load_neuron && d)begin d<=0;end 
        if(load_neuron &&~d)begin load_neuron_reg<=1;d<=1; end
        //veriyi register deposuna atma kısmı
        if(load_reg) begin
            if(data==32'h80000000) bias_adr<=adr;
            if(data==32'hffffffff) begin neuron_adr<=adr; first_layer_neuron_adr<=adr; end
            if(data==32'hfffffff0) begin 
                load_reg<=0; 
                write<=0; 
                end
            adr<= adr_next;
        end
        
        if(load_neuron_reg || load_neuron)begin
            if(t==0)begin
            neuron_adr<=9'h111;
            sram_input<=0;
            t<=1;
            end
            else begin
            if(i<=4)begin
                adr<=adr_next_neuron;
                neuron_adr<=adr_next_neuron;
                write<=1;
                read<=0;
                i<=i+1;
         end
         else begin 
                i<=0;
                load_neuron_reg<=0;
                write<=0;
                neuron_adr<=9'h111;
                t<=0;
         end
        end
        end
        
        
        
        if(oldu)begin
            case(decision)
            0:begin
                adr<=adr_next_neuron;
                neuron_adr<=adr_next_neuron;
                read<=1;
                write<=0;
                decision<=1;
            end
            1:begin
                bigger<=sram_out;
                adr<=adr_next_neuron;
                neuron_adr<=adr_next_neuron;
                decision<=2;
            end
            2:begin
                temp<=sram_out;
                adr<=adr_next_neuron;
                neuron_adr<=adr_next_neuron;
                decision<=3;
            end
            3:begin
                if(i<=3)begin
                    if(bigger_control)begin
                        decision<=2;
                        i<=i+1;
                    end
                    else begin
                        bigger<=temp;
                        decision<=2;
                        index<=i+1;
                        i<=i+1;

                    end
                end
                else begin
                    oldu<=0;
                    i<=0;
                    valid<=1;
                    busy<=0;
                    class<=index;
                    index<=0;
                    decision<=0;
                end    
            end
            endcase
        end
        
        if(start_reg && !load_reg) begin
            case(ana) 

            initilaze:begin
                
                    first_reg<=first_layer;
                    second_reg<=second_layer;
                    third_reg<=third_layer;
                    fourth_reg<=fourth_layer;
                    ana<=rest;
                    valid_current<=first_layer;
                    valid_current2<=second_layer;
                    current<=first_layer;
                    current2<=second_layer;
                    neuron_adr_hold<=9'h111;
                    store_adr<=9'h111+first_layer+1;
                     bias_adr<=9'hf3;
                    weight_adr<=0;
                    neuron_adr<=9'h111;
                    first_layer_neuron_adr<=9'h111;
                    c<=0; 
                    
            end

            rest:begin

             case(main)

                first:begin 
                    if(a)begin
                        temp_bias<=sram_out;
                        a<=0;
                    end
                    if(ok)begin
                        neuron_adr<= neuron_adr_hold;
                        read<=1;
                        adr<=adr_next_bias;
                        bias_adr<=adr_next_bias;
                        a<=1;
                    end

                    if(valid_current2==valid_counter2)begin
                        valid_current<=second_layer;
                        valid_current2<=third_layer;
                        main <= second;
                        valid_counter2<=0;
                    end 
                            
                    if(ok2_future)begin
                        current<=second_layer;
                        current2<=third_layer;
                        counter_second<=0;
                        neuron_adr_hold<=first_layer_neuron_adr+first_reg;
                        neuron_adr<=first_layer_neuron_adr+first_reg;
                    end
                end
        second: begin
           if(a)begin
            temp_bias<=sram_out;
            a<=0;
            end
            if(ok)begin
            neuron_adr<= neuron_adr_hold;
            read<=1;
            adr<=adr_next_bias;
            bias_adr<=adr_next_bias;
            a<=1;
                    end

            if(valid_current2==valid_counter2)begin
            valid_current<=third_layer;
            valid_current2<=fourth_layer;
            main <= third;
            valid_counter2<=0;
            
            end         
            if(ok2_future)begin
            
            current<=third_layer;
            current2<=fourth_layer;
            
            counter_second<=0;
            neuron_adr_hold<=neuron_adr_hold+second_reg;
            neuron_adr<=neuron_adr_hold+second_reg;
           
            end
         end
        third: begin 
            if(a)begin
            temp_bias<=sram_out;
            a<=0;
            end
            if(ok)begin
            neuron_adr<= neuron_adr_hold;
            read<=1;
            adr<=adr_next_bias;
            bias_adr<=adr_next_bias;
            a<=1;
                    end
            if (valid_counter2==1)begin
                c<=1;    
            end

            if(valid_current2 ==valid_counter2 && write)begin
            
          
            valid_counter2<=0;
            start_reg<=0;
            write<=0;
            read<=0;
            oldu<=1;
            finish<=0;
            ana<= 0;
            main<=first;
            state_load<=load_multiply;
            load_mul<=0;
            state<=adder_idle;
            
            
            end         
            if(ok2_future)begin
            finish<=1;
            
            current<=third_layer;
            current2<=fourth_layer;
            
            counter_second<=0;
            neuron_adr_hold<=neuron_adr_hold+third_reg;
            neuron_adr<=neuron_adr_hold+third_reg;
           
           
            end
        end
       endcase

        if(mult1_valid || mult2_valid)begin
            if(mult1_valid&& mult2_valid)begin
                valid_counter<= valid_counter+2;
            end
            else begin
                valid_counter<=valid_counter+1;
            end
        end
        if(valid_current==valid_counter)begin
            valid_counter<=0;
            add_finish<=1;
            valid_counter2<= valid_counter2+1;
        end
       
        if(current==counter_first)begin
            counter_first<=0;
            counter_second<= counter_second +1;            
        end

        if(loaded)begin
            counter_first <= counter_first +1;
            end
            case(state_load)

                load_multiply:begin
                    mult1_start<=0;
                    mult2_start<=0; 
                    if(~store_neuron && ~finish)begin
                    start_load_mult<=1;
                    load_mul<=0;
                    state_load<=start_multiply;
                    read<=1;
                    end
                end

                start_multiply:begin
                    if(loaded)loaded<=0;
                    if(~start_load_mult && mult1_load && !mult1_busy)begin
                        mult1_start<=1;
                        mult1_load<=0;
                        state_load<=load_multiply;
                        if(mult2_load)begin
                            mult2_start<=1; 
                            mult2_load<=0;
                        end
                    end
                end
            endcase

            if(start_load_mult && ~finish) begin
                case(load_mul)
                    0:begin
                        adr<=weight_adr;
                        load_mul<=1;
                    end
                    1:begin
                        mult_input1[0]<=sram_out;
                        weight_adr<= adr_next_weight;
                        adr<= adr_next_neuron;
                        load_mul<=2;
                    end
                    2:begin
                        mult_input2[0]<=sram_out;
                        neuron_adr<= adr_next_neuron;
                        adr<=weight_adr;
                        mult1_load<=1;
                        loaded<=1;
                        if(ok_future)begin
                        start_load_mult<=0;
                        end
                        load_mul<=3;
                       
                    end
                    3:begin
                        mult_input1[1]<=sram_out;
                        weight_adr<= adr_next_weight;
                        adr<= adr_next_neuron;
                        load_mul<=4;
                        loaded<=0;
                    end
                    4:begin
                        mult_input2[1]<=sram_out;
                        neuron_adr<= adr_next_neuron;
                        mult2_load<=1;
                        load_mul<=0;
                        start_load_mult<=0;
                        loaded<=1;
                    end
                endcase   
            end
            if(add_finish)begin
                if(mult1_valid && ~adder_temp_load1)begin
                    add_in_temp1<=mult1_out;
                    adder_temp_load1<=1;
                end
                if(mult2_valid && ~adder_temp_load2)begin
                    add_in_temp2<=mult2_out;
                    adder_temp_load2<=1;
                end 
            end
            else begin
            if(mult1_valid && ~adder_load1)begin
                    adder_input1<=mult1_out;
                    adder_load1<=1;
                end
            if(mult2_valid && ~adder_load2)begin
                    adder_input2<=mult2_out;
                    adder_load2<=1;
                end
            end

            case(state)

            adder_idle:begin
                if(add_finish && ~adder_load2 && ~adder_load1 )begin
                    adder_input2<=temp_bias;
                    adder_input1<=adder_out;
                    adder_load1<=1;
                    adder_load2<=1;
                    store_neuron<=1;
                    add_finish<=0;
                    adder_temp1_full<=0;
                    adder_temp2_full<=0;

                end
                if(add_finish && ~adder_load2 && adder_load1 )begin
                        adder_input2<=temp_bias;
                        adder_load2<=1; 
                        add_finish<=0;
                        store_neuron<=1;
                end

                else begin
               
                if(adder_load1 && adder_load2)begin
                    adder_strt<=1;
                    state<=add;
                    adder_load1<=0;
                    adder_load2<=0;
                end
                
            end
            end


            add:begin
                adder_strt<=0;
                
                if(adder_valid)begin
                    if(~adder_temp1_full)begin
                        
                        if(store_neuron)begin
                            state<=store;
                            write<=1;
                            store_neuron<=0;
                            adr<=store_adr;
                            store_adr<=next_store_adr;
                            sram_input<=1;
                        end
                        else begin
                            adder_temp1<=adder_out;
                            adder_temp1_full<=1;
                            state<=adder_idle;
                        end
                    end
                    else if(~adder_temp2_full)begin
                        adder_temp2<=adder_out;
                        adder_temp2_full<=1;
                        state<=wait_add;
                    end
                end
            end

            wait_add:begin
                adder_input1<=adder_temp1;
                adder_input2<=adder_temp2;
                adder_load1<=1;
                adder_load2<=1;
                adder_temp1_full<=0;
                adder_temp2_full<=0;
                state<=adder_idle;
                adder_temp1<=0;
                adder_temp2<=0;

            end

            store:begin
                write<=0;
                state<=adder_idle;
                store_neuron<=0;
                adder_temp1_full<=0;
                adder_temp2_full<=0;
                adder_temp1<=0;
                adder_temp2<=0;
                if(adder_temp_load1 )begin
                    adder_input2<=add_in_temp2;
                    adder_input1<=add_in_temp1;
                    adder_load1<=1;
                    adder_load2<=1;
                    adder_temp_load1<=0;
                    adder_temp_load2<=0;
                end

            end

            endcase
            end
            endcase
        end
        
    end
 end
endmodule
