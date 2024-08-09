// (C) Copyright 2017 Enrico Sanino
// License:     This project is licensed with the CERN Open Hardware Licence
//              v1.2.  You may redistribute and modify this project under the
//              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
//              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
//              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
//              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
//              v.1.2 for applicable Conditions.

module colorGen
    (
        input wire clk,
        input wire reset,
        input wire mult_ok,
        output reg [7 : 0] mult1,
        output reg [7 : 0] mult2,
        input wire [15 : 0] mult_res,
        output reg ld,
        input wire [7 : 0] mode,
        input wire [7 : 0] lint,
        input wire [7 : 0] colorIdx,
        input wire [7 : 0] whiteIn,
        input wire [7 : 0] redIn,
        input wire [7 : 0] greenIn,
        input wire [7 : 0] blueIn,
        output reg [7 : 0] redOut,
        output reg [7 : 0] greenOut,
        output reg [7 : 0] blueOut,
        output reg [7 : 0] whiteOut,
        output wire [7 : 0] dbg,
        output wire mult_ok_dbg,
        output wire ld_dbg);

    localparam init = 4'd0;
    localparam thr1 = 4'd1;
    localparam thr2 = 4'd2;
    localparam thr3 = 4'd3;
    localparam thr4 = 4'd4;
    localparam thr5 = 4'd5;
    localparam thr6 = 4'd6;
    localparam thr6_a = 4'd7;
    localparam thr7 = 4'd8;
    localparam whiteSat = 4'd9;
    localparam finalAdj = 4'd10;
    localparam stateApply = 4'd11;
    localparam stateApply_R = 4'd12;
    localparam stateApply_G = 4'd13;
    localparam stateApply_B = 4'd14;

    localparam applyOut = 4'd15;

    assign dbg = state;
    assign mult_ok_dbg = mult_ok;
    assign ld_dbg = ld;

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

    reg [15 : 0] temp_result = 16'h0000;
    reg [7 : 0] r = 8'b00000000;
    reg [7 : 0] g = 8'b00000000;
    reg [7 : 0] b = 8'b00000000;
    reg [15 : 0] r_temp = 16'h0000;
    reg [15 : 0] g_temp = 16'h0000;
    reg [15 : 0] b_temp = 16'h0000;
    reg [15 : 0] w_temp = 16'h0000;
    reg [8 : 0] temp_ovf_r = 9'b000000000;
    reg [8 : 0] temp_ovf_b = 9'b000000000;
    reg [8 : 0] temp_ovf_g = 9'b000000000;
    // wire [7:0] b_plus;
    // wire [7:0] r_plus;
    // wire [7:0] b_minus;
    // wire [7:0] r_minus;
    reg [7 : 0] w = 8'b00000000;
    reg [7 : 0] w_m = 8'b00000000;
    reg [7 : 0] lint_sig = 8'b00000000;
    reg [7 : 0] thr = 8'b00000000;
    reg [7 : 0] counter = 8'b00000000;
    reg [7 : 0] w_sig = 8'b00000000;
    reg [7 : 0] mode_latch = 8'b00000000;
    // reg [2:0] lint_comp = 3'b000;
    reg reset_sig;

    reg [3 : 0] state = 4'd0;

    // assign b_plus = b + 8'b00000111;
    // assign b_minus = b - 8'b00000111;
    // assign r_plus = r + 8'b00000111;
    // assign r_minus = r - 8'b00000111;

    always @(posedge clk)
    begin
        reset_sig <= reset;
        if (reset_sig == 1'b0)
        begin
            state <= init;
            thr <= 8'b00000000;
            lint_sig <= 8'b00000000;
            counter <= 8'b00000000;
            r <= 8'b00000000;
            g <= 8'b00000000;
            b <= 8'b00000000;
            w <= 8'b00000000;
            mode_latch <= 8'b00000000;
            whiteOut <= 16'h0000;
            redOut <= 16'h0000;
            greenOut <= 16'h0000;
            blueOut <= 16'h0000;
            // lint_comp <= 3'b000;
        end
        else
        begin
            mode_latch <= mode;
            // mult_ok_latch <= mult_ok;
            // buff_white <= whiteIn;

            case (state)
            init: begin
                r <= 8'b00000000;
                g <= 8'b00000000;
                b <= 8'b00000000;
                w <= 8'b00000000;
                thr <= colorIdx;
                lint_sig <= lint;
                counter <= 8'b00000001;
                if (mode_latch == 8'h21)
                begin
                    whiteOut <= whiteIn;
                    redOut <= redIn;
                    greenOut <= greenIn;
                    blueOut <= blueIn;
                    state <= init;
                end
                else if (mode_latch == 8'ha4)
                begin
                    state <= thr1;
                end
                else
                begin
                    state <= init;
                end
            end

            thr1: begin
                temp_ovf_b = b + 8'b00000111;
                if (temp_ovf_b[8] == 1'b1) begin // overflow
                    b = 8'hff;
                end 
                else begin
                    b = temp_ovf_b[7:0]; 
                end           
                r = 8'b11111111;
                g = 8'b00000000;
                temp_ovf_b = 9'b000000000;
                counter = counter + 1;
                if (counter <= thr)
                begin
                    if (counter < 8'h2A)
                    begin
                        state <= thr1;
                    end
                    else
                    begin
                        state <= thr2;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            thr2: begin
                temp_ovf_r = r - 8'b00000111;
                if ((temp_ovf_r[8] == 1'b1)) begin // underflow
                    r = 8'h00;
                end 
                else begin
                    r = temp_ovf_r[7:0]; 
                end                   
                g = 8'b00000000;
                b = 8'b11111111;
                temp_ovf_r = 9'b000000000;
                counter = counter + 1;
                if (counter < thr)
                begin
                    if (counter < 8'h54)
                    begin
                        state <= thr2;
                    end
                    else
                    begin
                        state <= thr3;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            thr3: begin
                r = 8'b00000000;
                temp_ovf_g = g + 8'b00000111;
                if (temp_ovf_g[8] == 1'b1) begin // overflow
                    g = 8'hff;
                end 
                else begin
                    g = temp_ovf_g[7:0]; 
                end    
                b = 8'b11111111;
                temp_ovf_g = 9'b000000000;
                counter = counter + 1;
                if (counter < thr)
                begin
                    if (counter < 8'h7e)
                    begin
                        state <= thr3;
                    end
                    else
                    begin
                        state <= thr4;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            thr4: begin
                r = 8'b00000000;
                g = 8'b11111111;
                temp_ovf_b = b - 8'b00000111;
                if ((temp_ovf_b[8] == 1'b1)) begin // underflow
                    b = 8'h00;
                end 
                else begin
                    b = temp_ovf_b[7:0]; 
                end   
                temp_ovf_b = 9'b000000000;
                counter = counter + 1;
                if (counter <= thr)
                begin
                    if (counter < 8'hA8)
                    begin
                        state <= thr4;
                    end
                    else
                    begin
                        state <= thr5;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            thr5: begin
                temp_ovf_r = r + 8'b00000111;
                if (temp_ovf_r[8] == 1'b1) begin // overflow
                    r = 8'hff;
                end 
                else begin
                    r = temp_ovf_r[7:0]; 
                end    
                g = 8'b11111111;
                b = 8'b00000000;
                temp_ovf_r = 9'b000000000;
                counter = counter + 1;
                if (counter < thr)
                begin
                    if (counter < 8'hD2)
                    begin
                        state <= thr5;
                    end
                    else
                    begin
                        state <= thr6;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            thr6: begin
                r = 8'b11111111;
                temp_ovf_g = g - 8'b00000111;
                if ((temp_ovf_g[8] == 1'b1)) begin // underflow
                    g = 8'h00;  
                end 
                else begin
                 g = temp_ovf_g[7:0]; 
                end                  
                b = 8'b00000000;
                temp_ovf_g = 9'b000000000;
                counter = counter + 1;
                if (counter < thr)
                begin
                    if (counter < 8'hFC)
                    begin
                        state <= thr6;
                    end
                    else
                    begin
                        state <= whiteSat;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            // thr7: begin
            //     temp_ovf_b = b + 8'b00000111;
            //     if (temp_ovf_b[8] == 1'b1) begin // overflow
            //         b = 8'hff;
            //     end 
            //     else begin
            //         b = temp_ovf_b[7:0]; 
            //     end           
            //     r = 8'b11111111;
            //     g = 8'b00000000;
            //     temp_ovf_b = 9'b000000000;
            //     counter = counter + 1;
            //     if (counter < thr)
            //     begin
            //         if (counter <= 8'hff)
            //         begin
            //             state <= thr7;
            //         end
            //         else
            //         begin
            //             state <= whiteSat;
            //         end
            //     end
            //     else
            //     begin
            //         state <= whiteSat;
            //     end
            // end

            // thr7: begin
            //     r <= 8'b11111111;
            //     g <= 8'b00000000;
            //     b <= 8'b00000000;
            //     state <= whiteSat;
            // end

            whiteSat: begin

                // if ((r + whiteIn[15:8]) > 8'b11111111) r <= 8'hFF;
                // else r <= r + whiteIn[15:8]; //no w, optimized

                // if ((g + whiteIn[15:8]) > 8'b11111111) g <= 8'hFF;
                // else g <= g + whiteIn[15:8];

                // if ((b + whiteIn[15:8]) > 8'b11111111) b <= 8'hFF;
                // else b <= b + whiteIn[15:8];
                // temp_ovf = r + whiteIn[15:8];

                // Assign values based on overflow check
                if ({1'b0, r} + {1'b0, whiteIn} >= 9'b100000000) 
                    begin 
                        r <= 8'hff;
                    end
                else 
                    begin  
                        r <= r + whiteIn;
                    end

                if ({1'b0, g} + {1'b0, whiteIn} >= 9'b100000000) 
                    begin 
                        g <= 8'hff;
                    end
                else 
                    begin  
                        g <= g + whiteIn;
                    end

                if ({1'b0, b} + {1'b0, whiteIn} >= 9'b100000000) 
                    begin 
                        b <= 8'hff;
                    end
                else 
                    begin  
                        b <= b + whiteIn;
                    end
                // if (g[7] == whiteIn[15] == temp_ovf_g[8] == 1'b1) g = 8'hff;
                // else g = temp_ovf_g;
                // //temp_ovf = b + whiteIn[15:8];
                // if (b[7] == whiteIn[15] == temp_ovf_b[8] == 1'b1) b = 8'hff;
                // else b = temp_ovf_b;

                state <= stateApply;
                ld <= 1'b0;
            end

            stateApply: begin

                // Shift the result right by 8 to fit it within 8 bits
                // whiteOut <= (temp_result >> 8);
                mult1 <= lint_sig;
                mult2 <= whiteIn;
                if (mult_ok == 1'b0 && ld == 1'b0) // because i needed to be sure it was 0 and to put the rising edge only when mult ok was 0, meaning  the multiplicator was back in initial state. optimiziable, but i am in rush
                begin
                    ld <= 1'b1;
                end

                if (mult_ok == 1'b1)
                begin

                    state <= stateApply_R;
                    ld <= 1'b0;
                    w_temp <= mult_res;
                end

                // w_temp = (lint_sig * whiteIn);
            end

            stateApply_R: begin
                // redOut = (lint_sig * r);
                // r_temp = (lint_sig * r);
                // state <= stateApply_G;
                mult1 <= lint_sig;
                mult2 <= r;
                if (mult_ok == 1'b0 && ld == 1'b0)
                begin
                    ld <= 1'b1;
                end

                if (mult_ok == 1'b1)
                begin

                    state <= stateApply_G;
                    ld <= 1'b0;
                    r_temp <= mult_res;
                end
            end

            stateApply_G: begin
                // g_temp = (lint_sig * g);
                // state <= stateApply_B;
                mult1 <= lint_sig;
                mult2 <= g;
                if (mult_ok == 1'b0 && ld == 1'b0)
                begin
                    ld <= 1'b1;
                end

                if (mult_ok == 1'b1)
                begin

                    state <= stateApply_B;
                    ld <= 1'b0;
                    g_temp <= mult_res;
                end

                // if (lint_sig[0]) g_temp = g_temp + (g << 0);
                // if (lint_sig[1]) g_temp = g_temp + (g << 1);
                // if (lint_sig[2]) g_temp = g_temp + (g << 2);
                // if (lint_sig[3]) g_temp = g_temp + (g << 3);
                // if (lint_sig[4]) g_temp = g_temp + (g << 4);
                // if (lint_sig[5]) g_temp = g_temp + (g << 5);
                // if (lint_sig[6]) g_temp = g_temp + (g << 6);
                // if (lint_sig[7]) g_temp = g_temp + (g << 7);
            end

            stateApply_B: begin
                // b_temp = (lint_sig * b);

                //          state <= applyOut;
                //    end

                mult1 <= lint_sig;
                mult2 <= b;
                if (mult_ok == 1'b0 && ld == 1'b0)
                begin
                    ld <= 1'b1;
                end

                if (mult_ok == 1'b1)
                begin

                    state <= applyOut;
                    ld <= 1'b0;
                    b_temp <= mult_res;
                end
            end

            applyOut: begin

                whiteOut <= w_temp >> 8;
                redOut <= r_temp >> 8;
                greenOut <= g_temp >> 8;
                blueOut <= b_temp >> 8;

                state <= init;
            end

                // default: state <= init;
            endcase
        end
    end
endmodule