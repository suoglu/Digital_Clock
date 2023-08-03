/* ------------------------------------------------ *
 * Title       : 24 hour to 12 hour converter       *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : h24toh12.v                         *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 24/02/2021                         *
 * Licence     : CERN-OHL-W                         *
 * ------------------------------------------------ *
 * Description : Convert 24 hour format to 12 hour  *
 *               format                             *
 * ------------------------------------------------ */

module h24Toh12Hex(
  input [4:0] hour24,
  output nAM_PM,
  output [3:0] hour12);

  wire [4:0] hour24Sub;

  assign hour24Sub = hour24 - 5'd12;
  
  assign nAM_PM = (hour24 > 5'd11);
  assign hour12 = ((hour24 == 5'd0)|(hour24 == 5'd12)) ? 4'd12 : ((nAM_PM) ? hour24Sub[3:0] : hour24[3:0]);
endmodule

module h24Toh12Dec(
  input [5:0] hour24,
  output nAM_PM,
  output [4:0] hour12);

  wire [5:0] hour24Sub;

  assign hour24Sub = hour24 - ((hour24[5:1]==5'b10000) ? 6'h18 : 6'h12);
  
  assign nAM_PM = (hour24 > 6'h11);
  assign hour12 = ((hour24 == 6'h0)|(hour24 == 6'h12)) ? 5'h12 : ((nAM_PM) ? hour24Sub[4:0] : hour24[4:0]);
endmodule
