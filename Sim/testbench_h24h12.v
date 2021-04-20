/* ------------------------------------------------ *
 * Title       : Simulation for 24h-12h converter   *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testbench_h24h12.v                 *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 24/02/2021                         *
 * ------------------------------------------------ *
 * Description : Simulation for Convert 24 hour     *
 *               format to 12 hour format           *
 * ------------------------------------------------ */
`timescale 1ns / 1ps
`include "Source/h24toh12.v"

module tb_h24h12();
  reg [4:0] hour24;
  wire nAM_PM;
  wire [3:0] hour12;

  h24Toh12Hex uut(hour24,nAM_PM,hour12);
  
  always #100 hour24 = (hour24 == 23) ? 0 : hour24+1;

  initial
    begin
      hour24 = 0;
    end
  initial
    begin
      $dumpfile("sim_h24h12.vcd");
      $dumpvars(0, hour24);
      $dumpvars(1, nAM_PM);
      $dumpvars(2, hour12);
      #2500
      $finish;
    end
endmodule