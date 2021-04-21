/* ------------------------------------------------ *
 * Title       : Test board for digital clock       *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testboard_main.v                   *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 20/03/2021                         *
 * ------------------------------------------------ */
//  `include "Source/clockwork.v"
//  `include "Source/alarm.v"
//  `include "Source/clockcalendar.v"
//  `include "Source/h24toh12.v"
//  `include "Test/ssd_util.v"
//  `include "Test/btn_debouncer.v"
//  `include "Test/hextoDec.v"

module board(
  input clk,
  input rst,
  output clk_1hz,
  input btnU, //Set Time
  input btnL, //Set Date
  input btnR, //Set Alarm
  input btnD, //end_ring
  input [15:0] sw,
  output [15:0] led,
  output [6:0] seg,
  output [3:0] an,
  output dp,//AM/PM
  //Following ports to uuts
  //Alarm
  output alarm_en_in,
  output [10:0] alarm_time_in,
  output [10:0] alarm_time_set_in,
  output alarm_set_time,
  input alarm_ring,
  output alarm_end_ring,
  //Clockwork
  output [16:0] clock_time_in,
  input [16:0] clock_time_out,
  output clock_time_ow,
  //Calender
  output [4:0] calender_hour_in,
  output [20:0] calender_date_in,
  input [20:0] calender_date_out,
  output calender_date_ow,
  //AM-PM convert
  output [4:0] h24Toh12_hour24,
  input h24Toh12_nAM_PM,
  input [3:0] h24Toh12_hour12); 
  wire clk_1hz, time_ow, date_ow, en_in, set_time, ring, end_ring;
  wire [16:0] time_in, time_out;
  wire [20:0] date_in, date_out;
  wire [5:0] sec_out, min_out;
  wire [4:0] hour_out, day_out;
  wire [3:0] hour12_out;
  wire [3:0] month_out;
  wire [11:0] year_out;
  wire [10:0] time_set_in;
  wire btnAny;
  wire btnSetTime, btnSetDate, btnSetAlarm, btnOther;
  wire h12Mode;

  localparam SEC = 3'd0,
            HHMM = 3'd1,
            DDMM = 3'd2,
            YEAR = 3'd3,
            INSW = 3'd4;
  wire [2:0] ssdMode;
  reg [15:0] ssdDis;
  wire [3:0] dig0, dig1, dig2, dig3;
  reg [3:0] ssdDigitEn;

  localparam IDLE = 2'd0,
          getTIME = 2'd1,
          getDATE = 2'd2,
          setALRM = 2'd3;
  reg [1:0] state;
  wire inIDLE, ingetTIME, ingetDATE, insetALRM;
  reg ingetTIME_d, ingetDATE_d, insetALRM_d;
  reg [1:0] stepCounter;
  wire gotAllData, stepDone;
  reg [1:0] totSteps;
  reg [16:0] time_buff;
  reg [10:0] alarm_buff;
  reg [20:0] date_buff;

  //some i/o routing
  assign h12Mode = sw[15];
  assign ssdMode = (inIDLE) ? sw[14:12] : INSW;
  assign en_in = sw[11];
  assign led[15:14] = stepCounter;
  assign led[13:12] = state;
  assign led[11:1] = 0;
  assign led[0] = ring;

  //State transactions & decode states
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          state <= IDLE;
        end
      else
        begin
          if(btnAny)
            case(state)
              IDLE:
                begin
                  if(btnSetTime)
                    state <= getTIME;
                  else if(btnSetDate)
                    state <= getDATE;
                  else if(btnSetAlarm)
                    state <= setALRM;
                end
              default:
                begin
                  state <= (gotAllData) ? IDLE : state;
                end
            endcase
        end
    end
  assign inIDLE = (state == IDLE);
  assign ingetTIME = (state == getTIME);
  assign ingetDATE = (state == getDATE);
  assign insetALRM = (state == setALRM);
  //Delay state flags to detect edges
  always@(posedge clk)
    begin
      ingetTIME_d <= ingetTIME;
      ingetDATE_d <= ingetDATE;
      insetALRM_d <= insetALRM;
    end
  //generate ow signals from states
  assign time_ow = inIDLE & ingetTIME_d;
  assign date_ow = inIDLE & ingetDATE_d;
  assign set_time = inIDLE & insetALRM_d;

  //Buffers
  //time_buff
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          time_buff <= 17'd0;
        end
      else
        begin
          if(ingetTIME)
            begin
              case(stepCounter)
                2'd0: //Hour
                  begin
                    time_buff[16:12] <= sw[4:0];
                  end
                2'd1: //Min
                  begin
                    time_buff[11:6] <= sw[5:0];
                  end
              endcase
              time_buff[5:0] <= 6'd0;
            end
        end
    end
  //alarm_buff
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          alarm_buff <= 17'd0;
        end
      else
        begin
          if(insetALRM)
            begin
              case(stepCounter)
                2'd0: //Hour
                  begin
                    alarm_buff[10:6] <= sw[4:0];
                  end
                2'd1: //Min
                  begin
                    alarm_buff[5:0] <= sw[5:0];
                  end
              endcase
            end
        end
    end
  //date_buff
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          date_buff <= {6'd22, 4'd1, 12'd21};
        end
      else
        begin
          if(ingetDATE)
            begin
              case(stepCounter)
                2'd0: //Year
                  begin
                    date_buff[6:0] <= sw[6:0];
                  end
                2'd1: //Month
                  begin
                    date_buff[15:12] <= sw[3:0];
                  end
                2'd2: //Day
                  begin
                    date_buff[20:16] <= sw[5:0];
                  end
              endcase
              date_buff[11:7] <= 4'd0;
            end
        end
    end

  //Decode output signals
  assign {hour_out,min_out,sec_out} = time_out;
  assign {day_out,month_out,year_out} = date_out;

  //Button debouncers & control
  debouncer debounce0(clk, rst, btnU, btnSetTime);
  debouncer debounce1(clk, rst, btnL, btnSetDate);
  debouncer debounce2(clk, rst, btnR, btnSetAlarm);
  debouncer debounce3(clk, rst, btnD, btnOther);
  assign btnAny = btnSetTime | btnSetDate | btnSetAlarm | btnOther;
  assign end_ring = btnOther;
  //Display data control
  always@*
    begin
      case(ssdMode)
        SEC:
          begin
            ssdDis = {10'd0, sec_out};
            ssdDigitEn = 4'b0011;
          end
        HHMM:
          begin
            ssdDis = (h12Mode) ? {4'd0, hour12_out, 2'd0, min_out} : {3'd0, hour_out, 2'd0, min_out};
            ssdDigitEn = 4'b1111;
          end
        DDMM:
          begin
            ssdDis = {3'd0, day_out, 4'd0, month_out};
            ssdDigitEn = 4'b1111;
          end
        YEAR:
          begin
            ssdDis = {4'd0, year_out};
            ssdDigitEn = 4'b0011;
          end
        INSW:
          begin
            ssdDis = sw;
            ssdDigitEn = 4'b0011;
          end
        default:
          begin
            ssdDis = 16'd0;
            ssdDigitEn = 4'b0000;
          end
      endcase
    end

  //Handle steps counters
  assign gotAllData = btnAny & stepDone;
  assign stepDone = (stepCounter == totSteps);
  //totSteps
  always@*
    begin
      case(state)
        getTIME:
          begin
            totSteps = 2'd1;
          end
        getDATE:
          begin
            totSteps = 2'd2;
          end
        setALRM:
          begin
            totSteps = 2'd1;
          end
        default:
          begin
            totSteps = 2'd3;
          end
      endcase
    end
  //stepCounter
  always@(posedge clk)
    begin
      if(inIDLE)
        begin
          stepCounter <= 2'd0;
        end
      else
        begin
          stepCounter <= stepCounter + {1'b0, (btnAny & ~stepDone)};
        end
    end

  //Display control
  doublDigitHtoD convLS(ssdDis[3:0],ssdDis[7:4],dig0,dig1,);
  doublDigitHtoD convMS(ssdDis[11:8],ssdDis[15:12],dig2,dig3,);
  ssdController4 ssdCntr(clk, rst, ssdDigitEn, dig3, dig2, dig1, dig0, seg, an);

  //Clock generator
  clkGen1Hz secondGen(clk, rst, clk_1hz);

  //UUT signals
  //Alarm
  assign alarm_en_in = en_in;
  assign alarm_time_in = {hour_out,min_out};
  assign alarm_time_set_in = alarm_buff;
  assign alarm_set_time = set_time;
  assign ring = alarm_ring;
  assign alarm_end_ring = end_ring;
  //Clockwork
  assign clock_time_in = time_buff;
  assign time_out = clock_time_out;
  assign clock_time_ow = time_ow;
  //Calender
  assign calender_hour_in = hour_out;
  assign calender_date_in = date_buff;
  assign date_out = calender_date_out;
  assign calender_date_ow = date_ow;
  //AM-PM convert
  assign h24Toh12_hour24 = hour_out;
  assign dp = h24Toh12_nAM_PM;
  assign hour12_out = h24Toh12_hour12;
endmodule

module clkGen1Hz(clk, rst, clk1hz);
  input clk, rst;
  output reg clk1hz;
  reg [25:0] counter;

  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          clk1hz <= 1'd1;
        end
      else
        begin
          clk1hz <= (counter == 26'd49_999_999) ? ~clk1hz : clk1hz;
        end
    end

  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          counter <= 26'd0;
        end
      else
        begin
          counter <= (counter == 26'd49_999_999) ? 26'd0 : (counter+26'd1);
        end
    end
endmodule
