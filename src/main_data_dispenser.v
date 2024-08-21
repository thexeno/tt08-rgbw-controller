// (C) Copyright 2017 Enrico Sanino
// License:     This project is licensed with the CERN Open Hardware Licence
//              v1.2.  You may redistribute and modify this project under the
//              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
//              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
//              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
//              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
//              v.1.2 for applicable Conditions.

module rgbw_data_dispencer (
    input wire [7:0] buffRx_spi,
    input wire reset,
    input wire rdy,
    input wire clk,
    input wire clk_half,
    output wire [7:0] lint_spi_out,
    output wire [7:0] red_spi_out,
    output wire [7:0] green_spi_out,
    output wire [7:0] blue_spi_out,
    output wire [7:0] white_spi_out,
    output wire [7:0] colorIdx_spi_out,
    output wire [7:0] mode_spi_out
);

    reg [7:0] lint_spi_out_reg;
    reg [7:0] red_spi_out_reg;
    reg [7:0] green_spi_out_reg;
    reg [7:0] blue_spi_out_reg;
    reg [7:0] white_spi_out_reg;
    reg [7:0] colorIdx_spi_out_reg;
    reg [7:0] mode_spi_out_reg;

    reg [7:0] lint_spi;
    reg [7:0] red_spi;
    reg [7:0] green_spi;
    reg [7:0] blue_spi;
    reg [7:0] white_spi;
    reg [7:0] colorIdx_spi;
    reg [7:0] byte_cnt_spi;
    reg rdy_latch;
    reg rdy_prev;
    //reg sync_char = 1'b0;

    assign lint_spi_out = lint_spi_out_reg;
    assign red_spi_out = red_spi_out_reg;
    assign green_spi_out = green_spi_out_reg;
    assign blue_spi_out  = blue_spi_out_reg;
    assign white_spi_out = white_spi_out_reg;
    assign colorIdx_spi_out = colorIdx_spi_out_reg;
    assign mode_spi_out  = mode_spi_out_reg;

always @(posedge clk) 
begin
   if (clk_half == 1'b0)
   begin
    if (reset == 1'b0)  begin
                lint_spi_out_reg <= 8'b00000000;
                red_spi_out_reg <= 8'b00000000;
                green_spi_out_reg <= 8'b00000000;
                blue_spi_out_reg <= 8'b00000000;
                white_spi_out_reg <= 8'b00000000;
                colorIdx_spi_out_reg <= 8'b00000000;
                mode_spi_out_reg <= 8'b00000000;
                lint_spi <= 8'b00000000;
                colorIdx_spi <= 8'b00000000;
                white_spi <= 8'b00000000;
                red_spi <= 8'b00000000;
                green_spi <= 8'b00000000;
                blue_spi <= 8'b00000000;
                byte_cnt_spi <= 8'b00000000;
                rdy_prev <= 1'b0;
                //sync_char <= 1'b0;
                // lint_sync <= 8'b00000000;
                // colorIdx_sync <= 8'b00000000;
                // white_sync <= 8'h00;
                // red_sync <= 8'h00;
                // green_sync <= 8'h00;
                // blue_sync <= 8'h00;
                // mode_sync <= 8'h00;
                // lint_spi_out <= lint_spi;
                // colorIdx_spi_out <= 8'b00000000;
                // red_spi_out <= 8'b00000000;
                // green_spi_out <= 8'b00000000;
                // blue_spi_out <= 8'b00000000;
                // white_spi_out <= 8'b00000000;
                rdy_latch <= 1'b0;
            end 
            else 
            begin
                rdy_prev <= rdy_latch;
                rdy_latch <= rdy;
            if (rdy_prev == 1'b0 && rdy_latch == 1'b1) begin
                case (byte_cnt_spi)
                
                    0: begin
                        if (buffRx_spi == 8'h55) begin
                            byte_cnt_spi <= byte_cnt_spi + 1;
                        end
                    end
                    1: begin
                      lint_spi <= buffRx_spi;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    2: begin
                      colorIdx_spi_out_reg <= buffRx_spi;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    3: begin
                        red_spi <= buffRx_spi;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    4: begin
                        green_spi <= buffRx_spi;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    5: begin
                       blue_spi <= buffRx_spi;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    6: begin
                        white_spi <= buffRx_spi;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    7: begin
                        mode_spi_out_reg <= buffRx_spi; // rimani in questo stato sempre fino a nuovo RDY
                        byte_cnt_spi <= 0;
                        lint_spi_out_reg <= lint_spi;
                        colorIdx_spi_out_reg <= colorIdx_spi;
                        red_spi_out_reg <= red_spi;     //are 16bit for optimizing the reuslt of mult in color_Gen, works better with the synthesizer
                        green_spi_out_reg <= green_spi;
                        blue_spi_out_reg <= blue_spi;
                        white_spi_out_reg <= white_spi;
                    end
                    default: 
                    begin
                    byte_cnt_spi <= 0;
                    lint_spi <= 0;
                    colorIdx_spi <= 0;
                    red_spi <= 0;
                    green_spi <= 0;
                    blue_spi <= 0;
                    white_spi <= 0;
                    end
                endcase
            end
            end
    end
end
endmodule