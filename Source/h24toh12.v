/* ------------------------------------------------ *
 * Title       : 24 hour to 12 hour converter       *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : h24toh12.v                         *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 24/02/2021                         *
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
