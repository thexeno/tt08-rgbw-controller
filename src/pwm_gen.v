/*******************************************************************************

-- File Type:    Verilog HDL 
-- Tool Version: VHDL2verilog 20.51
-- Input file was: pwm_gen.vhd
-- Command line was: vhdl2verilog pwm_gen.vhd
-- Date Created: Fri Jun 28 15:50:25 2024

*******************************************************************************/

`define false 1'b 0
`define FALSE 1'b 0
`define true 1'b 1
`define TRUE 1'b 1

`timescale 1 ns / 1 ns // timescale for following modules


//  (C) Copyright 2017 Enrico Sanino
//  License:     This project is licensed with the CERN Open Hardware Licence
//               v1.2.  You may redistribute and modify this project under the
//               terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
//               This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
//               WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
//               AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
//               v.1.2 for applicable Conditions.

module pwmGen (
input   clk,
input   reset,
input [7:0]  duty0,
input [7:0]  duty1,
input [7:0]  duty2,
input [7:0]  duty3,
output reg    d0,
output reg    d1,
output reg    d2,
output reg    d3);
 

 
reg     [7:0] counter = 8'h00;
reg     [7:0] duty0_buff = 8'h00;
reg     [7:0] duty1_buff = 8'h00;
reg     [7:0] duty2_buff = 8'h00;
reg     [7:0] duty3_buff = 8'h00;
reg     d0_sig = 1'b0;
reg     d1_sig = 1'b0;
reg     d2_sig = 1'b0;
reg     d3_sig = 1'b0;


always @(posedge clk)
   begin : maincounter
   if (reset == 1'b0)
      begin
      counter <= {8{1'b 0}};   
      d0_sig <= 1'b 0;   
      d1_sig <= 1'b 0;   
      d2_sig <= 1'b 0;   
      d3_sig <= 1'b 0;
      d0 <= 1'b 0;   
      d1 <= 1'b 0;   
      d2 <= 1'b 0;   
      d3 <= 1'b 0;         
      // duty0_buff <= {8{1'b 0}};   
      // duty1_buff <= {8{1'b 0}};   
      // duty2_buff <= {8{1'b 0}};   
      // duty3_buff <= {8{1'b 0}};   
      end
   else
      begin

      if (counter == 8'h ff)
         begin
         counter <= {8{1'b 0}};  
         // here are sync updates with pwm period 
         duty0_buff <= duty0;   
         duty1_buff <= duty1;   
         duty2_buff <= duty2;   
         duty3_buff <= duty3;   
         end
      else
         begin
         counter <= counter + 1;   
         end

      if (counter < duty0_buff)
         begin
         d0_sig <= 1'b 1;   
         end
      else
         begin
         d0_sig <= 1'b 0;   
         end
      if (counter < duty1_buff)
         begin
         d1_sig <= 1'b 1;   
         end
      else
         begin
         d1_sig <= 1'b 0;   
         end
      if (counter < duty2_buff)
         begin
         d2_sig <= 1'b 1;   
         end
      else
         begin
         d2_sig <= 1'b 0;   
         end
      if (counter < duty3_buff)
         begin
         d3_sig <= 1'b 1;   
         end
      else
         begin
         d3_sig <= 1'b 0;   
         end
         d0 <= d0_sig;   
         d1 <= d1_sig;   
         d2 <= d2_sig;   
         d3 <= d3_sig;   
      end
   end


endmodule // module pwmGen

