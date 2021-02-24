/* ------------------------------------------------ *
 * Title       : Basic Modules Simulation           *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testbench.v                        *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 08/04/2020                         *
 * ------------------------------------------------ *
 * Description : Simulation for basic modules       *
 * ------------------------------------------------ */
`timescale 1ns / 1ps

module tb();
    reg clk_clock, time_ow, clk_date, date_ow;
    reg [16:0] time_in;
    reg [4:0] hour_in;
    reg [20:0] date_in;
    wire [16:0] time_out;
    wire [5:0] sec, min;
    wire [4:0] hour;
    wire [20:0] date_out;
    wire [4:0] day;
    wire [3:0] month;
    wire [11:0] year;
    
    clockWork uut0(clk_clock, time_in, time_out, time_ow);
    date_module uut1(clk_date, hour_in, date_in, date_out, date_ow);

    assign {hour, min, sec} = time_out;
    assign {day, month, year} = date_out;

    always #5  clk_clock = ~clk_clock;
    always #1  clk_date = ~clk_date;
    always #5  hour_in <= (hour_in == 5'd23) ? 5'd0 : (hour_in + 5'd1); //simulate hour signal to be used in date module
    

    initial
        begin
            hour_in = 0;
            clk_date = 0;
            clk_clock = 0;
            time_ow = 0;
            date_ow = 0;
            time_in = 17'b10111_110000_000000; //23:48:00
            date_in = 21'b01111_0001_011111100100; //15.01.2020
            #12
            time_ow = 1;
            date_ow = 1;
            #10
            time_ow = 0;
            date_ow = 0;
            #1000000
            $finish;
        end

    initial //to get simulation outputs
      begin  
        $dumpfile("output_waveform.vcd"); 
        $dumpvars(0, uut0);
        $dumpvars(1, hour);
        $dumpvars(2, min);
        $dumpvars(3, sec); 
        $dumpvars(4, uut1);
        $dumpvars(5, day);
        $dumpvars(6, month);
        $dumpvars(7, year);
      end

endmodule // tb
