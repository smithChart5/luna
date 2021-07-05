///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: clkgen1.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::IGLOO2> <Die::M2GL010> <Package::144 TQ>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

//`timescale <time_units> / <precision>

module clkgen
    #(  parameter CLOCK_FREQ = 20_000_000,  //test comment
        parameter f_clk = 17)              //lll
    ( input wire reset, sysclk,             //hhhhhh
                output reg clk_div);        //lllllllllllllll

    parameter limit = CLOCK_FREQ/f_clk;
    reg [31:0]counter;
    
    always @ (posedge sysclk)
    begin
        if (reset == 1'b0)
            begin
                clk_div = 1'b0;
                counter = 0;
            end
        else
        begin   
            if (counter < limit/2-1)
            begin
                clk_div = 0;
                counter = counter + 1;
            end
            else if (counter < limit-1)
            begin
                clk_div = 1;
                counter = counter + 1;
            end
            else if (counter == limit-1)
            begin
                clk_div = 0;
                counter = 0;
            end   
        end
    end
        


endmodule

