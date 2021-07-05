//pin_E1 is clock
//set_location_assignment PIN_E1 -to clk
//set_location_assignment PIN_L14 -to LED[0]
//set_location_assignment PIN_K15 -to LED[1]
//set_location_assignment PIN_J14 -to LED[2]
//set_location_assignment PIN_J13 -to LED[3]


module top( input clk,
				input reset,
				output blinker,
            output tx_pin);
            
    wire tx_clk_rst;
	 wire sys_rst;
    wire uart_busy_signal;
      
    clkgen #(.CLOCK_FREQ(50000000), .f_clk(9600)) (sys_rst, clk, sys_clk);
    clkgen #(.CLOCK_FREQ(50000000), .f_clk(4)) (tx_clk_rst, clk, sys_clk2);
	 clkgen #(.CLOCK_FREQ(50000000), .f_clk(1)) (sys_rst, clk, sys_clk3);
    
    assign tx_clk_rst = (sys_rst & ~uart_busy_signal);
    assign sys_rst = reset;
	 assign blinker = sys_clk3;
    
    uart test_uart(    
        .clk(sys_clk),
        .reset(sys_rst),
        .rx_pin(),
        .tx_start(sys_clk2),
        .tx_data(8'h41),
        .tx_pin(tx_pin), 
        .rx_data(), 
        .rx_busy(),
        .tx_busy(uart_busy_signal));
        
endmodule