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


module clock_prescaler_module (
   clk,
   clk_presc,
   reset);
 

input   clk; 
output wire  clk_presc; 
input   reset; 

reg     [7:0] prescaler_cnt;
reg     clk_presc_sig;

assign   clk_presc = clk_presc_sig;   

always @(posedge clk)
   begin : mainprocess
   if (reset == 1'b 0)
      begin
      prescaler_cnt <= 8'h00;  
      clk_presc_sig <= 1'b 0;   
      end
   else
      begin
      if (prescaler_cnt == 8'h 00) // simply divide by 2 in this implementation
         begin
         clk_presc_sig <= ~clk_presc_sig;   
         prescaler_cnt <= {8{1'b 0}};   
         end
      else
         begin
         prescaler_cnt <= prescaler_cnt + 8'h 01;   
         end
      end
   end

endmodule 

