// (C) Copyright 2017 Enrico Sanino
// License:     This project is licensed with the CERN Open Hardware Licence
//              v1.2.  You may redistribute and modify this project under the
//              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
//              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
//              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
//              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
//              v.1.2 for applicable Conditions.

module colorGen (
    input wire clk,
    input wire reset,
    input wire [7:0] mode,
    input wire [7:0] lint,
    input wire [7:0] colorIdx,
    input wire [7:0] whiteIn,
    input wire [7:0] redIn,
    input wire [7:0] greenIn,
    input wire [7:0] blueIn,
    output reg [7:0] redOut,
    output reg [7:0] greenOut,
    output reg [7:0] blueOut,
    output reg [7:0] whiteOut
);

localparam init = 4'd0;
localparam thr1 = 4'd1;
localparam thr2 = 4'd2;
localparam thr3 = 4'd3;
localparam thr4 = 4'd4;
localparam thr5 = 4'd5;
localparam thr6 = 4'd6;
localparam thr7 = 4'd7;
localparam finalAdj = 4'd8;
localparam stateApply = 4'd9;




    // typedef enum reg [3:0] {
    //     init,
    //     thr1,
    //     thr2,
    //     thr3,
    //     thr4,
    //     thr5,
    //     thr6,
    //     thr7,
    //     finalAdj,
    //     stateApply
    // } state_type;

    reg[15:0] temp_result = 16'h0000;
    reg [7:0] r = 8'b00000000;
    reg [7:0] g = 8'b00000000;
    reg [7:0] b = 8'b00000000;
    integer r_temp = 8'b00000000;
    integer g_temp = 8'b00000000;
    reg [7:0] b_temp = 8'b00000000;
    wire [7:0] b_plus;
    wire [7:0] r_plus;
    wire [7:0] b_minus;
    wire [7:0] r_minus;
    reg [7:0] w = 8'b00000000;
    reg [7:0] w_m = 8'b00000000;
    reg [7:0] lint_sig = 8'b00000000;
    reg [7:0] thr = 8'b00000000;
    reg [7:0] counter = 8'b00000000;
    reg [7:0] w_sig = 8'b00000000;
    reg [7:0] mode_latch = 8'b00000000;
    reg [7:0] buff_white = 8'b00000000;
    reg [2:0] lint_comp = 3'b000;
    reg reset_sig;

    reg [3:0] state = 4'd0;

    assign b_plus = b + 8'b00000111;
    assign b_minus = b - 8'b00000111;
    assign r_plus = r + 8'b00000111;
    assign r_minus = r - 8'b00000111;

    always @(posedge clk) begin
        reset_sig <= reset;
        if (reset_sig == 1'b0) begin
            state <= init;
            thr <= 8'b00000000;
            lint_sig <= 8'b00000000;
            counter <= 8'b00000000;
            r <= 8'b00000000;
            g <= 8'b00000000;
            b <= 8'b00000000;
            r_temp <= 8'b00000000;
            g_temp <= 8'b00000000;
            b_temp <= 8'b00000000;
            w <= 8'b00000000;
            buff_white <= 8'b00000000;
            mode_latch <= 8'b00000000;
            whiteOut <= 8'b00000000;
            redOut <= 8'b00000000;
            greenOut <= 8'b00000000;
            blueOut <= 8'b00000000;
            lint_comp <= 3'b000;
        end else begin
            mode_latch <= mode;
            buff_white <= whiteIn;
            
            case (state)
                init: begin
                    r <= 8'b11111111;
                    g <= 8'b00000000;
                    b <= 8'b00000000;
                    w <= whiteIn;
                    thr <= colorIdx;
                    lint_sig <= lint;
                    counter <= 8'b00000000;
                    if (mode_latch == 8'h21) begin
                        whiteOut <= whiteIn;
                        redOut <= redIn;
                        greenOut <= greenIn;
                        blueOut <= blueIn;
                        state <= init;
                    end else if (mode_latch == 8'ha4) begin
                        state <= thr1;
                    end else begin
                        state <= init;
                    end
                end

                thr1: begin
                      
                    r <= 8'b11111111;
                    g <= 8'b00000000;
                    if (b_plus < 8'b00000111) begin // overflow EVENTUALLY SEPARAE COMB LOGICIN A DIFFERENT BLOCK
                        b <= 8'hff;
                    end 
                    else begin
                       b <= b_plus; 
                    end
                    counter <= counter + 1;
                    if (counter < 8'h24 && counter < thr) begin                    
                        state <= thr1;                       
                    end else if (counter >= 8'h24 && counter < thr) begin
                        state <= thr2;                               
                    end else begin
                        state <= finalAdj;
                    end
                end

                thr2: begin
                    if (r_minus > 8'hF8) begin // underflow
                        r <= 8'h00;
                    end 
                    else begin
                       r <= r_minus; 
                    end
                    g <= 8'b00000000;
                    b <= 8'b11111111;
                    counter <= counter + 1;
                    if (counter < 8'h48 && counter <= thr) begin
                        state <= thr2;
                    end else if (counter >= 8'h48 && counter <= thr) begin
                        state <= thr3;
                    end else begin
                        state <= finalAdj;
                    end
                end

                thr3: begin
                    r <= 8'b00000000;
                    g <= g + 8'b00000111;           
                    b <= 8'b11111111;
                    counter <= counter + 1;
                    if (counter < 8'h6c && counter <= thr) begin
                        state <= thr3;
                    end else if (counter >= 8'h6c && counter <= thr) begin
                        state <= thr4;
                    end else begin
                        state <= finalAdj;
                    end
                end

                thr4: begin
                    r <= 8'b00000000;
                    g <= 8'b11111111;
                    b <= b - 8'b00000111;         
                    counter <= counter + 1;
                    if (counter < 8'h90 && counter <= thr) begin
                        state <= thr4;
                    end else if (counter >= 8'h90 && counter <= thr) begin
                        state <= thr5;
                    end else begin
                        state <= finalAdj;
                    end
                end

                thr5: begin
                    r <= r + 8'b00000111;                       
                    g <= 8'b11111111;
                    b <= 8'b00000000;
                    counter <= counter + 1;
                    if (counter < 8'hb4 && counter <= thr) begin
                        state <= thr5;
                    end else if (counter >= 8'hb4 && counter <= thr) begin
                        state <= thr6;
                    end else begin
                        state <= finalAdj;
                    end
                end

                thr6: begin
                    r <= 8'b11111111;
                    g <= g - 8'b00000111;  
                    b <= 8'b00000000;
                    counter <= counter + 1;
                    if (counter < 8'hd8 && counter <= thr) begin
                        state <= thr6;
                    end else if (counter >= 8'hd8 && counter <= thr) begin
                        state <= thr7;
                    end else begin
                        state <= finalAdj;
                    end
                end

                thr7: begin
                    r <= 8'b11111111;
                    g <= 8'b00000000;
                    b <= 8'b00000000;
                    state <= finalAdj;
                end

                finalAdj: begin
                    if ({1'b0, r} + {1'b0, buff_white} > 9'b011111111) r <= 8'hFF;
                    else r <= r + buff_white;

                    if ({1'b0, g} + {1'b0, buff_white} > 9'b011111111) g <= 8'hFF;
                    else g <= g + buff_white;

                    if ({1'b0, b} + {1'b0, buff_white} > 9'b011111111) b <= 8'hFF;
                    else b <= b + buff_white;

                    state <= stateApply;
                end

                stateApply: begin 
                
        if (buff_white[7]) temp_result = temp_result + (lint_sig << 7);
        if (buff_white[6]) temp_result = temp_result + (lint_sig << 6);
        if (buff_white[5]) temp_result = temp_result + (lint_sig << 5);
        if (buff_white[4]) temp_result = temp_result + (lint_sig << 4);
        if (buff_white[3]) temp_result = temp_result + (lint_sig << 3);
        if (buff_white[2]) temp_result = temp_result + (lint_sig << 2);
        if (buff_white[1]) temp_result = temp_result + (lint_sig << 1);
        if (buff_white[0]) temp_result = temp_result + lint_sig;

        // Shift the result right by 8 to fit it within 8 bits
        buff_white <= (temp_result >> 8);
       

                    // case (lint_comp)
                    //     3'b000: begin
                    //         whiteOut <= buff_white;
                    //         redOut <= r;
                    //         greenOut <= g;
                    //         blueOut <= b;
                    //     end
                    //     3'b001: begin
                    //         whiteOut <= buff_white >> 1;
                    //         redOut <= r >> 1;
                    //         greenOut <= g >> 1;
                    //         blueOut <= b >> 1;
                    //     end
                    //     3'b010: begin
                    //         whiteOut <= buff_white >> 2;
                    //         redOut <= r >> 2;
                    //         greenOut <= g >> 2;
                    //         blueOut <= b >> 2;
                    //     end
                    //     3'b011: begin
                    //         whiteOut <= buff_white >> 3;
                    //         redOut <= r >> 3;
                    //         greenOut <= g >> 3;
                    //         blueOut <= b >> 3;
                    //     end
                    //     3'b100: begin
                    //         whiteOut <= buff_white >> 4;
                    //         redOut <= r >> 4;
                    //         greenOut <= g >> 4;
                    //         blueOut <= b >> 4;
                    //     end
                    //     3'b101: begin
                    //         whiteOut <= buff_white >> 5;
                    //         redOut <= r >> 5;
                    //         greenOut <= g >> 5;
                    //         blueOut <= b >> 5;
                    //     end
                    //     3'b110: begin
                    //         whiteOut <= buff_white >> 6;
                    //         redOut <= r >> 6;
                    //         greenOut <= g >> 6;
                    //         blueOut <= b >> 6;
                    //     end
                    //     3'b111: begin
                    //         whiteOut <= buff_white >> 7;
                    //         redOut <= r >> 7;
                    //         greenOut <= g >> 7;
                    //         blueOut <= b >> 7;
                    //     end
                    //     default: begin
                    //         whiteOut <= 8'b00000000;
                    //         redOut <= 8'b00000000;
                    //         greenOut <= 8'b00000000;
                    //         blueOut <= 8'b00000000;
                    //     end
                    // endcase

                    state <= init;
                end

                default: state <= init;
            endcase
        end
    end

endmodule