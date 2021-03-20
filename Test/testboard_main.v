/* ------------------------------------------------ *
 * Title       : Test board for digital clock       *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : testboard_main.v                   *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : /03/2021                         *
 * ------------------------------------------------ */
 `include "Source/clockwork.v"
 `include "Source/alarm.v"
 `include "Source/date_module.v"
 `include "Source/h24toh12.v"
 `include "Test/ssd_util.v"
 `include "Test/btn_debouncer.v"
 `include "Test/hextoDec.v"

module board(
  input clk,
  input rst,
  input btnU, //Set Time
  input btnL, //Set Date
  input btnR, //Set Alarm
  input btnD, //Empty
  input [15:0] sw,
  output [15:0] led,
  output [6:0] seg,
  output [3:0] an,
  output dp); //AM/PM
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
  assign led[15:14] = stepCounter;
  assign led[13:12] = state;
  assign led[11:0] = 0;

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
          alarm_buff <= 17'd0;
        end
      else
        begin
          if(ingetDATE)
            begin
              case(stepCounter)
                2'd0: //Year
                  begin
                    date_buff[16:10] <= sw[6:0];
                  end
                2'd1: //Month
                  begin
                    date_buff[9:6] <= sw[3:0];
                  end
                2'd2: //Day
                  begin
                    date_buff[5:0] <= sw[5:0];
                  end
              endcase
              date_buff[20:17] <= 4'd0;
            end
        end
    end

  //stepCounter to get data
  always@(posedge clk)
    begin
      if(inIDLE)
        begin
          stepCounter <= 2'd0;
        end
      else
        begin
          stepCounter <= stepCounter + {1'b0, btnAny};
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
            ssdDigitEn = 4'b1111;
          end
        INSW:
          begin
            ssdDis = sw;
            ssdDigitEn = 4'b1111;
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

  //UUTs
  alarm clockAlarm(clk, rst, en_in, {hour_out,min_out}, alarm_buff, set_time, ring, end_ring);
  clockWork clockW(clk_1hz, time_buff, time_out, time_ow);
  date_module dateC(clk, hour_out, date_buff, date_out, date_ow);
  h24Toh12 hourConv(hour_out, dp, hour12_out);
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
