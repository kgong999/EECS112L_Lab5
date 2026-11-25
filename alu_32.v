`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define AluBitWidth 3

module alu_32
#(parameter bitWidth = `AluBitWidth)
(
   input  [bitWidth -1:0] A_in,B_in,        // ALU 32 bit inputs
   input  [3:0]  ALU_Sel,          // ALU 4 bits selection
   output [bitWidth -1:0] ALU_Out,          // ALU 32 bits output
   output [bitWidth -1:0] A,B,
   output [3:0]  ALU_Sel_out,
   output reg    Carry_Out,
   output        Zero,             // 1 bit Zero Flag
   output reg    Overflow = 1'b0   // 1 bit Overflow flag has value zero as a 
   //default value and we will set it to 1 for Add and Sub if Overflow occurs!
    );
  assign A =A_in;
  assign B =B_in;
  assign ALU_Sel_out =ALU_Sel;
  reg  [bitWidth -1:0] ALU_Result;
  reg [bitWidth :0] temp;
  reg [bitWidth :0] twos_com; // to hold 2'sc of second source of ALU
  
  assign ALU_Out   = ALU_Result;              // ALU Out
  assign Zero      = (ALU_Result == 0);      // Zero Flag
        
  always @(*)
    begin
     Overflow = 1'b0;
     Carry_Out = 1'b0;
     case(ALU_Sel)
        4'b0000: //  Bitwise and 
          ALU_Result = A_in & B_in;
          
        4'b0001: //  Bitwise or
          ALU_Result = A_in | B_in;
           
        4'b0010: // Signed Addition with Overflow and Carry_out checking
           begin
             ALU_Result = $signed(A_in) + $signed(B_in); 
             temp = {1'b0, A_in} + {1'b0, B_in};
             Carry_Out = temp[bitWidth];
             if ((A_in[bitWidth -1] & B_in[bitWidth -1] & ~ALU_Out[bitWidth -1]) 
             | (~A_in[bitWidth -1] & ~B_in[bitWidth -1] & ALU_Out[bitWidth -1]))
                 Overflow = 1'b1;
             else 
                 Overflow = 1'b0;
           end 
           
        4'b0110: // Signed Subtraction with Overflow checking
           begin
             ALU_Result = $signed(A_in) - $signed(B_in) ;
             twos_com = ~(B_in) + 1'b1; 
             if ((A_in[bitWidth -1] & twos_com[bitWidth -1] &
             ~ALU_Out[bitWidth-1]) | (~A_in[bitWidth -1] &
             ~twos_com[bitWidth -1] & ALU_Out[bitWidth -1]))
                 Overflow = 1'b1;
             else 
                 Overflow = 1'b0;
           end 
           
         4'b0111: // Signed less than comparison
           ALU_Result = ($signed(A_in) < $signed(B_in))?
           `AluBitWidth'd1:`AluBitWidth'd0;
           
         4'b1100: //  Bitwise nor
           ALU_Result = ~(A_in | B_in);
           
         4'b1111: // Equal comparison   
           ALU_Result = (A_in==B_in)?`AluBitWidth'd1:`AluBitWidth'd0 ; 
                 
         default: ALU_Result = A_in + B_in ; 
       endcase
     end
endmodule
