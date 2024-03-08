module i2c_driver #(parameter clock = 100000000)
(
    input clk,
    input rst,

    input start_i,
    input [7:0] i2c_addrr,
    input [7:0] i2c_data_addrr_i,
    input [7:0] i2c_data_i,

    output [7:0] i2c_data_o,
    output reg resend,
    // I2C Ports
    inout sda,
    output scl,
    //
    output reg busy,
    output reg valid
);

    //    localparam TIME_1SEC   =50000000;   //(INTERVAL/clock);// Clock ticks in 1 sec
    localparam TIME_THDSTA =400; //(600/clock);     // 0.6 us
    localparam TIME_TSUSTA =470; //(600/clock);     // 0.6 us
    localparam TIME_THIGH  =400; //(600/clock);     // 0.6 us
    localparam TIME_TLOW   =470; //(1300/clock);    // 1.3 us
    localparam TIME_TSUDAT =25; //(20/clock);      // 0.02 us
    localparam TIME_TSUSTO =400; //(600/clock);     // 0.6 us
    localparam TIME_THDDAT =25; //(30/clock);      // 0.03 us
    //    reg [9:0] I2C_ADDR     =7'h40;   // 0x40 - 0x41 - 0x70 - 0x71
    localparam I2CBITS = 29;

    reg sda_en;
    reg scl_en;

    reg [28:0] i2c_data;
    reg [28:0] i2c_capt;

    reg [31:0]counter;
    reg counter_reset;

    reg [4:0] bit_count;
    reg [7:0] temp_data;
    reg [7:0] i2c_addr_reg;
    reg capture_en;

    reg ack_received;
    reg nack_received;

    assign scl = scl_en ? 1'bz : 1'b0;
    assign sda = sda_en ? 1'bz : 1'b0;
    assign i2c_data_o = temp_data;

    reg [2:0] fsm_state;
    parameter IDLE  = 0;
    parameter START = 1;
    parameter TLOW  = 2;
    parameter TSU   = 3;
    parameter THIGH = 4;
    parameter THD   = 5;
    parameter TSTO  = 6;

    always @(posedge clk)begin
        if (rst)begin
            temp_data       <= 8'b0;
            i2c_addr_reg    <= 8'b0;
            scl_en          <= 1'b0;
            sda_en          <= 1'b0;
            counter_reset   <= 1'b0;
            counter         <= 32'b0;
            bit_count       <= 5'b0;

            fsm_state       <= 3'b0;
            busy            <= 1'b0;
            valid           <= 1'b0;

            i2c_data        <= 29'b0;
            i2c_capt        <= 29'b0;

            ack_received    <= 1'b0;
            nack_received   <= 1'b0;
            resend          <= 1'b0;
        end
        else begin
            capture_en =  (i2c_addr_reg[0]) ? (i2c_capt[I2CBITS - bit_count - 1]) : (1'b0);
            scl_en  <= 1'b1;
            sda_en  <= i2c_data[I2CBITS - bit_count - 1];
            if(counter_reset)begin
                counter <= 32'b0;
                counter_reset <= 1'b0;
            end
            else begin
                counter <= counter + 1'b1;
            end
            case (fsm_state)
                IDLE:begin
                    i2c_data  <= {1'b0, i2c_addrr,   1'b1, i2c_data_addrr_i, 1'b1, i2c_data_i, 1'b1, 1'b1}; // 0 = write , 1 = read
                    i2c_capt  <= {1'b0, 7'h00, 1'b0, 1'b0, 8'h00,            1'b0, 8'hFF,      1'b0, 1'b0};
                    i2c_addr_reg <= i2c_addrr;
                    bit_count <= 5'b0;
                    sda_en    <= 1'b1; // Force to 1 in the beginning.
                    ack_received    <= 1'b0;
                    nack_received   <= 1'b0;
                    resend          <= 1'b0;
                    valid           <= 1'b0;
                    busy            <= (start_i) ? (1'b1) : (1'b0);
                    counter_reset   <= (start_i) ? (1'b0) : (1'b1);
                    fsm_state       <= (start_i) ? (START) : (IDLE);
                end
                START:begin
                    sda_en <= 1'b0;
                    if(counter == TIME_THDSTA)begin
                        scl_en <= 1'b0;
                        fsm_state <= TLOW;
                        counter_reset <= 1'b1;
                    end
                end
                TLOW:begin
                    scl_en <= 1'b0;
                    if(counter == TIME_TLOW)begin
                        bit_count <= bit_count + 1'b1;
                        fsm_state <= TSU;
                        counter_reset <= 1'b1;
                    end
                end
                TSU:begin
                    scl_en <= 1'b0;
                    if(counter == TIME_TSUSTA)begin
                        fsm_state <= THIGH;
                        counter_reset <= 1'b1;
                    end
                end
                THIGH:begin
                    scl_en <= 1'b1;
                    if(counter == TIME_THIGH)begin
                        if(bit_count==5'd9 || bit_count==5'd18 || bit_count==5'd27)begin
                            ack_received <= (!sda) ? (1'b1) : (1'b0);
                        end
                        if(capture_en)begin
                            temp_data <= temp_data << 1 | sda;
                        end
                        fsm_state <= THD;
                        counter_reset <= 1'b1;
                    end
                end
                THD:begin
                    scl_en <= 1'b0;
                    if (counter == TIME_THDDAT) begin
                        counter_reset <= 1'b1;
                        fsm_state <= (bit_count == I2CBITS) ? TSTO : TLOW;
                    end
                    if((bit_count==5'd9 || bit_count==5'd18 || bit_count==5'd27) && !ack_received)begin
                        fsm_state <= IDLE;
                        resend <= 1'b1;
                        nack_received <= 1'b1;
                    end
                end
                TSTO:begin
                    if (counter == TIME_TSUSTO) begin
                        counter_reset <= 1'b1;
                        fsm_state <= IDLE;
                        valid <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////