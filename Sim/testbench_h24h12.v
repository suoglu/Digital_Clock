/* ------------------------------------------------ *
 * Title       : Simulation for 24h-12h converter   *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testbench_h24h12.v                 *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 21/04/2021                         *
 * ------------------------------------------------ *
 * Description : Simulation for Convert 24 hour     *
 *               format to 12 hour format           *
 * ------------------------------------------------ */
`timescale 1ns / 1ps
`include "Source/h24toh12.v"

module tb_h24h12();
  reg [4:0] hour24hex;
  reg [5:0] hour24dec;
  wire nAM_PMhex, nAM_PMdec;
  wire [3:0] hour12hex;
  wire [4:0] hour12dec;

  h24Toh12Hex uuthex(hour24hex,nAM_PMhex,hour12hex);
  h24Toh12Dec uutdec(hour24dec,nAM_PMdec,hour12dec);

  always #100 hour24hex = (hour24hex == 5'd23) ? 0 : hour24hex+1;
  always #100 hour24dec = (hour24dec == 6'h23) ? 0 : (((hour24dec == 6'h9)|(hour24dec == 6'h19)) ? (hour24dec+7) : (hour24dec+1));

  initial
    begin
      hour24hex = 0;
      hour24dec = 0;
    end
  initial
    begin
      $dumpfile("sim_h24h12.vcd");
      $dumpvars(0, hour24hex);
      $dumpvars(1, nAM_PMhex);
      $dumpvars(2, hour12hex);
      $dumpvars(3, hour24dec);
      $dumpvars(4, nAM_PMdec);
      $dumpvars(5, hour12dec);
      #2500
      $finish;
    end
endmodule