/*******************************************************************************

-- File Type:    Verilog HDL 
-- Tool Version: VHDL2verilog 20.51
-- Input file was: clockDividerPwm.vhd
-- Command line was: vhdl2verilog clockDividerPwm.vhd
-- Date Created: Fri Jun 28 11:43:13 2024

*******************************************************************************/




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
output wire  clkPresc; 
input   reset; 

reg     [7:0] prescalerCnt = 8'h00; 
reg     clkPrescSig = 1'b0;

// initial 
//    begin : process_2
//    clkPrescSig = 1'b 0;   
//    end

// initial 
//    begin : process_1
//    prescalerCnt = {8{1'b 0}};   
//    end
assign   clkPresc = clkPrescSig;   

always @(negedge clk)
   begin : mainprocess
   if (reset == 1'b 0)
      begin
      prescalerCnt <= 8'h00;  
      clkPrescSig <= 1'b 0;   
// clkPresc <= '0';
      end
   else
      begin
      if (prescalerCnt == 8'h 00)
         begin
         clkPrescSig <= ~clkPrescSig;   
         prescalerCnt <= {8{1'b 0}};   
         end
      else
         begin
         prescalerCnt <= prescalerCnt + 8'h 01;   
         end
      end
   end


// signal    prescaler    : std_logic_vector(7 downto 0) := "00000011";

endmodule // module clockDividerPwm

