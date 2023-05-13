@REM ------------------------------------------------------
@REM Simple DOS batch file to compile and run the testbench
@REM Tested with Modelsim 5.8c
@REM ------------------------------------------------------
vlib work

@REM Compile HTL146818 

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


@REM Compile Testbench

vcom -93 -quiet -work work ../testbench/tester_behaviour.vhd
vcom -93 -quiet -work work ../testbench/edge_flag.vhd
vcom -93 -quiet -work work ../testbench/top_rtc_tb.vhd

@REM Run simulation
vsim work.htl146818_tb -c -do "set StdArithNoWarnings 1; run -all; quit -f"
