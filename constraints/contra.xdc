
# Clock signal
set_property PACKAGE_PIN W5 [get_ports i_clock]							
	set_property IOSTANDARD LVCMOS33 [get_ports i_clock]
 
# BUTTONS
set_property PACKAGE_PIN W19 [get_ports {i_reset}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_reset}]
set_property PACKAGE_PIN V16 [get_ports {i_clock_reset}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_clock_reset}]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {o_state[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[0]}]
set_property PACKAGE_PIN E19 [get_ports {o_state[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[1]}]
set_property PACKAGE_PIN U19 [get_ports {o_state[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[2]}]
set_property PACKAGE_PIN V19 [get_ports {o_state[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[3]}]
set_property PACKAGE_PIN W18 [get_ports {o_state[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[4]}]
set_property PACKAGE_PIN U15 [get_ports {o_state[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[5]}]
set_property PACKAGE_PIN U14 [get_ports {o_state[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[6]}]
set_property PACKAGE_PIN V14 [get_ports {o_state[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[7]}]
set_property PACKAGE_PIN V13 [get_ports {o_state[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[8]}]
set_property PACKAGE_PIN V3 [get_ports {o_state[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[9]}]
set_property PACKAGE_PIN P1 [get_ports {o_halt}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_halt}]
set_property PACKAGE_PIN L1 [get_ports {o_locked}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_locked}]



#USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports i_uart_debug_unit_rx]						
	set_property IOSTANDARD LVCMOS33 [get_ports i_uart_debug_unit_rx]
set_property PACKAGE_PIN A18 [get_ports o_uart_debug_unit_tx]						
	set_property IOSTANDARD LVCMOS33 [get_ports o_uart_debug_unit_tx]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
