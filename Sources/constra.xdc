# Clock signal
set_property PACKAGE_PIN W5 [get_ports i_clock]							
	set_property IOSTANDARD LVCMOS33 [get_ports i_clock]
	create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 5} [get_ports i_clock]
 
# Buttons
set_property PACKAGE_PIN W19 [get_ports {i_reset}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_reset}]
set_property PACKAGE_PIN T17 [get_ports {i_reset_wz}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_reset_wz}]

#USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports i_rx_data]						
	set_property IOSTANDARD LVCMOS33 [get_ports i_rx_data]
set_property PACKAGE_PIN A18 [get_ports o_tx_data]						
	set_property IOSTANDARD LVCMOS33 [get_ports o_tx_data]


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
set_property PACKAGE_PIN W3 [get_ports {o_state[10]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[10]}]
set_property PACKAGE_PIN U3 [get_ports {o_state[11]}]					
 	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[11]}]
# set_property PACKAGE_PIN P3 [get_ports {o_state[3]}]					
#  	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[3]}]
# set_property PACKAGE_PIN N3 [get_ports {o_state[4]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[4]}]
# set_property PACKAGE_PIN P1 [get_ports {o_state[5]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {o_state[5]}]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]