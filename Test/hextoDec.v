/* ------------------------------------------ *
 * Title       : Hexadecimal to Decimal       *
 *               Digit converter              *         
 * Project     : Verilog Utility Modules      *
 * ------------------------------------------ *
 * File        : hextoDec.v                   *
 * Author      : Yigit Suoglu                 *
 * Last Edit   : 04/03/2021                   *
 * ------------------------------------------ *
 * Description : Convert Hexadecimal digits   *
 *               into decimal digits          *
 * ------------------------------------------ */

//Convert two hexadecimal digits to decimal
//This module needs optimization:
//fixN and adjustN wires are used to apply fixes/adjustments for digit values
module doublDigitHtoD(digit0_i,digit1_i,digit0_o,digit1_o,carry_o);
  input [3:0] digit0_i, digit1_i;
  output [3:0] digit0_o, digit1_o;
  output [1:0] carry_o;
  wire [3:0] offset, digit0_offset, multiFac; //Offset due to base
  wire [3:0] digit1_adjust;
  wire digit0_icarry;
  wire [7:0] digits_i;
  wire fix0, fix1, fix2, fix3, fix4, fix5, fix6, fix7, fix8; //Fix offset errors for digit0
  wire adjust0, adjust1, adjust2, adjust3, adjust4, adjust5, adjust6, adjust7, adjust8;

  assign digits_i = {digit1_i,digit0_i};
  
  //Fixes offset errors for digit 0
  assign fix0 = digits_i > 8'h23;
  assign fix1 = digits_i > 8'h41;
  assign fix2 = ((digits_i > 8'h55) & (digits_i < 8'h5A)) | (digits_i > 8'h5F);
  assign fix3 = ((digits_i > 8'h73) & (digits_i < 8'h7A)) | (digits_i > 8'h7D);
  assign fix4 = ((digits_i > 8'h87) & (digits_i < 8'h8A)) | ((digits_i > 8'h91) & (digits_i < 8'h9A)) | (digits_i > 8'h9B);
  assign fix5 = ((digits_i > 8'hA5) & (digits_i < 8'hAA)) | (digits_i > 8'hAF);
  assign fix6 = ((digits_i > 8'hC3) & (digits_i < 8'hCA)) | (digits_i > 8'hCD);
  assign fix7 = ((digits_i > 8'hD7) & (digits_i < 8'hDA)) | (digits_i > 8'hE1);
  assign fix8 = ((digits_i > 8'hF5) & (digits_i < 8'hFA)) | (digits_i[7:1] == 7'b0011100);

  //Adjustments for digit 1
  assign adjust0 = ((digits_i > 8'h13) & (digits_i < 8'h1A)) | (digits_i > 8'h1D);
  assign adjust1 = ((digits_i > 8'h31) & (digits_i < 8'h3A)) | (digits_i[7:1] == 7'b0010100) | (digits_i > 8'h3B);
  assign adjust2 = ((digits_i > 8'h45) & (digits_i < 8'h4A)) | (digits_i > 8'h4F);
  assign adjust3 = ((digits_i > 8'h63) & (digits_i < 8'h6A)) | (digits_i > 8'h6D);
  assign adjust4 = ((digits_i > 8'h81) & (digits_i < 8'h8A)) | (digits_i[7:1] == 7'b0111100) | (digits_i > 8'h8B);
  assign adjust5 = ((digits_i > 8'h95) & (digits_i < 8'h9A)) | (digits_i > 8'h9F);
  assign adjust6 = ((digits_i > 8'hB3) & (digits_i < 8'hBA)) | (digits_i > 8'hBD);
  assign adjust7 = ((digits_i > 8'hD1) & (digits_i < 8'hDA)) | (digits_i[7:1] == 7'b1100100) | (digits_i > 8'hDB);
  assign adjust8 = ((digits_i > 8'hE5) & (digits_i < 8'hEA)) | (digits_i > 8'hEF);

  assign digit0_icarry = digit0_i > 4'h9;
  assign digit0_offset = offset + digit0_i;
  assign multiFac = digit1_i + {3'd0, digit0_icarry} + {3'd0, fix0} + {3'd0, fix1} + {3'd0, fix2} + {3'd0, fix3} + {3'd0, fix4} + {3'd0, fix5} + {3'd0, fix6} + {3'd0, fix7} + {3'd0, fix8};

  assign digit1_adjust = digit1_i + {3'd0, digit0_icarry} + {3'd0, adjust0} + {3'd0, adjust1} + {3'd0, adjust2} + {3'd0, adjust3} + {3'd0, adjust4} + {1'd0, {3{adjust5}}} + {3'd0, adjust6} + {3'd0, adjust7} + {3'd0, adjust8};


  singDigitHtoD dig1Conv(digit1_adjust,digit1_o,);
  singDigitHtoD dig0Conv(digit0_offset,digit0_o,);
  multi6 offsetMulti(multiFac, offset);
  assign carry_o[1] = {digit1_i, digit0_i} > 8'hC7;
  assign carry_o[0] = ~carry_o[1] & ({digit1_i, digit0_i} > 8'h63);
endmodule

//Convert a hexadecimal digit to decimal
module singDigitHtoD(digit_i,digit_o,carry_o);
  input [3:0] digit_i;
  output [3:0] digit_o;
  output carry_o;
  
  assign carry_o = digit_i > 4'h9;
  assign digit_o = (carry_o) ? (digit_i - 4'hA) : digit_i;
endmodule

//Multiply input with 6
module multi6(mult_i, mult_o);
  input [3:0] mult_i;
  output [3:0] mult_o;

  assign mult_o = {mult_i[2:0], 1'b0} + {mult_i[1:0], 2'b0};
endmodule
