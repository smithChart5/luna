//////////////////////////////////////////////////////////////////////
// Created by Microsemi SmartDesign Tue Jun 15 19:02:51 2021
// Testbench Template
// This is a basic testbench that instantiates your design with basic 
// clock and reset pins connected.  If your design has special
// clock/reset or testbench driver requirements then you should 
// copy this file and modify it. 
//////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: uart1_tb.v
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

`timescale 1ns/100ps

module uart2_tb;

parameter SYSCLK_PERIOD = 50;// 50MHZ

reg SYSCLK;
reg NSYSRESET;
reg rx_input;
wire tx_pin_data;
reg tx_start_tb;

initial
begin
    SYSCLK = 1'b0;
    NSYSRESET = 1'b0;
end

//////////////////////////////////////////////////////////////////////
// Reset Pulse
//////////////////////////////////////////////////////////////////////
initial
begin
    #(SYSCLK_PERIOD * 10 )
        NSYSRESET = 1'b1;
    
end

//////////////////////////////////////////////////////////////////////
// Stimulus
//////////////////////////////////////////////////////////////////////
initial
begin
	rx_input = 1'b1;
	tx_start_tb = 1'b0;
	#(SYSCLK_PERIOD * 20 )
	tx_start_tb = 1'b1;
	#(SYSCLK_PERIOD*1)
	tx_start_tb = 1'b0;
	#(SYSCLK_PERIOD * 200 )
	rx_input = 1'b0;
	#(SYSCLK_PERIOD * 200 )
	rx_input = 1'b1;
	
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;


//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  uart1
//////////////////////////////////////////////////////////////////////
uart2 uart1_0 (
    // Inputs
    .clk(SYSCLK),
    .reset(NSYSRESET),
    .rx_pin( ),
    .tx_start(tx_start_tb),
    .tx_data({8'b0100_0001}),

    // Outputs
    .tx_pin(tx_pin_data),
    .rx_data( ),
    .rx_busy( ),
    .tx_busy( )

);

uart2 rx_uart (
    // Inputs
    .clk(SYSCLK),
    .reset(NSYSRESET),
    .rx_pin(tx_pin_data),
    .tx_start(1'b0),
    .tx_data( ),

    // Outputs
    .tx_pin( ),
    .rx_data( ),
    .rx_busy( ),
    .tx_busy( )

);

endmodule

