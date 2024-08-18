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
        input wire clk_half,
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
        output reg [7 : 0] whiteOut
    );

    localparam init = 5'd0;
    localparam pre_thr1 = 5'd1;
    localparam thr1 = 5'd2;
    localparam pre_thr2 = 5'd3;
    localparam thr2 = 5'd4;
    localparam pre_thr3 = 5'd5;
    localparam thr3 = 5'd6;
    localparam pre_thr4 = 5'd7;
    localparam thr4 = 5'd8;
    localparam pre_thr5 = 5'd9;
    localparam thr5 = 5'd10;
    localparam pre_thr6 = 5'd11;
    localparam thr6 = 5'd12;
    localparam whiteSat = 5'd13;
    localparam stateApply = 5'd14;
    localparam stateApply_R = 5'd15;
    localparam stateApply_G = 5'd16;
    localparam stateApply_B = 5'd17;
    localparam applyOut = 5'd18;


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
    reg [7 : 0] lint_sig = 8'b00000000;
    reg [7 : 0] thr = 8'b00000000;
    reg [7 : 0] counter = 8'b00000000;
    reg [7 : 0] mode_latch = 8'b00000000;
    // reg [2:0] lint_comp = 3'b000;

    reg [4 : 0] state = 5'd0;

    // assign b_plus = b + 8'b00000111;
    // assign b_minus = b - 8'b00000111;
    // assign r_plus = r + 8'b00000111;
    // assign r_minus = r - 8'b00000111;

    always @(posedge clk)
    begin
    if (clk_half == 1'b0)
    begin
        if (reset == 1'b0)
        begin
            state <= init;
            thr <= 8'b00000000;
            lint_sig <= 8'b00000000;
            counter <= 8'b00000000;
            r <= 8'b00000000;
            g <= 8'b00000000;
            b <= 8'b00000000;
            mode_latch <= 8'b00000000;
            whiteOut <= 8'h00;
            redOut <= 8'h00;
            greenOut <= 8'h00;
            blueOut <= 8'h00;
            ld <= 1'b0;
            mult1 <= 8'h00;
            mult2 <= 8'h00;
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
                    state <= pre_thr1;
                    temp_ovf_b <= b + 8'b00000111;
                end
                else
                begin
                    state <= init;
                end
            end

            pre_thr1: begin
            /* this pre_* state is purely to have the correct sync in a pure sequential logic. it increase the clock cycles to compute a color */
            if (temp_ovf_b[8] == 1'b1) begin // overflow
                    b <= 8'hff;
                end 
                else begin
                    b <= temp_ovf_b[7:0]; 
                end           
            r <= 8'b11111111;
            g <= 8'b00000000;
            state <= thr1;
            end


            thr1: begin
                
            
                if (counter < thr)
                begin
                    counter <= counter + 1;
                    if (counter < 8'h2A)
                    begin
                        state <= pre_thr1;
                        temp_ovf_b <= b + 8'b00000111;
                    end
                    else
                    begin
                        state <= pre_thr2;
                        temp_ovf_r <= r - 8'b00000111;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            pre_thr2: begin
            /* this pre_* state is purely to have the correct sync in a pure sequential logic. it increase the clock cycles to compute a color */
            if ((temp_ovf_r[8] == 1'b1)) begin // underflow
                    r <= 8'h00;
                end 
                else begin
                    r <= temp_ovf_r[7:0]; 
                end                   
                g <= 8'b00000000;
                b <= 8'b11111111;
                state <= thr2;
            end

            thr2: begin
                
                if (counter < thr)
                begin
                    counter <= counter + 1;
                    if (counter < 8'h54)
                    begin
                        state <= pre_thr2;
                        temp_ovf_r <= r - 8'b00000111;
                    end
                    else
                    begin
                        state <= pre_thr3;
                        temp_ovf_g <= g + 8'b00000111;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end


            pre_thr3: begin
            /* this pre_* state is purely to have the correct sync in a pure sequential logic. it increase the clock cycles to compute a color */
                if (temp_ovf_g[8] == 1'b1) begin // overflow
                    g <= 8'hff;
                end 
                else begin
                    g <= temp_ovf_g[7:0]; 
                end    
                r <= 8'b00000000;
                b <= 8'b11111111;
                state <= thr3;
            end


            thr3: begin

                if (counter < thr)
                begin
                    counter <= counter + 1;
                    if (counter < 8'h7e)
                    begin
                        state <= pre_thr3;
                        temp_ovf_g <= g + 8'b00000111;
                    end
                    else
                    begin
                        state <= pre_thr4;
                        temp_ovf_b <= b - 8'b00000111;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            pre_thr4: begin
            /* this pre_* state is purely to have the correct sync in a pure sequential logic. it increase the clock cycles to compute a color */
                if ((temp_ovf_b[8] == 1'b1)) begin // underflow
                    b <= 8'h00;
                end 
                else begin
                    b <= temp_ovf_b[7:0]; 
                end   
                r <= 8'b00000000;
                g <= 8'b11111111;
                state <= thr4;
                    counter <= counter + 1;

            end

            thr4: begin

                if (counter < thr)
                begin
                    if (counter < 8'hA8)
                    begin
                        state <= pre_thr4;
                        temp_ovf_b <= b - 8'b00000111;
                    end
                    else
                    begin
                        state <= pre_thr5;
                        temp_ovf_r <= r + 8'b00000111;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            pre_thr5: begin
            /* this pre_* state is purely to have the correct sync in a pure sequential logic. it increase the clock cycles to compute a color */
                if (temp_ovf_r[8] == 1'b1) begin // overflow
                    r <= 8'hff;
                end 
                else begin
                    r <= temp_ovf_r[7:0]; 
                end    
                g <= 8'b11111111;
                b <= 8'b00000000;
                state <= thr5;
            end

            thr5: begin

                if (counter < thr)
                begin
                    counter <= counter + 1;
                    if (counter < 8'hD2)
                    begin
                        state <= pre_thr5;
                        temp_ovf_r <= r + 8'b00000111;
                    end
                    else
                    begin
                        state <= pre_thr6;
                        temp_ovf_g <= g - 8'b00000111;
                    end
                end
                else
                begin
                    state <= whiteSat;
                end
            end

            pre_thr6: begin
            /* this pre_* state is purely to have the correct sync in a pure sequential logic. it increase the clock cycles to compute a color */
                if ((temp_ovf_g[8] == 1'b1)) begin // underflow
                    g <= 8'h00;  
                end 
                else begin
                 g <= temp_ovf_g[7:0]; 
                end    
                r <= 8'b11111111;
                b <= 8'b00000000;
                state <= thr6;
            end

            thr6: begin
                if (counter < thr)
                begin
                    counter <= counter + 1;
                    if (counter < 8'hFC)
                    begin
                        state <= pre_thr6;
                        temp_ovf_g <= g - 8'b00000111;
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
                    w_temp <= mult_res[15:8];
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
                    r_temp <= mult_res[15:8];
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
                    g_temp <= mult_res[15:8];
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
                    b_temp <= mult_res[15:8];
                end
            end

            applyOut: begin

                whiteOut <= w_temp;
                redOut <= r_temp;
                greenOut <= g_temp;
                blueOut <= b_temp;

                state <= init;
            end

            default:
            begin
                state <= init;
            end
                // default: state <= init;
            endcase
        end
    end
    end
endmodule