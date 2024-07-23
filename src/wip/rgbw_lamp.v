// (C) Copyright 2017 Enrico Sanino
// License:     This project is licensed with the CERN Open Hardware Licence
//              v1.2.  You may redistribute and modify this project under the
//              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
//              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
//              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
//              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
//              v.1.2 for applicable Conditions.

module rgbw_lamp (
    input reset,
    input clk12,
    input sck0,
    input mosi,
    input cs,
    output wire red_pin,
    output wire green_pin,
    output wire blue_pin,
    output wire white_pin,
    output wire dbg,
    output wire red_pwr,
    output wire green_pwr,
    output wire blue_pwr,
    output wire white_pwr
);

    // Internal signals
    wire clkSys_shared;
    wire clkSys_pwm;
    wire clkSys_des;
    wire red_sig;
    wire green_sig;
    wire blue_sig;
    wire white_sig;
    wire rdy;
    reg reset_sync;
    wire [7:0] rDuty;
    wire [7:0] gDuty;
    wire [7:0] bDuty;
    wire [7:0] wDuty;
    wire [7:0] buffRx_spi;
    wire [3:0] byte_cnt_spi;
    wire [7:0] lint_sync;
    wire [7:0] red_sync;
    wire [7:0] green_sync;
    wire [7:0] blue_sync;
    wire [7:0] white_sync;
    wire [7:0] colorIdx_sync;
    wire [7:0] mode_sync;

    // Output assignments
    assign dbg = sck0 & reset;
    // assign red_pin = red_sig;
    // assign green_pin = green_sig;
    // assign blue_pin = blue_sig;
    // assign white_pin = white_sig;
    assign red_pwr = red_pin;
    assign green_pwr = green_pin;
    assign blue_pwr = blue_pin;
    assign white_pwr = white_pin;
    assign clkSys_shared = clk12;

    // // Components instantiation
    // clockDividerPwm clockFeeder (
    //     .clk(clk12),
    //     .clkPresc(clkSys_shared),
    //     .reset(reset_sync)
    // ) /* synthesis syn_noprune=1 */;

    pwmGen pwm (
        .clk(clk12),
        .reset(reset_sync),
        .duty0(rDuty),
        .duty1(gDuty),
        .duty2(bDuty),
        .duty3(wDuty),
        .d0(red_pin),
        .d1(green_pin),
        .d2(blue_pin),
        .d3(white_pin)
    ) /* synthesis syn_noprune=1 */;

    colorGen color (
        .clk(clk12),
        .reset(reset_sync),
        .mode(mode_sync),
        .lint(lint_sync),
        .colorIdx(colorIdx_sync),
        .whiteIn(white_sync),
        .redIn(red_sync),
        .greenIn(green_sync),
        .blueIn(blue_sync),
        .redOut(rDuty),
        .greenOut(gDuty),
        .blueOut(bDuty),
        .whiteOut(wDuty)
    ) /* synthesis syn_noprune=1 */;

    

    rgbw_data_dispencer deserializer (
        .buffRx_spi(buffRx_spi),
        .reset(reset_sync),
        .rdy(rdy),
        .clk(clk12),
        .lint_sync(lint_sync),
        .red_sync(red_sync),
        .green_sync(green_sync),
        .blue_sync(blue_sync),
        .white_sync(white_sync),
        .colorIdx_sync(colorIdx_sync),
        .mode_sync(mode_sync)
    ) /* synthesis syn_noprune=1 */;

    spiSlave spi_rx (
        .sck(sck0),
        .cs(cs), 
        .clk(clk12),
        .mosi(mosi),
        .reset(reset_sync),
        .rdy(rdy),
        .data(buffRx_spi)
    ) /* synthesis syn_noprune=1 */;

    // Process for synchronous reset
    always @(posedge clk12) begin
        if (clk12) begin
            reset_sync <= reset;
        end
    end



endmodule