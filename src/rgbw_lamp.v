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
    wire red_pin;
    wire green_pin;
    wire blue_pin;
    wire white_pin;
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
//*    wire [7:0] r_duty_w;
//*    wire [7:0] g_duty_w;
//*    wire [7:0] b_duty_w;
//*    wire [7:0] w_duty_w;
//*    wire [7:0] mode_spi_w;
//*    wire [7:0] white_spi_w;
    wire [7:0] buffRx_spi;
//*    wire [7:0] lint_spi_w;
//*    wire [7:0] red_spi_w;
//*    wire [7:0] green_spi_w;
//*    wire [7:0] blue_spi_w;
//*    wire [7:0] colorIdx_spi_w;
//*    wire [7:0] a;
//*    wire [7:0] b;
//*    wire [15:0] result;
//*    wire load;
//*    wire m_rdy;
    wire clk_div_en;
    wire clk_sys_shared;

    reg [7:0] uo_out_reg = 0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in[6], uio_in[7:0], 1'b0};
    //assign uo_out = (r_duty_w && g_duty_w && w_duty_w);

    assign uo_out = uo_out_reg;
    assign uio_oe = 8'hff;
    assign uio_out = 0;
    //assign uo_out[7] = clk_sys_shared;
    //assign uo_out = white_spi_w;

    assign reset = rst_n;
    assign sck = ui_in[5];
    assign mosi = ui_in[3];
    assign cs = ui_in[4];
    assign clk_div_en = ui_in[7];
    // assign uo_out[0] = red_pin;
    // assign uo_out[1] = green_pin;
    // assign uo_out[2] = blue_pin ;
    // assign uo_out[3] = white_pin;
    // assign uo_out[7:4] = 4'b0000;

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
    //     .clk(clk),
    //     .reset(reset),
    //     .ld(load),
    //     .mult_rdy(m_rdy),
    //     .a(a),
    //     .b(b),
    //     .result(result)        
    // );

    // pwmGen pwm (
    //     .clk(clk),
    //     .clk_half(clk_sys_shared),
    //     .reset(reset),
    //     .duty0(r_duty_w),
    //     .duty1(g_duty_w),
    //     .duty2(b_duty_w),
    //     .duty3(w_duty_w),
    //     .d0(red_pin),
    //     .d1(green_pin),
    //     .d2(blue_pin),
    //     .d3(white_pin)
    // ) /* synthesis syn_noprune=1 */;

    // colorGen color (
    //     .clk(clk),
    //     .clk_half(clk_sys_shared),
    //     .reset(reset),
    //     .mult1(a),
    //     .mult2(b),
    //     .mult_res(result),
    //     .mult_ok(m_rdy),
    //     .ld(load),
    //     .mode(mode_spi_w),
    //     .lint(lint_spi_w),
    //     .colorIdx(colorIdx_spi_w),
    //     .whiteIn(white_spi_w),
    //     .redIn(red_spi_w),
    //     .greenIn(green_spi_w),
    //     .blueIn(blue_spi_w),
    //     .redOut(r_duty_w),
    //     .greenOut(g_duty_w),
    //     .blueOut(b_duty_w),
    //     .whiteOut(w_duty_w)
    // ) /* synthesis syn_noprune=1 */;

    

    // rgbw_data_dispencer deserializer (
    //     .buffRx_spi(buffRx_spi),
    //     .clk_half(clk_sys_shared),
    //     .reset(reset),
    //     .rdy(rdy),
    //     .clk(clk),
    //     .lint_spi_out(lint_spi_w),
    //     .red_spi_out(red_spi_w),
    //     .green_spi_out(green_spi_w),
    //     .blue_spi_out(blue_spi_w),
    //     .colorIdx_spi_out(colorIdx_spi_w),
    //     .white_spi_out(white_spi_w),
    //     .mode_spi_out(mode_spi_w)
    // ) /* synthesis syn_noprune=1 */;

    spiSlave spi_rx (
        .sck(sck),
        .cs(cs), 
        .clk(clk),
        .clk_half(clk_sys_shared),
        .mosi(mosi),
        .reset(reset),
        .rdy_sig(rdy),
        .data(buffRx_spi)
    ) /* synthesis syn_noprune=1 */;

always @(posedge clk) 
begin
    case(ui_in[2:0])
        0: uo_out_reg <= buffRx_spi;
        1: uo_out_reg <= {7'b0000000, rdy};
          
        default:
          uo_out_reg <= 8'hff;
       
    endcase
end


    // // // Process for synchronous reset
    // // always @(posedge clk12) begin
    // //     if (clk12) begin
    // //         reset_sync <= reset;
    // //     end
    // // end
    // // not needed as all module have sync reset


endmodule