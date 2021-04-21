/* ------------------------------------------------ *
 * Title       : Decimal Calendar Simulation        *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testbench_decCal.v                 *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 22/04/2021                         *
 * ------------------------------------------------ *
 * Description : Simulation decimal calendar module *
 * ------------------------------------------------ */
`timescale 1ns / 1ps
`include "Source/clockcalendar.v"

module tb();
  reg clk, date_ow;
  reg [5:0] hour_in;
  reg [24:0] date_in;
  reg [18:0] date_in2;
  wire [24:0] date_out;
  wire [5:0] day, day2;
  wire [4:0] month, month2;
  wire [13:0] year;
  wire [18:0] date_out2;
  wire [7:0] year2;


  always #1  clk = ~clk;
  always #10  hour_in <= (hour_in == 6'h23) ? 6'd0 : ((hour_in[3:0] == 4'h9) ? ({(hour_in[5:4] + 2'd1),4'h0}) : (hour_in + 6'd1)); 

  assign {day, month, year} = date_out;
  assign {day2, month2, year2} = date_out2;

  clockCalendarDec4 uut(clk, hour_in, date_in, date_out, date_ow);
  clockCalendarDec2 uut2(clk, hour_in, date_in2, date_out2, date_ow);

  initial
        begin
            hour_in = 0;
            clk = 0;
            date_ow = 0;
            date_in = {6'h15,5'h01,14'h2020}; //15.01.2020
            date_in2 = {6'h15,5'h01,8'h20}; //15.01.2020
            #12
            date_ow = 1;
            #10
            date_ow = 0;
            #1000000
            $finish;
        end
  initial //to get simulation outputs
      begin  
        $dumpfile("output_waveform.vcd"); 
        $dumpvars(0, clk);
        $dumpvars(1, hour_in);
        $dumpvars(2, day);
        $dumpvars(3, month);
        $dumpvars(4, year);
        $dumpvars(5, year2);
      end
endmodule
