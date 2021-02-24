/* ------------------------------------------------ *
 * Title       : Alarm Module Simulation            *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testbench_alarm.v                  *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 28/04/2020                         *
 * ------------------------------------------------ *
 * Description : Simulation for alarm module        *
 * ------------------------------------------------ */

`timescale 1ns / 1ps

module tb_alrm();

    reg clk, rst, en_in, end_ring, set_time;
    wire [10:0] time_in, time_set_in;
    reg [5:0] min_set, min;
    reg [4:0] hour_set, hour;

    wire ring;
    
    assign time_in = {hour, min};
    assign time_set_in = {hour_set, min_set};

    alarm uut(clk, rst, en_in, time_in, time_set_in, set_time, ring, end_ring);

    always #5  clk = ~clk; //10 cycle is 10ns

    always #100 //assume a minute is 10 cycle, 100ns
        begin
            if (min == 6'd59)
                begin
                    hour = (hour == 5'd23) ? 5'd0 : (hour + 5'd1);
                end
            min = (min == 6'd59) ? 6'd0 : (min + 6'd1);
        end

    initial
        begin
            clk = 0;
            rst = 0;
            hour = 0;
            min = 0;
            hour_set = 5'd8;
            min_set = 6'd30;
            end_ring = 0;
            set_time = 0;
            en_in = 0;
            #2
            rst = 1;
            #5
            rst = 0;
            #1000
            //set time for 10 min before alarm (23:50)
            hour = 5'd23;
            min = 6'd50;
            #2000 //wait 20 min to test unenabled alarm 
            //set alarm to 8:30
            set_time = 1;
            #10  
            set_time = 0;
            //set time for 10 min before alarm (8:20)
            en_in = 1;
            hour = 5'd8;
            min = 6'd20;
            #1200 //wait 12 min to test alarm
            end_ring <= 1;
            #10
            end_ring <= 0;
            hour_set = 5'd15;
            min_set = 6'd45;
            #10
            //set alarm to 15:45
            set_time = 1;
            #10  
            set_time = 0;
            //set time for 10 min before alarm (15:35)
            hour = 5'd15;
            min = 6'd35;
            #1010 //wait 10 min + 1 cycle to test alarm
            end_ring <= 1;
            #10
            end_ring <= 0;
            #6000
            $finish;
        end

    initial //to get simulation outputs
      begin  
        $dumpfile("output_waveform.vcd"); 
        $dumpvars(0, uut);
      end

endmodule // tb
