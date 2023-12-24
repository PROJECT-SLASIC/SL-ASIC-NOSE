module lcd_driver(
    input clk, //
    input rst, //
    input start_lcd, //
    input [2:0] selective,

    output scl, //
    inout sda //
);

    localparam TIME_20ms = 1000000;
    localparam TIME_5ms = 250000;
    localparam TIME_3ms = 150000;

    reg start_dut;
    reg [7:0] i2c_addrr_dut;
    reg [7:0] i2c_data_addrr_i_dut;
    reg [7:0] i2c_data_i_dut;

    wire [7:0] i2c_data_o_dut;
    wire resend_dut;

    wire busy_dut;
    wire valid_dut;

    i2c_driver I2C(
        . clk(clk),
        . rst(rst),

        . start_i(start_dut),
        . i2c_addrr(i2c_addrr_dut),
        . i2c_data_addrr_i(i2c_data_addrr_i_dut),
        . i2c_data_i(i2c_data_i_dut),

        . i2c_data_o(i2c_data_o_dut),
        . resend(resend_dut),
        // I2C Ports
        . sda(sda),
        . scl(scl),
        . busy(busy_dut),
        . valid(valid_dut)
    );

    reg [2:0] state;
    parameter IDLE = 0;
    parameter INITIALIZE_LCD  = 1;
    parameter WRITE_LCD  = 2;
    parameter COMPLETED  = 3;

    reg [7:0] sequences [1:0][2:0]; // Clear Display
    reg [7:0] sequences_1 [19:0][2:0]; // Weather
    reg [7:0] sequences_2 [19:0][2:0]; // Hazelnut
    reg [7:0] sequences_3 [19:0][2:0]; // Cookie
    reg [7:0] sequences_4 [19:0][2:0]; // Rulokat
    reg [7:0] sequences_5 [19:0][2:0]; // Salad
    reg [7:0] sequences_6 [19:0][2:0]; // Orange
    reg [7:0] sequences_7 [19:0][2:0]; // Error


    reg [9:0] counter_1;
    reg [31:0] counter;
    reg counter_reset;
    reg wait_ok;
    reg lcd_initialize_ok;
    reg clear_display ;
    reg [2:0] selective_reg;

    reg [2:0] state_1;
    parameter PART_1 = 0;
    parameter PART_2  = 1;

    initial begin
        /////////////////////////
        // Clear Display
        /////////////////////////
        sequences[0][0] = 8'h4e; sequences[0][1] = 8'h0C; sequences[0][2] = 8'h08; // high nibble  - blink cursor
        sequences[1][0] = 8'h4e; sequences[1][1] = 8'h1C; sequences[1][2] = 8'h18;
        /////////////////////////
        // Weather
        /////////////////////////
        sequences_1[0][0] = 8'h4e; sequences_1[0][1] = 8'h0C; sequences_1[0][2] = 8'h08; // high nibble  - blink cursor
        sequences_1[1][0] = 8'h4e; sequences_1[1][1] = 8'hfC; sequences_1[1][2] = 8'hf8;

        sequences_1[2][0] = 8'h4e; sequences_1[2][1] = 8'h8C; sequences_1[2][2] = 8'h88; // high nibble - ddram position
        sequences_1[3][0] = 8'h4e; sequences_1[3][1] = 8'h0C; sequences_1[3][2] = 8'h08;

        sequences_1[4][0] = 8'h4e; sequences_1[4][1] = 8'h5D; sequences_1[4][2] = 8'h59; // high nibble - W into 1_1
        sequences_1[5][0] = 8'h4e; sequences_1[5][1] = 8'h7D; sequences_1[5][2] = 8'h79;

        sequences_1[6][0] = 8'h4e; sequences_1[6][1] = 8'h6D; sequences_1[6][2] = 8'h69; // high nibble - e into 1_2
        sequences_1[7][0] = 8'h4e; sequences_1[7][1] = 8'h5D; sequences_1[7][2] = 8'h59;

        sequences_1[8][0] = 8'h4e; sequences_1[8][1] = 8'h6D; sequences_1[8][2] = 8'h69; // high nibble - a into 1_1
        sequences_1[9][0] = 8'h4e; sequences_1[9][1] = 8'h1D; sequences_1[9][2] = 8'h19;

        sequences_1[10][0] = 8'h4e; sequences_1[10][1] = 8'h7D; sequences_1[10][2] = 8'h79; // high nibble - t into 1_1
        sequences_1[11][0] = 8'h4e; sequences_1[11][1] = 8'h4D; sequences_1[11][2] = 8'h49;

        sequences_1[12][0] = 8'h4e; sequences_1[12][1] = 8'h6D; sequences_1[12][2] = 8'h69; // high nibble - h into 1_2
        sequences_1[13][0] = 8'h4e; sequences_1[13][1] = 8'h8D; sequences_1[13][2] = 8'h89;

        sequences_1[14][0] = 8'h4e; sequences_1[14][1] = 8'h6D; sequences_1[14][2] = 8'h69; // high nibble - e into 1_1
        sequences_1[15][0] = 8'h4e; sequences_1[15][1] = 8'h5D; sequences_1[15][2] = 8'h59;

        sequences_1[16][0] = 8'h4e; sequences_1[16][1] = 8'h7D; sequences_1[16][2] = 8'h79; // high nibble - r into 1_1
        sequences_1[17][0] = 8'h4e; sequences_1[17][1] = 8'h2D; sequences_1[17][2] = 8'h29;

        sequences_1[18][0] = 8'h4e; sequences_1[18][1] = 8'h2D; sequences_1[18][2] = 8'h29; // high nibble - # into 1_1
        sequences_1[19][0] = 8'h4e; sequences_1[19][1] = 8'h3D; sequences_1[19][2] = 8'h39;
        /////////////////////////
        // Hazelnut
        /////////////////////////
        sequences_2[0][0] = 8'h4e; sequences_2[0][1] = 8'h0C; sequences_2[0][2] = 8'h08; // high nibble  - blink cursor
        sequences_2[1][0] = 8'h4e; sequences_2[1][1] = 8'hfC; sequences_2[1][2] = 8'hf8;

        sequences_2[2][0] = 8'h4e; sequences_2[2][1] = 8'h8C; sequences_2[2][2] = 8'h88; // high nibble - ddram position
        sequences_2[3][0] = 8'h4e; sequences_2[3][1] = 8'h0C; sequences_2[3][2] = 8'h08;

        sequences_2[4][0] = 8'h4e; sequences_2[4][1] = 8'h4D; sequences_2[4][2] = 8'h49; // high nibble - H into 1_1
        sequences_2[5][0] = 8'h4e; sequences_2[5][1] = 8'h8D; sequences_2[5][2] = 8'h89;

        sequences_2[6][0] = 8'h4e; sequences_2[6][1] = 8'h6D; sequences_2[6][2] = 8'h69; // high nibble - a into 1_2
        sequences_2[7][0] = 8'h4e; sequences_2[7][1] = 8'h1D; sequences_2[7][2] = 8'h19;

        sequences_2[8][0] = 8'h4e; sequences_2[8][1] = 8'h7D; sequences_2[8][2] = 8'h79; // high nibble - z into 1_1
        sequences_2[9][0] = 8'h4e; sequences_2[9][1] = 8'hAD; sequences_2[9][2] = 8'hA9;

        sequences_2[10][0] = 8'h4e; sequences_2[10][1] = 8'h6D; sequences_2[10][2] = 8'h69; // high nibble - e into 1_1
        sequences_2[11][0] = 8'h4e; sequences_2[11][1] = 8'h5D; sequences_2[11][2] = 8'h59;

        sequences_2[12][0] = 8'h4e; sequences_2[12][1] = 8'h6D; sequences_2[12][2] = 8'h69; // high nibble - l into 1_2
        sequences_2[13][0] = 8'h4e; sequences_2[13][1] = 8'hCD; sequences_2[13][2] = 8'hC9;

        sequences_2[14][0] = 8'h4e; sequences_2[14][1] = 8'h6D; sequences_2[14][2] = 8'h69; // high nibble - n into 1_1
        sequences_2[15][0] = 8'h4e; sequences_2[15][1] = 8'hED; sequences_2[15][2] = 8'hE9;

        sequences_2[16][0] = 8'h4e; sequences_2[16][1] = 8'h7D; sequences_2[16][2] = 8'h79; // high nibble - u into 1_1
        sequences_2[17][0] = 8'h4e; sequences_2[17][1] = 8'h5D; sequences_2[17][2] = 8'h59;

        sequences_2[18][0] = 8'h4e; sequences_2[18][1] = 8'h7D; sequences_2[18][2] = 8'h79; // high nibble - t into 1_1
        sequences_2[19][0] = 8'h4e; sequences_2[19][1] = 8'h4D; sequences_2[19][2] = 8'h49;
        /////////////////////////
        // Cookie
        /////////////////////////
        sequences_3[0][0] = 8'h4e; sequences_3[0][1] = 8'h0C; sequences_3[0][2] = 8'h08; // high nibble  - blink cursor
        sequences_3[1][0] = 8'h4e; sequences_3[1][1] = 8'hfC; sequences_3[1][2] = 8'hf8;

        sequences_3[2][0] = 8'h4e; sequences_3[2][1] = 8'h8C; sequences_3[2][2] = 8'h88; // high nibble - ddram position
        sequences_3[3][0] = 8'h4e; sequences_3[3][1] = 8'h0C; sequences_3[3][2] = 8'h08;

        sequences_3[4][0] = 8'h4e; sequences_3[4][1] = 8'h4D; sequences_3[4][2] = 8'h49; // high nibble - C into 1_1
        sequences_3[5][0] = 8'h4e; sequences_3[5][1] = 8'h3D; sequences_3[5][2] = 8'h39;

        sequences_3[6][0] = 8'h4e; sequences_3[6][1] = 8'h6D; sequences_3[6][2] = 8'h69; // high nibble - o into 1_2
        sequences_3[7][0] = 8'h4e; sequences_3[7][1] = 8'hFD; sequences_3[7][2] = 8'hF9;

        sequences_3[8][0] = 8'h4e; sequences_3[8][1] = 8'h6D; sequences_3[8][2] = 8'h69; // high nibble - o into 1_1
        sequences_3[9][0] = 8'h4e; sequences_3[9][1] = 8'hFD; sequences_3[9][2] = 8'hF9;

        sequences_3[10][0] = 8'h4e; sequences_3[10][1] = 8'h6D; sequences_3[10][2] = 8'h69; // high nibble - k into 1_1
        sequences_3[11][0] = 8'h4e; sequences_3[11][1] = 8'hBD; sequences_3[11][2] = 8'hB9;

        sequences_3[12][0] = 8'h4e; sequences_3[12][1] = 8'h6D; sequences_3[12][2] = 8'h69; // high nibble - i into 1_2
        sequences_3[13][0] = 8'h4e; sequences_3[13][1] = 8'h9D; sequences_3[13][2] = 8'h99;

        sequences_3[14][0] = 8'h4e; sequences_3[14][1] = 8'h6D; sequences_3[14][2] = 8'h69; // high nibble - e into 1_1
        sequences_3[15][0] = 8'h4e; sequences_3[15][1] = 8'h5D; sequences_3[15][2] = 8'h59;

        sequences_3[16][0] = 8'h4e; sequences_3[16][1] = 8'h2D; sequences_3[16][2] = 8'h29; // high nibble - # into 1_1
        sequences_3[17][0] = 8'h4e; sequences_3[17][1] = 8'h3D; sequences_3[17][2] = 8'h39;

        sequences_3[18][0] = 8'h4e; sequences_3[18][1] = 8'h2D; sequences_3[18][2] = 8'h29; // high nibble - # into 1_1
        sequences_3[19][0] = 8'h4e; sequences_3[19][1] = 8'h3D; sequences_3[19][2] = 8'h39;
        /////////////////////////
        // Rulokat
        /////////////////////////
        sequences_4[0][0] = 8'h4e; sequences_4[0][1] = 8'h0C; sequences_4[0][2] = 8'h08; // high nibble  - blink cursor
        sequences_4[1][0] = 8'h4e; sequences_4[1][1] = 8'hfC; sequences_4[1][2] = 8'hf8;

        sequences_4[2][0] = 8'h4e; sequences_4[2][1] = 8'h8C; sequences_4[2][2] = 8'h88; // high nibble - ddram position
        sequences_4[3][0] = 8'h4e; sequences_4[3][1] = 8'h0C; sequences_4[3][2] = 8'h08;

        sequences_4[4][0] = 8'h4e; sequences_4[4][1] = 8'h5D; sequences_4[4][2] = 8'h59; // high nibble - R into 1_1
        sequences_4[5][0] = 8'h4e; sequences_4[5][1] = 8'h2D; sequences_4[5][2] = 8'h29;

        sequences_4[6][0] = 8'h4e; sequences_4[6][1] = 8'h7D; sequences_4[6][2] = 8'h79; // high nibble - u into 1_2
        sequences_4[7][0] = 8'h4e; sequences_4[7][1] = 8'h5D; sequences_4[7][2] = 8'h59;

        sequences_4[8][0] = 8'h4e; sequences_4[8][1] = 8'h6D; sequences_4[8][2] = 8'h69; // high nibble - l into 1_1
        sequences_4[9][0] = 8'h4e; sequences_4[9][1] = 8'hCD; sequences_4[9][2] = 8'hC9;

        sequences_4[10][0] = 8'h4e; sequences_4[10][1] = 8'h6D; sequences_4[10][2] = 8'h69; // high nibble - o into 1_1
        sequences_4[11][0] = 8'h4e; sequences_4[11][1] = 8'hFD; sequences_4[11][2] = 8'hF9;

        sequences_4[12][0] = 8'h4e; sequences_4[12][1] = 8'h6D; sequences_4[12][2] = 8'h69; // high nibble - k into 1_2
        sequences_4[13][0] = 8'h4e; sequences_4[13][1] = 8'hBD; sequences_4[13][2] = 8'hB9;

        sequences_4[14][0] = 8'h4e; sequences_4[14][1] = 8'h6D; sequences_4[14][2] = 8'h69; // high nibble - a into 1_1
        sequences_4[15][0] = 8'h4e; sequences_4[15][1] = 8'h1D; sequences_4[15][2] = 8'h19;

        sequences_4[16][0] = 8'h4e; sequences_4[16][1] = 8'h7D; sequences_4[16][2] = 8'h79; // high nibble - t into 1_1
        sequences_4[17][0] = 8'h4e; sequences_4[17][1] = 8'h4D; sequences_4[17][2] = 8'h49;

        sequences_4[18][0] = 8'h4e; sequences_4[18][1] = 8'h2D; sequences_4[18][2] = 8'h29; // high nibble - # into 1_1
        sequences_4[19][0] = 8'h4e; sequences_4[19][1] = 8'h3D; sequences_4[19][2] = 8'h39;
        /////////////////////////
        // Salad
        /////////////////////////
        sequences_5[0][0] = 8'h4e; sequences_5[0][1] = 8'h0C; sequences_5[0][2] = 8'h08; // high nibble  - blink cursor
        sequences_5[1][0] = 8'h4e; sequences_5[1][1] = 8'hfC; sequences_5[1][2] = 8'hf8;

        sequences_5[2][0] = 8'h4e; sequences_5[2][1] = 8'h8C; sequences_5[2][2] = 8'h88; // high nibble - ddram position
        sequences_5[3][0] = 8'h4e; sequences_5[3][1] = 8'h0C; sequences_5[3][2] = 8'h08;

        sequences_5[4][0] = 8'h4e; sequences_5[4][1] = 8'h5D; sequences_5[4][2] = 8'h59; // high nibble - S into 1_1
        sequences_5[5][0] = 8'h4e; sequences_5[5][1] = 8'h3D; sequences_5[5][2] = 8'h39;

        sequences_5[6][0] = 8'h4e; sequences_5[6][1] = 8'h6D; sequences_5[6][2] = 8'h69; // high nibble - a into 1_2
        sequences_5[7][0] = 8'h4e; sequences_5[7][1] = 8'h1D; sequences_5[7][2] = 8'h19;

        sequences_5[8][0] = 8'h4e; sequences_5[8][1] = 8'h6D; sequences_5[8][2] = 8'h69; // high nibble - l into 1_1
        sequences_5[9][0] = 8'h4e; sequences_5[9][1] = 8'hCD; sequences_5[9][2] = 8'hC9;

        sequences_5[10][0] = 8'h4e; sequences_5[10][1] = 8'h6D; sequences_5[10][2] = 8'h69; // high nibble - a into 1_1
        sequences_5[11][0] = 8'h4e; sequences_5[11][1] = 8'h1D; sequences_5[11][2] = 8'h19;

        sequences_5[12][0] = 8'h4e; sequences_5[12][1] = 8'h6D; sequences_5[12][2] = 8'h69; // high nibble - d into 1_2
        sequences_5[13][0] = 8'h4e; sequences_5[13][1] = 8'h4D; sequences_5[13][2] = 8'h49;

        sequences_5[14][0] = 8'h4e; sequences_5[14][1] = 8'h2D; sequences_5[14][2] = 8'h29; // high nibble - # into 1_1
        sequences_5[15][0] = 8'h4e; sequences_5[15][1] = 8'h3D; sequences_5[15][2] = 8'h39;

        sequences_5[16][0] = 8'h4e; sequences_5[16][1] = 8'h2D; sequences_5[16][2] = 8'h29; // high nibble - # into 1_1
        sequences_5[17][0] = 8'h4e; sequences_5[17][1] = 8'h3D; sequences_5[17][2] = 8'h39;

        sequences_5[18][0] = 8'h4e; sequences_5[18][1] = 8'h2D; sequences_5[18][2] = 8'h29; // high nibble - # into 1_1
        sequences_5[19][0] = 8'h4e; sequences_5[19][1] = 8'h3D; sequences_5[19][2] = 8'h39;
        /////////////////////////
        // Orange
        /////////////////////////
        sequences_6[0][0] = 8'h4e; sequences_6[0][1] = 8'h0C; sequences_6[0][2] = 8'h08; // high nibble  - blink cursor
        sequences_6[1][0] = 8'h4e; sequences_6[1][1] = 8'hfC; sequences_6[1][2] = 8'hf8;

        sequences_6[2][0] = 8'h4e; sequences_6[2][1] = 8'h8C; sequences_6[2][2] = 8'h88; // high nibble - ddram position
        sequences_6[3][0] = 8'h4e; sequences_6[3][1] = 8'h0C; sequences_6[3][2] = 8'h08;

        sequences_6[4][0] = 8'h4e; sequences_6[4][1] = 8'h4D; sequences_6[4][2] = 8'h49; // high nibble - O into 1_1
        sequences_6[5][0] = 8'h4e; sequences_6[5][1] = 8'hFD; sequences_6[5][2] = 8'hF9;

        sequences_6[6][0] = 8'h4e; sequences_6[6][1] = 8'h7D; sequences_6[6][2] = 8'h79; // high nibble - r into 1_2
        sequences_6[7][0] = 8'h4e; sequences_6[7][1] = 8'h2D; sequences_6[7][2] = 8'h29;

        sequences_6[8][0] = 8'h4e; sequences_6[8][1] = 8'h6D; sequences_6[8][2] = 8'h69; // high nibble - a into 1_1
        sequences_6[9][0] = 8'h4e; sequences_6[9][1] = 8'h1D; sequences_6[9][2] = 8'h19;

        sequences_6[10][0] = 8'h4e; sequences_6[10][1] = 8'h6D; sequences_6[10][2] = 8'h69; // high nibble - n into 1_1
        sequences_6[11][0] = 8'h4e; sequences_6[11][1] = 8'hED; sequences_6[11][2] = 8'hE9;

        sequences_6[12][0] = 8'h4e; sequences_6[12][1] = 8'h6D; sequences_6[12][2] = 8'h69; // high nibble - g into 1_2
        sequences_6[13][0] = 8'h4e; sequences_6[13][1] = 8'h7D; sequences_6[13][2] = 8'h79;

        sequences_6[14][0] = 8'h4e; sequences_6[14][1] = 8'h6D; sequences_6[14][2] = 8'h69; // high nibble - e into 1_1
        sequences_6[15][0] = 8'h4e; sequences_6[15][1] = 8'h5D; sequences_6[15][2] = 8'h59;

        sequences_6[16][0] = 8'h4e; sequences_6[16][1] = 8'h2D; sequences_6[16][2] = 8'h29; // high nibble - # into 1_1
        sequences_6[17][0] = 8'h4e; sequences_6[17][1] = 8'h3D; sequences_6[17][2] = 8'h39;

        sequences_6[18][0] = 8'h4e; sequences_6[18][1] = 8'h2D; sequences_6[18][2] = 8'h29; // high nibble - # into 1_1
        sequences_6[19][0] = 8'h4e; sequences_6[19][1] = 8'h3D; sequences_6[19][2] = 8'h39;
        /////////////////////////
        // Error
        /////////////////////////
        sequences_7[0][0] = 8'h4e; sequences_7[0][1] = 8'h0C; sequences_7[0][2] = 8'h08; // high nibble  - blink cursor
        sequences_7[1][0] = 8'h4e; sequences_7[1][1] = 8'hfC; sequences_7[1][2] = 8'hf8;

        sequences_7[2][0] = 8'h4e; sequences_7[2][1] = 8'h8C; sequences_7[2][2] = 8'h88; // high nibble - ddram position
        sequences_7[3][0] = 8'h4e; sequences_7[3][1] = 8'h0C; sequences_7[3][2] = 8'h08;

        sequences_7[4][0] = 8'h4e; sequences_7[4][1] = 8'h4D; sequences_7[4][2] = 8'h49; // high nibble - E into 1_1
        sequences_7[5][0] = 8'h4e; sequences_7[5][1] = 8'h5D; sequences_7[5][2] = 8'h59;

        sequences_7[6][0] = 8'h4e; sequences_7[6][1] = 8'h7D; sequences_7[6][2] = 8'h79; // high nibble - r into 1_2
        sequences_7[7][0] = 8'h4e; sequences_7[7][1] = 8'h2D; sequences_7[7][2] = 8'h29;

        sequences_7[8][0] = 8'h4e; sequences_7[8][1] = 8'h7D; sequences_7[8][2] = 8'h79; // high nibble - r into 1_1
        sequences_7[9][0] = 8'h4e; sequences_7[9][1] = 8'h2D; sequences_7[9][2] = 8'h29;

        sequences_7[10][0] = 8'h4e; sequences_7[10][1] = 8'h6D; sequences_7[10][2] = 8'h69; // high nibble - o into 1_1
        sequences_7[11][0] = 8'h4e; sequences_7[11][1] = 8'hFD; sequences_7[11][2] = 8'hF9;

        sequences_7[12][0] = 8'h4e; sequences_7[12][1] = 8'h7D; sequences_7[12][2] = 8'h79; // high nibble - r into 1_2
        sequences_7[13][0] = 8'h4e; sequences_7[13][1] = 8'h29; sequences_7[13][2] = 8'h29;

        sequences_7[14][0] = 8'h4e; sequences_7[14][1] = 8'h2D; sequences_7[14][2] = 8'h29; // high nibble - # into 1_1
        sequences_7[15][0] = 8'h4e; sequences_7[15][1] = 8'h3D; sequences_7[15][2] = 8'h39;

        sequences_7[16][0] = 8'h4e; sequences_7[16][1] = 8'h2D; sequences_7[16][2] = 8'h29; // high nibble - # into 1_1
        sequences_7[17][0] = 8'h4e; sequences_7[17][1] = 8'h3D; sequences_7[17][2] = 8'h39;

        sequences_7[18][0] = 8'h4e; sequences_7[18][1] = 8'h2D; sequences_7[18][2] = 8'h29; // high nibble - # into 1_1
        sequences_7[19][0] = 8'h4e; sequences_7[19][1] = 8'h3D; sequences_7[19][2] = 8'h39;
    end

    always @(posedge clk)begin
        if (rst)begin
            start_dut <= 1'b0;
            i2c_addrr_dut <= 8'b0;
            i2c_data_addrr_i_dut <= 8'b0;
            i2c_data_i_dut <= 8'b0;

            state <= 3'b0;
            state_1 <= 3'b0;
            wait_ok <= 1'b0;
            lcd_initialize_ok <= 1'b0;
            clear_display <= 1'b0;
            selective_reg <= 3'b0;

            counter <= 32'b0;
            counter_1 <= 10'b0;
            counter_reset <= 1'b0;
        end
        else begin
            if(counter_reset)begin
                counter <= 32'b0;
                counter_reset <= 1'b0;
            end
            else begin
                counter <= counter + 1'b1;
            end
            case (state)
                IDLE:begin
                    counter_reset <= 1'b0;
                    start_dut <= 1'b0;
                    i2c_addrr_dut <= 8'b0;
                    i2c_data_addrr_i_dut <= 8'b0;
                    i2c_data_i_dut <= 8'b0;
                    state <= (start_lcd) ? ((!lcd_initialize_ok) ? (INITIALIZE_LCD) : (WRITE_LCD)) : (IDLE);
                    selective_reg <= (start_lcd) ? (selective) : (selective_reg);
                    counter_reset <= (start_lcd) ? (1'b0) : (1'b1);
                end
                INITIALIZE_LCD:begin
                    case (state_1)
                        PART_1:begin
                            if (counter==TIME_20ms)begin
                                counter_reset <= 1'b1;
                                wait_ok <= 1'b1;
                            end
                            else begin
                                wait_ok <= 1'b0;
                            end

                            if (wait_ok && !start_dut)begin
                                send_sequence_i2c(8'h4e,8'h3C,8'h38);
                                if (counter_1==10'd2)begin
                                    state_1 <= PART_2;
                                    wait_ok <= 1'b0;
                                    counter_1 <= 12'b0;
                                end
                                else begin
                                    state_1 <= PART_1;
                                    wait_ok <= 1'b1;
                                    counter_1 <= counter_1 + 1;
                                end
                            end
                            else begin
                                start_dut <= 1'b0;
                            end
                        end
                        PART_2:begin
                            if (counter==TIME_5ms)begin
                                counter_reset <= 1'b1;
                                wait_ok <= 1'b1;
                            end
                            else begin
                                wait_ok <= 1'b0;
                            end

                            if (wait_ok && !start_dut)begin
                                send_sequence_i2c(8'h4e,8'h2C,8'h28); // high nibble  - blink cursor
                                state_1 <= PART_1;
                                state <= WRITE_LCD;
                                lcd_initialize_ok <= 1'b1;
                            end
                            else begin
                                start_dut <= 1'b0;
                            end
                        end
                    endcase
                end
                WRITE_LCD:begin
                    if (counter==TIME_3ms)begin
                        counter_reset <= 1'b1;
                        wait_ok <= 1'b1;
                    end
                    else begin
                        wait_ok <= 1'b0;
                    end
                    if (wait_ok && !start_dut)begin
                        case (selective_reg)
                            3'b000:begin
                                if (counter_1 <= 10'd19) begin
                                    send_sequence_i2c(sequences_1[counter_1][0], sequences_1[counter_1][1], sequences_1[counter_1][2]);
                                    counter_1 <= counter_1 + 1;
                                end else begin
                                    counter_1 <= 10'd0;
                                    clear_display <= 1'b0;
                                    state <= COMPLETED;
                                end
                            end
                            3'b001:begin
                                if (counter_1 <= 10'd19) begin
                                    send_sequence_i2c(sequences_2[counter_1][0], sequences_2[counter_1][1], sequences_2[counter_1][2]);
                                    counter_1 <= counter_1 + 1;
                                end else begin
                                    counter_1 <= 10'd0;
                                    clear_display <= 1'b0;
                                    state <= COMPLETED;
                                end
                            end
                            3'b010:begin
                                if (counter_1 <= 10'd19) begin
                                    send_sequence_i2c(sequences_3[counter_1][0], sequences_3[counter_1][1], sequences_3[counter_1][2]);
                                    counter_1 <= counter_1 + 1;
                                end else begin
                                    counter_1 <= 10'd0;
                                    clear_display <= 1'b0;
                                    state <= COMPLETED;
                                end
                            end
                            3'b011:begin
                                if (counter_1 <= 10'd19) begin
                                    send_sequence_i2c(sequences_4[counter_1][0], sequences_4[counter_1][1], sequences_4[counter_1][2]);
                                    counter_1 <= counter_1 + 1;
                                end else begin
                                    counter_1 <= 10'd0;
                                    clear_display <= 1'b0;
                                    state <= COMPLETED;
                                end
                            end
                            3'b100:begin
                                if (counter_1 <= 10'd19) begin
                                    send_sequence_i2c(sequences_5[counter_1][0], sequences_5[counter_1][1], sequences_5[counter_1][2]);
                                    counter_1 <= counter_1 + 1;
                                end else begin
                                    counter_1 <= 10'd0;
                                    clear_display <= 1'b0;
                                    state <= COMPLETED;
                                end
                            end
                            3'b101:begin
                                if (counter_1 <= 10'd19) begin
                                    send_sequence_i2c(sequences_6[counter_1][0], sequences_6[counter_1][1], sequences_6[counter_1][2]);
                                    counter_1 <= counter_1 + 1;
                                end else begin
                                    counter_1 <= 10'd0;
                                    clear_display <= 1'b0;
                                    state <= COMPLETED;
                                end
                            end
                            3'b110,3'b111:begin
                                if (counter_1 <= 10'd19) begin
                                    send_sequence_i2c(sequences_7[counter_1][0], sequences_7[counter_1][1], sequences_7[counter_1][2]);
                                    counter_1 <= counter_1 + 1;
                                end else begin
                                    counter_1 <= 10'd0;
                                    clear_display <= 1'b0;
                                    state <= COMPLETED;
                                end
                            end
                        endcase
                    end
                    else begin
                        start_dut <= 1'b0;
                    end
                end
                COMPLETED: begin
                    if (!start_lcd) state <= IDLE; // Wait for start_lcd to be reset
                    start_dut <= 1'b0;
                end
            endcase
        end
    end

    task send_sequence_i2c;
        input [7:0] i2c_addr;
        input [7:0] data_addr;
        input [7:0] data;

        begin
            start_dut <= 1'b1;
            i2c_addrr_dut <= i2c_addr;
            i2c_data_addrr_i_dut <= data_addr;
            i2c_data_i_dut <= data;
            wait_ok <= 1'b0;
        end
    endtask
endmodule
