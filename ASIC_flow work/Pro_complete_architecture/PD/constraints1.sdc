create_clock -name clk -period 10.0 [get_ports clk]   

set_clock_uncertainty -setup 0.06 [get_clocks clk]

set_false_path -from [get_ports resetn] -to [get_pins -hierarchical *]   

set_max_fanout 150

set_clock_groups -asynchronous -group { [get_clocks clk] }



