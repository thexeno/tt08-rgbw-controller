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
 reg [3:0] seq = 4'h0;
 reg ld_latch = 1'b0;
 reg ld_prev = 1'b0;
 

always @(posedge clk)
   begin
      mult_rdy <= 1'b0;
      result <= a + b;
   end
endmodule 

