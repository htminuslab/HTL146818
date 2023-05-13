# Modelsim "do" file
vcom -93 -quiet -work work ../rtl/bin_2_bcd.vhd
vcom -93 -quiet -work work ../rtl/bin_2_bcdpm.vhd
vcom -93 -quiet -work work ../rtl/binpm_2_bin.vhd
vcom -93 -quiet -work work ../rtl/redge.vhd
vcom -93 -quiet -work work ../rtl/ram_synch_in.vhd
vcom -93 -quiet -work work ../rtl/mem_block_rtl.vhd
vcom -93 -quiet -work work ../rtl/redge3ff.vhd
vcom -93 -quiet -work work ../rtl/clock_gen_rtl.vhd
vcom -93 -quiet -work work ../rtl/timefsm.vhd
vcom -93 -quiet -work work ../rtl/bin_2_binpm.vhd
vcom -93 -quiet -work work ../rtl/bcd_2_bin.vhd
vcom -93 -quiet -work work ../rtl/alarm_rtl.vhd
vcom -93 -quiet -work work ../rtl/bcdpm_2_bin.vhd
vcom -93 -quiet -work work ../rtl/htl146818.vhd
vcom -93 -quiet -work work ../testbench/tester_behaviour.vhd
vcom -93 -quiet -work work ../testbench/edge_flag.vhd
vcom -93 -quiet -work work ../testbench/top_rtc_tb.vhd
vsim work.htl146818_tb  
set StdArithNoWarnings 1 
run -all 