/* ------------------------------------------------ *
 * Title       : Clockwork                          *
 * Project     : Digital Clock                      *
 * ------------------------------------------------ *
 * File        : clockwork.v                        *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 21/04/2021                         *
 * ------------------------------------------------ *
 * Description : Time keeping module for a clock    *
 * ------------------------------------------------ */

module clockWorkHex(clk_1hz, time_in, time_out, time_ow);
  input clk_1hz, time_ow; //1 Hz clock (clock), Time overwrite (asynchronous reset)
  //Time signal format: hhhhh:mmmmmm:ssssss
  input [16:0] time_in; //time input
  output [16:0] time_out; //main output

  //separated time signals to respective meaning
  wire [5:0] sec_in, min_in;
  wire [4:0] hour_in;
  reg [5:0] sec_reg, min_reg;
  reg [4:0] hour_reg;

  //separation and combination of time signals
  assign {hour_in, min_in, sec_in} = time_in;
  assign time_out = {hour_reg, min_reg, sec_reg};

  //handle seconds
  always@(posedge clk_1hz or posedge time_ow)
    begin
      if(time_ow)
        begin
          sec_reg <= sec_in;
        end
      else
        begin
          sec_reg <= (sec_reg == 6'd59) ? 6'd0 : (sec_reg + 6'd1);
        end
    end

  //handle minutes
  always@(posedge clk_1hz or posedge time_ow)
    begin
      if(time_ow)
        begin
          min_reg <= min_in;
        end
      else
        begin
          if(sec_reg == 6'd59)
            begin
              min_reg <= (min_reg == 6'd59) ? 6'd0 : (min_reg + 6'd1);
            end
        end
    end

  //handle hours
  always@(posedge clk_1hz or posedge time_ow)
    begin
      if(time_ow)
        begin
          hour_reg <= hour_in;
        end
      else
        begin
          if((sec_reg == 6'd59)&(min_reg == 6'd59))
            begin
              hour_reg <= (hour_reg == 5'd23) ? 5'd0 : (hour_reg + 5'd1);
            end
        end
    end  
endmodule

module clockWorkDec(clk_1hz, time_in, time_out, time_ow);
  input clk_1hz, time_ow; //1 Hz clock (clock), Time overwrite (asynchronous reset)
  //Time signal format: hh_hhhh:mmm_mmmm:sss_ssss only decimal values
  input [19:0] time_in; //time input
  output [19:0] time_out; //main output

  //separated time signals to respective meaning
  wire [6:0] sec_in, min_in;
  wire [5:0] hour_in;
  reg [6:0] sec_reg, min_reg;
  reg [5:0] hour_reg;

  //separation and combination of time signals
  assign {hour_in, min_in, sec_in} = time_in;
  assign time_out = {hour_reg, min_reg, sec_reg};

  //handle seconds
  always@(posedge clk_1hz or posedge time_ow)
    begin
      if(time_ow)
        begin
          sec_reg <= sec_in;
        end
      else
        begin
          casex(sec_reg)
            7'h59:
              begin
                sec_reg <= 7'd0;
              end
            7'hx9:
              begin
                sec_reg <= {(sec_reg[6:4]+3'd1),4'h0};
              end
            default:
              begin
                sec_reg <= sec_reg + 7'd1;
              end
          endcase
        end
    end

  //handle minutes
  always@(posedge clk_1hz or posedge time_ow)
    begin
      if(time_ow)
        begin
          min_reg <= min_in;
        end
      else
        begin
          if(sec_reg == 7'h59)
            begin
              casex(min_reg)
                7'h59:
                  begin
                    min_reg <= 7'h0;
                  end
                7'hx9:
                  begin
                    min_reg <= {(min_reg[6:4]+3'd1),4'h0};
                  end
                default:
                  begin
                    min_reg <= min_reg + 7'd1;
                  end
              endcase
            end
        end
    end

  //handle hours
  always@(posedge clk_1hz or posedge time_ow)
    begin
      if(time_ow)
        begin
          hour_reg <= hour_in;
        end
      else
        begin
          if((sec_reg == 7'h59)&(min_reg == 7'h59))
            begin
              casex(hour_reg)
                6'h23:
                  begin
                    hour_reg <= 6'd0;
                  end
                6'b0x1001: //09 & 19
                  begin
                    hour_reg <= {(hour_reg[5:4]+3'd1),4'd0};
                  end
                default:
                  begin
                    hour_reg <= hour_reg + 6'd1;
                  end
              endcase
            end
        end
    end  
endmodule
