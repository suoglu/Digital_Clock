//Last sim 5.4.2020 with icarus verilog
`timescale 1ns / 1ps

module tb();
    reg clk_1hz, time_ow;
    reg [16:0] time_in;
    wire [16:0] time_out;
    wire [5:0] sec, min;
    wire [4:0] hour;
    
    clockWork uut(clk_1hz, time_in, time_out, time_ow);

    always #5  clk_1hz = ~clk_1hz;
    assign {hour, min, sec} = time_out;

    initial //test cases here
        begin
            clk_1hz = 0;
            time_ow = 0;
            time_in = 17'b10111_110000_000000;
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
        $dumpvars(0, uut);
        $dumpvars(1, hour);
        $dumpvars(2, min);
        $dumpvars(3, sec);
      end

endmodule // tb
