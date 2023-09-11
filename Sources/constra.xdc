# Clock signal
set_property PACKAGE_PIN W5 [get_ports {i_clock}]							
	set_property IOSTANDARD LVCMOS33 [get_ports {i_clock}]
	# create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 5} [get_ports i_clock]
 
# Buttons
set_property PACKAGE_PIN W19 [get_ports {i_reset}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_reset}]
set_property PACKAGE_PIN T17 [get_ports {i_reset_wz}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_reset_wz}]
set_property PACKAGE_PIN T18 [get_ports {i_tx_start}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_start}]

#USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports {i_rx}]						
	set_property IOSTANDARD LVCMOS33 [get_ports {i_rx}]
set_property PACKAGE_PIN A18 [get_ports {o_tx}]						
	set_property IOSTANDARD LVCMOS33 [get_ports {o_tx}]

# Switches
set_property PACKAGE_PIN V17 [get_ports {i_tx_data[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_data[0]}]
set_property PACKAGE_PIN V16 [get_ports {i_tx_data[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_data[1]}]
set_property PACKAGE_PIN W16 [get_ports {i_tx_data[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_data[2]}]
set_property PACKAGE_PIN W17 [get_ports {i_tx_data[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_data[3]}]
set_property PACKAGE_PIN V15 [get_ports {i_tx_data[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_data[4]}]
set_property PACKAGE_PIN W14 [get_ports {i_tx_data[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_data[5]}]
set_property PACKAGE_PIN W13 [get_ports {i_tx_data[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_data[6]}]
set_property PACKAGE_PIN V2 [get_ports {i_tx_data[7]}]	
	set_property IOSTANDARD LVCMOS33 [get_ports {i_tx_data[7]}]

# LEDs
#TX data
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

# Tx Done Rx Done
set_property PACKAGE_PIN U3 [get_ports {o_rx_done}]					
 	set_property IOSTANDARD LVCMOS33 [get_ports {o_rx_done}]
set_property PACKAGE_PIN P3 [get_ports {o_tx_done}]					
 	set_property IOSTANDARD LVCMOS33 [get_ports {o_tx_done}]

set_property PACKAGE_PIN L1 [get_ports {o_locked}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_locked}]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]