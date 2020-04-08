//Yigit Suoglu
module date_module(clk, hour_in, date_in, date_out, date_ow);
    input clk, date_ow; //System clock, Date overwrite (asynchronous reset)
    //Time signal format: hhhhh_mmmmmm_ssssss
    input [4:0] hour_in; //hour data

    //Date signal format: ddddd_mmmm_yyyyyyyyyyyy
    //Year signal can be adjusted to count from another refence than 0, e.g. 1900, to reduce bit size
    input [20:0] date_in; //date input
    output [20:0] date_out; //main output

    //separated date signals to respective meaning
    wire [4:0] day_in;
    wire [3:0] month_in;
    wire [11:0] year_in;
    reg [4:0] day_reg, day_reg_del; //day_reg_del: delayed signal
    reg [3:0] month_reg, month_reg_del; //month_reg_del: delayed signal
    reg [11:0] year_reg;

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
                            year_reg <= year_reg + 12'd1; 
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
                                        casex(year_reg)
                                            12'b??????????00: //only divisible by 4 rule is considered
                                                begin
                                                    day_reg <= (day_reg == 5'd29) ? 5'd1 : (day_reg + 5'd1);  
                                                end
                                            //To Improve: add cases for other rules, case structure should be changed 
                                            default:
                                                begin
                                                    day_reg <= (day_reg == 5'd28) ? 5'd1 : (day_reg + 5'd1);
                                                end
                                        endcase
                                        
                                            
                                    end
                                4'b???0: //even months
                                    begin
                                        day_reg <= (day_reg == 5'd30) ? 5'd1 : (day_reg + 5'd1);
                                    end
                                4'b???1: //odd months
                                    begin
                                        day_reg <= (day_reg == 5'd31) ? 5'd1 : (day_reg + 5'd1);
                                    end
                            endcase
                            
                        end
                    
                end
        end
    

endmodule