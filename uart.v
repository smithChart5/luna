///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: uart1.v
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

module uart #(parameter parity = 0, parameter stop_bits = 1, parameter data_length = 8)
            (   input clk, 
					input reset, 
					input rx_pin, 
					input tx_start, 
					input [7:0] tx_data,
               output tx_pin, 
					output tx_busy , 
					output [7:0] rx_data, 
					output rx_busy);

    //tx variables
    reg [1:0]current_state, next_state;
    parameter packet_size = (parity + stop_bits + data_length + 1); //FIXME, check this lpacket size
    parameter   idle = 2'b00,
                tx_mode = 2'b01;
    reg [(packet_size-1):0]tx_data_buffer;
    reg tx_pin_buffer;
    reg tx_busy_buffer;
    reg [3:0]tx_shift_counter;
    
    //tx process state memory
    always @ (posedge clk or negedge reset)
    begin: tx_state_memory
        if (!reset)
            current_state <= idle;
        else
            current_state <= next_state;
    end
    
    //tx process next state logic
    always @ (current_state or tx_start or clk or tx_shift_counter)
    begin:tx_next_state_logic
        case(current_state)
            idle:   
                if(tx_start == 1'b1) 
                    next_state = tx_mode;
                else
                    next_state = idle;
            tx_mode:
                if(tx_shift_counter == (packet_size))
                    next_state = idle;
                else
                    next_state = tx_mode;
        endcase
    end
    
    //tx process output logic
    always @ (posedge clk)
    begin: tx_output_logic
        case(current_state)
            idle: begin
                tx_busy_buffer = 1'b0;
                tx_pin_buffer = 1'b1;
                tx_shift_counter = 0;
                if(tx_start == 1'b1)
                    tx_data_buffer = { 1'b1, tx_data, 1'b0};    //data is LSB first, {stop bit, data, start bit}
            end
            tx_mode: begin
                tx_busy_buffer = 1'b1;
                tx_pin_buffer = tx_data_buffer[0];
                //tx_data_buffer = tx_data_buffer >> 1;
                //switched to shifting in ones to prevent an output glitch when
                //swotching from tx_mode to idle with empty tx buffer
                tx_data_buffer = {1'b1, tx_data_buffer[9:1]};
                tx_shift_counter = tx_shift_counter + 1;
            end
        endcase
    end
    
    assign tx_pin = tx_pin_buffer;
    assign tx_busy = tx_busy_buffer;
    
endmodule











