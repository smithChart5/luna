//pin_E1 is clock
//set_location_assignment PIN_E1 -to clk
//set_location_assignment PIN_L14 -to LED[0]
//set_location_assignment PIN_K15 -to LED[1]
//set_location_assignment PIN_J14 -to LED[2]
//set_location_assignment PIN_J13 -to LED[3]



module top( input clk,
				input reset,
				input rx_in,
				output blinker,
            output tx_pin);			
            
    wire tx_clk_rst;
	 wire sys_rst;
    wire uart_busy_signal;
	 
	 wire [7:0] tmp_rx_data;
	 wire tmp_rx_busy;
	 reg one_shot1, one_shot2;
	 wire begin_tx;
	 reg really_start;
	 reg [7:0] return_data;
      
    clkgen #(.CLOCK_FREQ(50000000), .f_clk(9600)) u1(sys_rst, clk, sys_clk);
    clkgen #(.CLOCK_FREQ(50000000), .f_clk(25)) u2(tx_clk_rst, clk, sys_clk2);
	 clkgen #(.CLOCK_FREQ(50000000), .f_clk(2)) u3(sys_rst, clk, sys_clk3);
    
    assign tx_clk_rst = (sys_rst & ~uart_busy_signal);
    assign sys_rst = reset;
	 assign blinker = sys_clk3;
    
//    uart2 test_uart(    
//        .clk(clk),
//        .reset(sys_rst),
//        .rx_pin(),
//        .tx_start(sys_clk2),
//        .tx_data(8'h41),
//        .tx_pin(tx_pin), 
//        .rx_data(), 
//        .rx_busy(),
//        .tx_busy(uart_busy_signal));

    uart2 test_uart(    
        .clk(clk),
        .reset(sys_rst),
        .rx_pin(rx_in),
        .tx_start(really_start),
        .tx_data(return_data),
        .tx_pin(tx_pin), 
        .rx_data(tmp_rx_data), 
        .rx_busy(tmp_rx_busy),
        .tx_busy(uart_busy_signal));
		  

	always @ (posedge clk) begin
		if(!reset) begin
			one_shot1 <= 1'b0;
		end else begin
			one_shot1 <= tmp_rx_busy;
		end
	end
	
	assign begin_tx = ~tmp_rx_busy & one_shot1;
	
	always @ (posedge clk) begin
		if (begin_tx == 1) begin
			return_data <= tmp_rx_data + 1;
			really_start <= 1'b1;
		 end else begin
			really_start <= 1'b0;
		end
	end
        
endmodule






