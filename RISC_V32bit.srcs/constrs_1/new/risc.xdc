# ----------------------------------------------------------------------------
# System Clock
# This provides the 100MHz clock to your processor (pin Y9).
# ----------------------------------------------------------------------------

set_property PACKAGE_PIN Y9 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports clock]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clock]


# ----------------------------------------------------------------------------
# System Reset
# User Push Button "BTNC" (Center, pin P16).
# Bank 34, default IOSTANDARD is LVCMOS18.
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN P16 [get_ports reset]
set_property IOSTANDARD LVCMOS18 [get_ports reset]


# ----------------------------------------------------------------------------
# User DIP Switches (SW0-SW7)
# Bank 35, default IOSTANDARD is LVCMOS18.
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN F22 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[0]}]
set_property PACKAGE_PIN G22 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[1]}]
set_property PACKAGE_PIN H22 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[2]}]
set_property PACKAGE_PIN F21 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[3]}]
set_property PACKAGE_PIN H19 [get_ports {sw[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[4]}]
set_property PACKAGE_PIN H18 [get_ports {sw[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[5]}]
set_property PACKAGE_PIN H17 [get_ports {sw[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[6]}]
set_property PACKAGE_PIN M15 [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[7]}]


# ----------------------------------------------------------------------------
# User LEDs (LD0-LD7)
# Bank 33, IOSTANDARD is LVCMOS33.
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN T21 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN U22 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN U21 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN V22 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN W22 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN U19 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property PACKAGE_PIN U14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
set_property PACKAGE_PIN U16 [get_ports zero]
set_property IOSTANDARD LVCMOS33 [get_ports zero]