/* ------------------------------------------------ *
 * Title       : Decimal Clockwork Simulation       *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testbench_decClkwork.v             *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 21/04/2021                         *
 * ------------------------------------------------ *
 * Description : Simulation decimal clockwork       *
 * ------------------------------------------------ */
`include "Source/clockwork.v"
`timescale 1ns / 1ps

module tb();
  reg clk_clock, time_ow;
  reg [19:0] time_in;
  wire [19:0] time_out;
  wire [6:0] sec, min;
  wire [5:0] hour;

  always #5  clk_clock = ~clk_clock; //In sim we assume 10ns = 1s
  
  assign {hour, min, sec} = time_out;

  clockWorkDec uut(clk_clock, time_in, time_out, time_ow);

  initial
        begin
            clk_clock = 0;
            time_ow = 0;
            time_in = {6'h23,7'h48,7'h0}; //23:48:00
            #12
            time_ow = 1;
            #10
            time_ow = 0;
            #1000000
            $finish;
        end
  initial //to get simulation outputs
      begin  
        $dumpfile("output_waveform.vcd"); 
        $dumpvars(0, clk_clock);
        $dumpvars(1, hour);
        $dumpvars(2, min);
        $dumpvars(3, sec);
      end
endmodule