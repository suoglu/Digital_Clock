/* ------------------------------------------------ *
 * Title       : Test board for digital clock (dec) *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testmodule_dec.v                   *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 22/04/2021                         *
 * ------------------------------------------------ */
//  `include "Source/clockwork.v"
//  `include "Source/alarm.v"
//  `include "Source/clockcalendar.v"
//  `include "Source/h24toh12.v"
//  `include "Test/ssd_util.v"
//  `include "Test/btn_debouncer.v"
//  `include "Test/hextoDec.v"

module boardDec(
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
  output [12:0] alarm_time_in,
  output [12:0] alarm_time_set_in,
  output alarm_set_time,
  input alarm_ring,
  output alarm_end_ring,
  //Clockwork
  output [19:0] clock_time_in,
  input [19:0] clock_time_out,
  output clock_time_ow,
  //Calender
  output [5:0] calender_hour_in,
  output [24:0] calender4_date_in,
  input [24:0] calender4_date_out,
  output [18:0] calender2_date_in,
  input [18:0] calender2_date_out,
  output calender_date_ow,
  //AM-PM convert
  output [5:0] h24Toh12_hour24,
  input h24Toh12_nAM_PM,
  input [4:0] h24Toh12_hour12); 
  wire clk_1hz, time_ow, date_ow, en_in, set_time, ring, end_ring;
  wire [19:0] time_in, time_out;
  wire [24:0] date_in, date_out;
  wire [6:0] sec_out, min_out;
  wire [5:0] hour_out, day_out;
  wire [4:0] hour12_out;
  wire [4:0] month_out;
  wire [13:0] year_out;
  wire [7:0] year2_out, month2_out, day2_out;
  wire btnAny;
  wire btnSetTime, btnSetDate, btnSetAlarm, btnOther;
  wire h12Mode;
  wire yearComp, monthComp, dayComp;
  reg date_ow_debug,date_ow_debug2;

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
  reg [19:0] time_buff;
  reg [12:0] alarm_buff;
  reg [24:0] date_buff;

  //some i/o routing
  assign h12Mode = sw[15];
  assign ssdMode = (inIDLE) ? sw[14:12] : INSW;
  assign en_in = sw[11];
  assign led[15:14] = stepCounter;
  assign led[13:12] = state;
  assign led[11] = 0;
  assign led[10:5] = 0;
  assign led[4] = 0;
  assign led[3:1] = {dayComp,monthComp,yearComp};
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
          time_buff <= {6'h11, 7'h58, 7'h22};
        end
      else
        begin
          if(ingetTIME)
            begin
              case(stepCounter)
                2'd0: //Hour
                  begin
                    time_buff[19:14] <= sw[5:0];
                  end
                2'd1: //Min
                  begin
                    time_buff[13:7] <= sw[6:0];
                  end
              endcase
              time_buff[6:0] <= 7'h30;
            end
        end
    end
  //alarm_buff
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          alarm_buff <= 13'd0;
        end
      else
        begin
          if(insetALRM)
            begin
              case(stepCounter)
                2'd0: //Hour
                  begin
                    alarm_buff[12:7] <= sw[5:0];
                  end
                2'd1: //Min
                  begin
                    alarm_buff[6:0] <= sw[6:0];
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
          date_buff <= {6'h22, 5'h1, 14'h21};
        end
      else
        begin
          if(ingetDATE)
            begin
              case(stepCounter)
                2'd0: //Year
                  begin
                    date_buff[13:0] <= {6'd0,sw[7:0]};
                  end
                2'd1: //Month
                  begin
                    date_buff[18:14] <= sw[4:0];
                  end
                2'd2: //Day
                  begin
                    date_buff[24:19] <= sw[5:0];
                  end
              endcase
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
            ssdDis = {8'h0, sec_out};
            ssdDigitEn = 4'b0011;
          end
        HHMM:
          begin
            ssdDis = (h12Mode) ? {3'd0, hour12_out, 1'd0, min_out} : {2'd0, hour_out, 1'd0, min_out};
            ssdDigitEn = 4'b1111;
          end
        DDMM:
          begin
            ssdDis = (sw[10]) ? {day2_out,month2_out} : {2'd0, day_out, 3'd0, month_out};
            ssdDigitEn = 4'b1111;
          end
        YEAR:
          begin
            ssdDis = (sw[10]) ? {8'h0,year2_out} : {2'd0, year_out};
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
  ssdController4 ssdCntr(clk, rst, ssdDigitEn, ssdDis[15:12], ssdDis[11:8], ssdDis[7:4], ssdDis[3:0], seg, an);

  //Clock generator
  clkGen1Hz secondGen(clk, rst, clk_1hz);

  //Compare date modules
  assign yearComp = (calender2_date_out[7:0] == year_out);
  assign monthComp = (calender2_date_out[12:8] == month_out);
  assign dayComp = (calender2_date_out[18:13] == day_out);
  assign day2_out = {2'd0,calender2_date_out[18:13]};
  assign month2_out = {3'd0,calender2_date_out[12:8]};
  assign year2_out = calender2_date_out[7:0];

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
  assign calender2_date_in = {date_buff[24:14], date_buff[7:0]};
  assign date_out = calender4_date_out;
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
