/*******************************************************************************

-- File Type:    Verilog HDL 
-- Tool Version: VHDL2verilog 20.51
-- Input file was: clockDividerPwm.vhd
-- Command line was: vhdl2verilog clockDividerPwm.vhd
-- Date Created: Fri Jun 28 11:43:13 2024

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

module clockDividerPwm (
   clk,
   clkPresc,
   reset);
 

input   clk; 
output   clkPresc; 
input   reset; 

reg     clkPresc; 
reg     [7:0] prescalerCnt = {8{1'b 0}}; 
reg     clkPrescSig = 1'b0;
reg     reset_sig; 

// initial 
//    begin : process_2
//    clkPrescSig = 1'b 0;   
//    end

// initial 
//    begin : process_1
//    prescalerCnt = {8{1'b 0}};   
//    end


always @(posedge clk)
   begin : mainprocess
   reset_sig <= reset;   
   if (reset_sig == 1'b 0)
      begin
      prescalerCnt <= {8{1'b 0}};   
      clkPrescSig <= 1'b 0;   

// clkPresc <= '0';
      end
   else
      begin
      if (prescalerCnt == 8'h 02)
         begin
         clkPrescSig <= ~clkPrescSig;   
         prescalerCnt <= {8{1'b 0}};   
         end
      else
         begin
         prescalerCnt <= prescalerCnt + 8'h 01;   
         end
      end
   clkPresc <= clkPrescSig;   
   end


// signal    prescaler    : std_logic_vector(7 downto 0) := "00000011";

endmodule // module clockDividerPwm

