/* ------------------------------------------------ *
 * Title       : Alarm Module                       *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : alarm.v                            *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 28/04/2020                         *
 * ------------------------------------------------ *
 * Description : A clock alarm module               *
 * ------------------------------------------------ */

module alarmHex(clk, rst, en_in, time_in, time_set_in, set_time, ring, end_ring);
  input clk, rst, set_time, end_ring, en_in;
  output reg ring;

  //Alarm is not sensitive to seconds
  input [10:0] time_set_in, time_in;
  reg [10:0] time_alarm;
    
  reg en;

  //set alarm time
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          time_alarm <= 11'd0;
        end
      else
        begin
          time_alarm <= (set_time) ? time_set_in : time_alarm;
        end
    end
    
  //handle to ringing of the alarm
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          ring <= 1'b0;
        end
      else
        begin
          if(en)
            begin
              //while ringing: stop if  end ring pressed
              //otherwise start ringing when time is equal to snooze
              ring <= (ring) ? (~end_ring) : (time_alarm == time_in);
            end
        end
    end

  //keep ringing shut after end_ring if high, but not disable for next day
  always@(posedge clk)
    begin
      if(time_alarm == time_in)
        begin
          en <= (end_ring) ? 1'b0 : en;
        end
      else
        begin
          en <= en_in;
        end
    end
endmodule//alarm

module alarmDec(clk, rst, en_in, time_in, time_set_in, set_time, ring, end_ring);
  input clk, rst, set_time, end_ring, en_in;
  output reg ring;

  //Alarm is not sensitive to seconds
  input [12:0] time_set_in, time_in;
  reg [12:0] time_alarm;
    
  reg en;

  //set alarm time
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          time_alarm <= 13'd0;
        end
      else
        begin
          time_alarm <= (set_time) ? time_set_in : time_alarm;
        end
    end
    
  //handle to ringing of the alarm
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          ring <= 1'b0;
        end
      else
        begin
          if(en)
            begin
              //while ringing: stop if  end ring pressed
              //otherwise start ringing when time is equal to snooze
              ring <= (ring) ? (~end_ring) : (time_alarm == time_in);
            end
        end
    end

  //keep ringing shut after end_ring if high, but not disable for next day
  always@(posedge clk)
    begin
      if(time_alarm == time_in)
        begin
          en <= (end_ring) ? 1'b0 : en;
        end
      else
        begin
          en <= en_in;
        end
    end
endmodule//alarm
