###################################################################

# Created by write_sdc on Thu Oct  9 14:25:55 2025

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA
create_clock [get_ports clk]  -period 10  -waveform {0 5}
set_clock_uncertainty -setup 0.06  [get_clocks clk]
