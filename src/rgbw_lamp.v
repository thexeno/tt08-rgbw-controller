// (C) Copyright 2017 Enrico Sanino
// License:     This project is licensed with the CERN Open Hardware Licence
//              v1.2.  You may redistribute and modify this project under the
//              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
//              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
//              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
//              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
//              v.1.2 for applicable Conditions.

module tt_um_thexeno_rgbw_controller (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset;
    // wire clk12;
    //wire sck0;
    wire mosi;
    wire cs;
    // wire red_pin;
    // wire green_pin;
    // wire blue_pin;
    // wire white_pin;
    // Internal signals
    //wire clkSys_shared;
    // wire clkSys_pwm;
    // wire clkSys_des;
    // wire red_sig;
    // wire green_sig;
    // wire blue_sig;
    // wire white_sig;
    wire rdy;
    wire sck;
    // wire [7:0] rDuty;
    // wire [7:0] gDuty;
    // wire [7:0] bDuty;
    // wire [7:0] wDuty;
    wire [7:0] mode_spi_w;
    wire [7:0] buffRx_spi;
    wire [3:0] byte_cnt_spi_w;
    // wire [7:0] lint_sync;
    // wire [7:0] red_sync;
    // wire [7:0] green_sync;
    // wire [7:0] blue_sync;
    // wire [7:0] white_sync;
    // wire [7:0] colorIdx_sync;
    // wire [7:0] mode_sync;
    // wire [7:0] a, b;
    // wire [15:0] result;
    // wire load;
    // wire m_rdy;
    wire clk_div_en;
    wire clk_sys_shared;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in[6], ui_in[2:0], uio_in[7:0], 1'b0};
    assign uio_oe = 8'hff;
    assign uio_out = mode_spi_w;
    //assign uo_out[7] = clk_sys_shared;
    assign uo_out[3:0] = byte_cnt_spi_w;
    assign uo_out[4] = clk_sys_shared;
    assign uo_out[7:5] = 0;

    assign reset = rst_n;
    assign sck = ui_in[5];
    assign mosi = ui_in[3];
    assign cs = ui_in[4];
    assign clk_div_en = ui_in[7];
    // assign red_pin = uo_out[0];
    // assign green_pin = uo_out[1];
    // assign blue_pin = uo_out[2];
    // assign white_pin = uo_out[3];


    // Output assignments
    //assign dbg = sck0 & reset;
    // assign red_pin = red_sig;
    // assign green_pin = green_sig;
    // assign blue_pin = blue_sig;
    // assign white_pin = white_sig;
    // assign red_pwr = red_pin;
    // assign green_pwr = green_pin;
    // assign blue_pwr = blue_pin;
    // assign white_pwr = white_pin;
    //assign clkSys_shared = clk12;
    //assign buffRx_spi_o = buffRx_spi;
    //assign rdy_o = rdy;

    // Components instantiation
    clockDividerPwm clockFeeder (
        .clk(clk),
        //.clkPresc(clkSys_shared),
        .clkPresc(clk_sys_shared),
        .reset(clk_div_en)
    ) /* synthesis syn_noprune=1 */;



    // mult8x8 mult (
    //     .clk(clk12),
    //     .reset(reset),
    //     .ld(load),
    //     .mult_rdy(m_rdy),
    //     .a(a),
    //     .b(b),
    //     .result(result)        
    // );

    // pwmGen pwm (
    //     .clk(clkSys_shared),
    //     .reset(reset),
    //     .duty0(rDuty),
    //     .duty1(gDuty),
    //     .duty2(bDuty),
    //     .duty3(wDuty),
    //     .d0(red_pin),
    //     .d1(green_pin),
    //     .d2(blue_pin),
    //     .d3(white_pin)
    // ) /* synthesis syn_noprune=1 */;

    // colorGen color (
    //     .clk(clkSys_shared),
    //     .reset(reset),
    //     .mult1(a),
    //     .mult2(b),
    //     .mult_res(result),
    //     .mult_ok(m_rdy),
    //     .ld(load),
    //     .mode(mode_sync),
    //     .lint(lint_sync),
    //     .colorIdx(colorIdx_sync),
    //     .whiteIn(white_sync),
    //     .redIn(red_sync),
    //     .greenIn(green_sync),
    //     .blueIn(blue_sync),
    //     .redOut(rDuty),
    //     .greenOut(gDuty),
    //     .blueOut(bDuty),
    //     .whiteOut(wDuty)
    // ) /* synthesis syn_noprune=1 */;

    

    rgbw_data_dispencer deserializer (
        .buffRx_spi(buffRx_spi),
        .reset(reset),
        .rdy(rdy),
        .clk(clk),
        .byte_cnt_spi_out(byte_cnt_spi_w),
        .mode_spi(mode_spi_w)
    ) /* synthesis syn_noprune=1 */;

    spiSlave spi_rx (
        .sck(sck),
        .cs(cs), 
        .clk(clk),
        .mosi(mosi),
        .reset(reset),
        .rdy_sig(rdy),
        .data_byte(buffRx_spi)
    ) /* synthesis syn_noprune=1 */;

    // // // Process for synchronous reset
    // // always @(posedge clk12) begin
    // //     if (clk12) begin
    // //         reset_sync <= reset;
    // //     end
    // // end
    // // not needed as all module have sync reset


endmodule