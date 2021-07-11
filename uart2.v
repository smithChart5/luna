///////////////////////////////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

//`timescale <time_units> / <precision>


module uart2 #(parameter PARITY = 0, parameter STOP_BITS = 1, parameter DATA_LENGTH = 8, BAUD_RATE = 460800, CLOCK_SPEED = 50000000)
            (   input clk, 
					input reset, 
					input rx_pin, 
					input tx_start, 
					input [7:0] tx_data,
               output tx_pin, 
					output tx_busy , 
					output reg [7:0] rx_data, 
					output reg rx_busy);
					
	//shared varibles
	parameter HALF_PERIOD = CLOCK_SPEED/BAUD_RATE/2;						
	parameter FULL_PERIOD = 2*HALF_PERIOD;
	parameter PACKET_SIZE = (PARITY + STOP_BITS + DATA_LENGTH + 1); 	//FIXME, check this packet size, +1 for start bit?
																							//parity not currently supported
	
////////////////////////////////////////////////////////////////
/////////////TX section/////////////////////////////////////////
////////////////////////////////////////////////////////////////

	//tx variables
	reg [1:0]current_state, next_state;
	parameter   idle = 2'b00,
				 tx_mode = 2'b01;
	reg [(PACKET_SIZE-1):0]tx_data_buffer;
	reg tx_pin_buffer;
	reg tx_busy_buffer;
	reg [3:0]tx_shift_counter;
	integer uart_clk;
	 
	//tx process state memory
	always @ (posedge clk or negedge reset) begin: tx_state_memory
	  if (!reset)
			current_state <= idle;
	  else
			current_state <= next_state;
	end

	//tx process next state logic
	//always @ (current_state or tx_start or clk or tx_shift_counter) begin:tx_next_state_logic
	always @ (current_state or tx_start or clk or tx_shift_counter) begin:tx_next_state_logic
	  case(current_state)
			idle:   
				 if(tx_start == 1'b1) 
					  next_state = tx_mode;
				 else
					  next_state = idle;
			tx_mode:
				 if(tx_shift_counter == (PACKET_SIZE))
					  next_state = idle;
				 else
					  next_state = tx_mode;
	  endcase
	end

	//tx process output logic
	always @ (posedge clk) begin: tx_output_logic
		case(current_state)
			idle: begin
					tx_busy_buffer = 1'b0;
					tx_pin_buffer = 1'b1;
					tx_shift_counter = 0;
					uart_clk = 0;
					if(tx_start == 1'b1)
						tx_data_buffer = { 1'b1, tx_data, 1'b0};    //data is LSB first, {stop bit, data, start bit}
				end
			tx_mode: begin
					tx_busy_buffer = 1'b1;
					tx_pin_buffer = tx_data_buffer[0];
					if (uart_clk == FULL_PERIOD - 1) 
						begin
							tx_data_buffer = {1'b1, tx_data_buffer[9:1]};
							tx_shift_counter = tx_shift_counter + 1;
							uart_clk = 0;
						end
					else
						uart_clk = uart_clk + 1;
				end
		endcase
	end

	assign tx_pin = tx_pin_buffer;
	assign tx_busy = tx_busy_buffer;
		
////////////////////////////////////////////////////////////////
/////////////RX section/////////////////////////////////////////
////////////////////////////////////////////////////////////////

	//rx variables
	reg [1:0] rx_current_state, rx_next_state;
	parameter   rx_idle = 2'b00,
				 rx_mode = 2'b10,
				 rx_end = 2'b11;
	reg [9:0]rx_data_buffer;
	integer rx_shift_counter;
	integer rx_clk_counter;
	
	//rx process state memory
	always @ (posedge clk or negedge reset) begin: rx_state_memory
	  if (!reset)
			rx_current_state <= rx_idle;
	  else
			rx_current_state <= rx_next_state;
	end	

	//rx process next state logic
	always @ (rx_current_state or rx_pin or rx_shift_counter or clk or rx_clk_counter) begin:rx_next_state_logic
	//always @ * begin:rx_next_state_logic
		case(rx_current_state)
			rx_idle: begin
				if(rx_pin == 1'b0) 
					rx_next_state <= rx_mode;
				else
					rx_next_state <= rx_idle;
			end
			rx_mode: begin
				if (rx_shift_counter == PACKET_SIZE)
					rx_next_state <= rx_end;
				else
					rx_next_state <= rx_mode;
			end
			rx_end: begin
				rx_next_state <= rx_idle;
			end
			default: begin
				rx_next_state <= rx_idle;
			end
		endcase
	end
	
	//rx process output logic
	//always @ (clk) begin : rx_output_logic
	//always @(clk or rx_pin or rx_current_state or rx_data_buffer) begin : rx_output_logic
	always @(posedge clk) begin : rx_output_logic
		case(rx_current_state)
			idle: begin
				rx_shift_counter <= 0;
				rx_clk_counter <= 0;
				rx_data_buffer <= 10'b0000000000;
				rx_busy <= 1'b0;
			end
			rx_mode: begin
				rx_busy <= 1'b1;
				rx_clk_counter <= rx_clk_counter + 1;
				if((rx_shift_counter == 0) && (rx_clk_counter == HALF_PERIOD)) begin
					rx_data_buffer <= {9'b000000000, rx_pin};
					rx_clk_counter <= 0;
					rx_shift_counter <= 1;
				end else if((rx_shift_counter <= PACKET_SIZE) && (rx_clk_counter == FULL_PERIOD)) begin
					rx_data_buffer[rx_shift_counter] <= rx_pin;
					rx_shift_counter <= rx_shift_counter + 1;
					rx_clk_counter <= 0;
				end else begin
					rx_data_buffer <= rx_data_buffer;
					rx_shift_counter <= rx_shift_counter;
				end
			end
			rx_end: begin
				rx_busy <= 1'b1;
				rx_shift_counter <= 0;
				rx_clk_counter <= 0;
				if((rx_data_buffer[0] == 1'b0) && (rx_data_buffer[9] == 1'b1))
					rx_data <= rx_data_buffer[8:1];
			end
		endcase
	end

	
	
    
endmodule



































