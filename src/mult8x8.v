// Copyright, 2024 - Alea Art Engineering, Enrico Sanino
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


module mult8x8_module (
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

always @(posedge clk)
   begin
   if (reset == 1'b0)
      begin
         result <= 16'h0000;
         mult_rdy <=  1'b 0; 
         ld_latch <= 1'b0;  
      end
   else 
   begin
         if (ld == 1'b1) // at the rising edge of load, store the operands
         begin
         result <= a_sig + b_sig;
         mult_rdy <= 1'b1;
         end
   end
end
endmodule 

