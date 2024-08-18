/*******************************************************************************

-- File Type:    Verilog HDL 
-- Tool Version: VHDL2verilog 20.51
-- Input file was: pwm_gen.vhd
-- Command line was: vhdl2verilog pwm_gen.vhd
-- Date Created: Fri Jun 28 15:50:25 2024

*******************************************************************************/




//  (C) Copyright 2017 Enrico Sanino
//  License:     This project is licensed with the CERN Open Hardware Licence
//               v1.2.  You may redistribute and modify this project under the
//               terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
//               This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
//               WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
//               AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
//               v.1.2 for applicable Conditions.

module mult8x8 (
   input wire clk,
   input wire reset,
   input wire ld,
   output reg mult_rdy,
   input wire[7:0] a,
   input wire[7:0] b,
   output reg[15:0] result
);

 reg[7:0] a_sig = 8'h00;
 reg[7:0] b_sig = 8'h00;
 reg [3:0] seq = 4'h0;
 reg ld_latch = 1'b0;
 reg ld_prev = 1'b0;


always @(posedge clk)
   begin
   if (reset == 1'b0)
      begin
         result <= 16'h0000;
         mult_rdy <=  1'b 0; 
         seq <= 4'b0000;
        // ld <= 1'b0;
         ld_latch <= 1'b0;  
         //ld_prev <= 1'b0;  
      end
   else 
   begin
      ld_latch <= ld;
      ld_prev <= ld_latch;
      if (seq == 4'h0) begin
         if (ld == 1'b0)
         begin
         mult_rdy <= 1'b0;
         end
            
         if (ld_prev == 1'b0 && ld_latch == 1'b1) begin
         a_sig <= a;
         b_sig <= b;
         mult_rdy <= 1'b0;
         seq <= 4'h1;
         end
      end
      else if (seq == 4'h1) begin
         result <= a_sig * b_sig;
         mult_rdy <= 1'b1;
         seq <= 4'h2;
      end
      else if (seq == 4'h2) begin
        // mult_rdy <= 1'b0;
         seq <= 4'h0;
         //ld_prev <= ld_latch;
      end
      else seq <= 4'h0;
      end
   end
endmodule // module pwmGen

