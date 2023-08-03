/* ------------------------------------------------ *
 * Title       : Date Module                        *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : clockcalendar.v                    *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 22/04/2021                         *
 * Licence     : CERN-OHL-W                         *
 * ------------------------------------------------ *
 * Description : Keep date with respect to hour     *
 * ------------------------------------------------ */

module clockCalendarHex#(parameter YEARRES = 12)(clk, hour_in, date_in, date_out, date_ow);
  input clk, date_ow; //System clock, Date overwrite (asynchronous reset)
  //Time signal format: hhhhh_mmmmmm_ssssss
  input [4:0] hour_in; //hour data

  //Date signal format: ddddd_mmmm_yyyyyyyyyyyy
  //Year signal can be adjusted to count from another refence than 0, e.g. 1900, to reduce bit size
  input [(YEARRES+8):0] date_in; //date input
  output [(YEARRES+8):0] date_out; //main output

  //separated date signals to respective meaning
  wire [4:0] day_in;
  wire [3:0] month_in;
  wire [(YEARRES-1):0] year_in;
  reg [4:0] day_reg, day_reg_del; //day_reg_del: delayed signal
  reg [3:0] month_reg, month_reg_del; //month_reg_del: delayed signal
  reg [(YEARRES-1):0] year_reg;

  reg [4:0] hour_reg; //Store previous hour data
  reg new_day; //Detect new day
  wire new_year, new_month; //Detect new year/month

  //separation and combination of date signals
  assign {day_in, month_in, year_in} = date_in;
  assign date_out = {day_reg, month_reg, year_reg};

  //edge detaction for year & month changes
  assign new_year = (month_reg == 4'd1) & (month_reg_del != 4'd1);
  assign new_month = (day_reg == 4'd1) & (day_reg_del != 4'd1);

  always@(posedge clk) //edge detection
    begin
      new_day <= (hour_in == 5'd0) & (hour_reg == 5'd23);
    end

  always@(posedge clk) //generate delayed signals for edge detection
    begin
      hour_reg <= hour_in;
      day_reg_del <= day_reg;
      month_reg_del <= month_reg;
    end

  //handle year
  always@(posedge clk or posedge date_ow)
    begin
      if(date_ow)
        begin
          year_reg <= year_in;
        end
      else
        begin
          if(new_year)
            begin
              year_reg <= year_reg +{{(YEARRES-1){1'd0}},1'd1}; 
            end
        end
    end     

  //handle month
  always@(posedge clk or posedge date_ow)
    begin
      if(date_ow)
        begin
          month_reg <= month_in;
        end
      else
        begin
          if(new_month)
            begin
              month_reg <= (month_reg == 4'd12) ? 4'd1 : (month_reg + 4'd1); 
            end
        end
    end     
    
  //handle day
  always@(posedge clk or posedge date_ow) 
    begin
      if(date_ow)
        begin
          day_reg <= day_in;
        end
      else
        begin
          if(new_day)
            begin
              casex(month_reg)
                4'd2: //spacial case febuary
                  begin
                    /*
                     *  leap years:
                     *  if (year is not divisible by 4) then (it is a common year)
                     *  else if (year is not divisible by 100) then (it is a leap year)
                     *  else if (year is not divisible by 400) then (it is a common year)
                     *  else (it is a leap year)
                     */
                    if(year_reg[1:0] == 2'b00)
                      begin
                        day_reg <= (day_reg == 5'd29) ? 5'd1 : (day_reg + 5'd1);  
                      end
                    else
                      begin
                         day_reg <= (day_reg == 5'd28) ? 5'd1 : (day_reg + 5'd1);
                      end
                  end
                4'b0??0: //even months; April and June
                  begin
                    day_reg <= (day_reg == 5'd30) ? 5'd1 : (day_reg + 5'd1);
                  end
                4'b0??1: //odd months; January, March, May and July
                  begin
                    day_reg <= (day_reg == 5'd31) ? 5'd1 : (day_reg + 5'd1);
                  end
                4'b1??0: //even months; August, October, December
                  begin
                    day_reg <= (day_reg == 5'd31) ? 5'd1 : (day_reg + 5'd1);
                  end
                4'b1??1: //odd months; September, November
                  begin
                    day_reg <= (day_reg == 5'd30) ? 5'd1 : (day_reg + 5'd1);
                  end
              endcase
            end
        end
    end
endmodule

module clockCalendarDec4(clk, hour_in, date_in, date_out, date_ow);
  input clk, date_ow; //System clock, Date overwrite (asynchronous reset)
  //Time signal format: hh_hhhh:mmm_mmmm:sss_ssss
  input [5:0] hour_in; //hour data

  //Date signal format: dd_dddd.m_mmmm.yy_yyyy_yyyy_yyyy
  //Year signal can be adjusted to count from another refence than 0, e.g. 1900, to reduce bit size
  input [24:0] date_in; //date input
  output [24:0] date_out; //main output

  //separated date signals to respective meaning
  wire [5:0] day_in;
  wire [4:0] month_in;
  wire [13:0] year_in;
  reg [5:0] day_reg, day_reg_del; //day_reg_del: delayed signal
  reg [4:0] month_reg, month_reg_del; //month_reg_del: delayed signal
  reg [13:0] year_reg;

  reg [5:0] hour_reg; //Store previous hour data
  reg new_day; //Detect new day
  wire new_year, new_month; //Detect new year/month

  //separation and combination of date signals
  assign {day_in, month_in, year_in} = date_in;
  assign date_out = {day_reg, month_reg, year_reg};

  //edge detaction for year & month changes
  assign new_year = (month_reg == 5'h1) & (month_reg_del != 5'h1);
  assign new_month = (day_reg == 5'h1) & (day_reg_del != 5'h1);

  always@(posedge clk) //edge detection
    begin
      new_day <= (hour_in == 6'h0) & (hour_reg == 6'h23);
    end

  always@(posedge clk) //generate delayed signals for edge detection
    begin
      hour_reg <= hour_in;
      day_reg_del <= day_reg;
      month_reg_del <= month_reg;
    end

  //handle year
  always@(posedge clk or posedge date_ow)
    begin
      if(date_ow)
        begin
          year_reg <= year_in;
        end
      else
        begin
          if(new_year)
            begin
              casex(year_reg)
                14'h?999: year_reg <= {(year_reg[13:12]+2'd1),12'h000};
                14'h??99: year_reg <= {(year_reg[13:8]+6'd1),8'h00};
                14'h???9: year_reg <= {(year_reg[13:4]+10'd1),4'h0};
                default: year_reg <= year_reg + 14'b1;
              endcase 
            end
        end
    end     

  //handle month
  always@(posedge clk or posedge date_ow)
    begin
      if(date_ow)
        begin
          month_reg <= month_in;
        end
      else
        begin
          if(new_month)
            begin
              case(month_reg)
                5'h12: month_reg <= 5'h1;
                5'h09: month_reg <= 5'h10;
                default: month_reg <= month_reg + 5'd1;
              endcase 
            end
        end
    end     
    
  //handle day
  always@(posedge clk or posedge date_ow) 
    begin
      if(date_ow)
        begin
          day_reg <= day_in;
        end
      else
        begin
          if(new_day)
            begin
              casex(month_reg)
                5'd2: //spacial case febuary
                    /*
                     *  leap years:
                     *  if (year is not divisible by 4) then (it is a common year)
                     *  else if (year is not divisible by 100) then (it is a leap year)
                     *  else if (year is not divisible by 400) then (it is a common year)
                     *  else (it is a leap year)
                     */
                    casex(day_reg)
                      6'h29: day_reg <= 6'h1;
                      6'h28: day_reg <= (year_reg[1:0] == 2'b00) ? 6'h29 : 6'h1;
                      6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                      default: day_reg <= day_reg + 6'd1;
                    endcase
                5'b00??0: //even months; April and June; 4, 6
                  casex(day_reg)
                    6'h30: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b00??1: //odd months; January, March, May and July; 1, 3, 5, 7
                  casex(day_reg)
                    6'h31: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b????0: //even months; August, October, December; 8, 10, 12
                  casex(day_reg)
                    6'h31: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b????1: //odd months; September, November; 9, 11
                  casex(day_reg)
                    6'h30: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                    default: day_reg <= day_reg + 6'd1;
                  endcase
              endcase
            end
        end
    end
endmodule

module clockCalendarDec2(clk, hour_in, date_in, date_out, date_ow);
  input clk, date_ow; //System clock, Date overwrite (asynchronous reset)
  //Time signal format: hh_hhhh:mmm_mmmm:sss_ssss
  input [5:0] hour_in; //hour data

  //Date signal format: dd_dddd.m_mmmm.yy_yyyy_yyyy_yyyy
  //Year signal can be adjusted to count from another refence than 0, e.g. 1900, to reduce bit size
  input [18:0] date_in; //date input
  output [18:0] date_out; //main output

  //separated date signals to respective meaning
  wire [5:0] day_in;
  wire [4:0] month_in;
  wire [7:0] year_in;
  reg [5:0] day_reg, day_reg_del; //day_reg_del: delayed signal
  reg [4:0] month_reg, month_reg_del; //month_reg_del: delayed signal
  reg [7:0] year_reg;

  reg [5:0] hour_reg; //Store previous hour data
  reg new_day; //Detect new day
  wire new_year, new_month; //Detect new year/month

  //separation and combination of date signals
  assign {day_in, month_in, year_in} = date_in;
  assign date_out = {day_reg, month_reg, year_reg};

  //edge detaction for year & month changes
  assign new_year = (month_reg == 5'h1) & (month_reg_del != 5'h1);
  assign new_month = (day_reg == 5'h1) & (day_reg_del != 5'h1);

  always@(posedge clk) //edge detection
    begin
      new_day <= (hour_in == 6'h0) & (hour_reg == 6'h23);
    end

  always@(posedge clk) //generate delayed signals for edge detection
    begin
      hour_reg <= hour_in;
      day_reg_del <= day_reg;
      month_reg_del <= month_reg;
    end

  //handle year
  always@(posedge clk or posedge date_ow)
    begin
      if(date_ow)
        begin
          year_reg <= year_in;
        end
      else
        begin
          if(new_year)
            begin
              casex(year_reg)
                8'h?9: year_reg <= {(year_reg[7:4]+4'd1),4'h0};
                default: year_reg <= year_reg + 8'b1;
              endcase 
            end
        end
    end     

  //handle month
  always@(posedge clk or posedge date_ow)
    begin
      if(date_ow)
        begin
          month_reg <= month_in;
        end
      else
        begin
          if(new_month)
            begin
              case(month_reg)
                5'h12: month_reg <= 5'h1;
                5'h09: month_reg <= 5'h10;
                default: month_reg <= month_reg + 5'd1;
              endcase 
            end
        end
    end     
    
  //handle day
  always@(posedge clk or posedge date_ow) 
    begin
      if(date_ow)
        begin
          day_reg <= day_in;
        end
      else
        begin
          if(new_day)
            begin
              casex(month_reg)
                5'd2: //spacial case febuary
                    /*
                     *  leap years:
                     *  if (year is not divisible by 4) then (it is a common year)
                     *  else if (year is not divisible by 100) then (it is a leap year)
                     *  else if (year is not divisible by 400) then (it is a common year)
                     *  else (it is a leap year)
                     */
                    casex(day_reg)
                      6'h29: day_reg <= 6'h1;
                      6'h28: day_reg <= (year_reg[1:0] == 2'b00) ? 6'h29 : 6'h1;
                      6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                      default: day_reg <= day_reg + 6'd1;
                    endcase
                5'b00??0: //even months; April and June; 4, 6
                  casex(day_reg)
                    6'h30: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b00??1: //odd months; January, March, May and July; 1, 3, 5, 7
                  casex(day_reg)
                    6'h31: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b????0: //even months; August, October, December; 8, 10, 12
                  casex(day_reg)
                    6'h31: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b????1: //odd months; September, November; 9, 11
                  casex(day_reg)
                    6'h30: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0};
                    default: day_reg <= day_reg + 6'd1;
                  endcase
              endcase
            end
        end
    end
endmodule
