create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clock]
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports i_clock]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports i_reset]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports o_locked]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports o_ack_debug]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports o_end_send_data]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports i_rx_data]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports o_tx_data]



