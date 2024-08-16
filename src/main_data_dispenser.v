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
    output reg [7:0] lint_spi,
    output reg [7:0] red_spi,
    output reg [7:0] green_spi,
    output reg [7:0] blue_spi,
    output reg [7:0] white_spi,
    output reg [7:0] colorIdx_spi,
    output reg [7:0] mode_spi
);

    // reg [7:0] lint_spi = 8'b00000000;
    // reg [7:0] red_spi = 8'b00000000;
    // reg [7:0] green_spi = 8'b00000000;
    // reg [7:0] blue_spi = 8'b00000000;
    // reg [7:0] white_spi = 8'b00000000;
    // reg [7:0] colorIdx_spi = 8'b00000000;
    //reg [7:0] mode_spi = 8'b00000000;
    reg [7:0] buffRx_spi_latch = 8'b00000000;
    reg [3:0] byte_cnt_spi = 4'b0000;
    reg rdy_latch = 1'b0;
    reg rdy_prev = 1'b0;
    //reg sync_char = 1'b0;

always @(posedge clk) begin

   if (reset == 1'b0)  begin
            lint_spi <= 8'b00000000;
            colorIdx_spi <= 8'b00000000;
            white_spi <= 8'b00000000;
            red_spi <= 8'b00000000;
            green_spi <= 8'b00000000;
            blue_spi <= 8'b00000000;
           // mode_spi <= 8'b00000000;
            buffRx_spi_latch <= 8'b00000000;
            byte_cnt_spi <= 4'b0000;
            rdy_prev <= 1'b0;
            //sync_char <= 1'b0;
            // lint_sync <= 8'b00000000;
            // colorIdx_sync <= 8'b00000000;
            // white_sync <= 8'h00;
            // red_sync <= 8'h00;
            // green_sync <= 8'h00;
            // blue_sync <= 8'h00;
            // mode_sync <= 8'h00;
            rdy_latch <= 1'b0;
        end 
        else 
        begin
            rdy_prev <= rdy_latch;
            buffRx_spi_latch <= buffRx_spi;
            rdy_latch <= rdy;

            if (rdy_prev == 1'b0 && rdy_latch == 1'b1) begin
                case (byte_cnt_spi)
                    4'h0: begin
                        if (buffRx_spi_latch == 8'h55) begin
                            byte_cnt_spi <= byte_cnt_spi + 1;
                        end
                    end
                    4'h1: begin
                        lint_spi <= buffRx_spi_latch;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    4'h2: begin
                        colorIdx_spi <= buffRx_spi_latch;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    4'h3: begin
                        red_spi <= buffRx_spi_latch;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    4'h4: begin
                        green_spi <= buffRx_spi_latch;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    4'h5: begin
                        blue_spi <= buffRx_spi_latch;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    4'h6: begin
                        white_spi <= buffRx_spi_latch;
                        byte_cnt_spi <= byte_cnt_spi + 1;
                    end
                    4'h7: begin
                        //mode_sync <= buffRx_spi_latch; // rimani in questo stato sempre fino a nuovo RDY
                        byte_cnt_spi <= 4'h0;
                        //lint_sync <= lint_spi;
                        // colorIdx_sync <= colorIdx_spi;
                        // red_sync <= red_spi;     //are 16bit for optimizing the reuslt of mult in color_Gen, works better with the synthesizer
                        // green_sync <= green_spi;
                        // blue_sync <= blue_spi;
                        // white_sync <= white_spi;
                    end
                    default: byte_cnt_spi <= 4'h0;
                endcase
            end
        end
    end
endmodule