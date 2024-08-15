/*******************************************************************************

-- File Type:    Verilog HDL 
-- Tool Version: VHDL2verilog 20.51
-- Input file was: spi_slave.vhd
-- Command line was: vhdl2verilog spi_slave.vhd
-- Date Created: Fri Jun 28 15:56:30 2024

*******************************************************************************/



//  (C) Copyright 2017 Enrico Sanino
//  License:     This project is licensed with the CERN Open Hardware Licence
//               v1.2.  You may redistribute and modify this project under the
//               terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
//               This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
//               WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
//               AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
//               v.1.2 for applicable Conditions.

module spiSlave (
  input wire sck,
  input wire cs,
  input wire clk,
  input wire mosi,
  input wire reset,
  output reg rdy_sig,
  output wire [7:0] data);
 

//input   sck; 
//input   cs; 
//input   clk; 
//input   mosi; 
//input   reset; 
//output   rdy; 
//output   [7:0] data; 

//reg     rdy; 
//reg     [7:0] data; 
reg     [7:0] bit_counter = 8'h00; 
//reg     [7:0] data_reg = {8{1'b 0}}; 
reg     [7:0] data_byte  = 8'h00;  
//reg     rdy_sig = 1'b 0;
reg     sck_latch = 1'b0; 
reg     sck_prev = 1'b0; 
reg     mosi_latch = 1'b0;
reg clkPrescSig = 1'b0;
// initial 
//    begin : process_7
//    mosi_latch = 1'b 0;   
//    end

// initial 
//    begin : process_6
//    sck_prev = 1'b 0;   
//    end

// initial 
//    begin : process_5
//    sck_latch = 1'b 0;   
//    end

// initial 
//    begin : process_4
//    rdy_sig = 1'b 0;   
//    end

// initial 
//    begin : process_3
//    data_byte = {8{1'b 0}};   
//    end

// initial 
//    begin : process_2
//    data_reg = {8{1'b 0}};   
//    end

// initial 
//    begin : process_1
//    bit_counter = {8{1'b 0}};   
//    end
always @(posedge clk)
   begin : spi_sys_clock
            clkPrescSig <= ~clkPrescSig;   
   end

always @(posedge clkPrescSig)
   begin : mainprocess
   if (reset == 1'b 0 || cs == 1'b 1)
      begin
      bit_counter <= 8'h00;   
      //data_reg <= {8{1'b 0}};   
      data_byte <= 8'h00;   
      rdy_sig <= 1'b 0;   
      sck_prev <= 1'b 0;   
      sck_latch <= 1'b 0;   
      mosi_latch <= 1'b 0;   
      end
   else
      begin
      sck_prev <= sck_latch;   
      sck_latch <= sck;   
      mosi_latch <= mosi;   
      if (sck_prev == 1'b 0 & sck_latch == 1'b1)
         begin
         data_byte <= {data_byte[6:0], mosi_latch};   
         bit_counter <= bit_counter + 8'h01;   
         end
      if (sck_latch == 1'b 0 && bit_counter == 8'h08)
         begin
         rdy_sig <= 1'b1;   
         bit_counter <= 8'h00;   
         end
      else
         begin
         rdy_sig <= 1'b0;   
         end
      data <= data_byte;   
     // rdy <= rdy_sig;   
      end
   end


// rdy <= '0';
// data <= (others => '0');

endmodule // module spiSlave

