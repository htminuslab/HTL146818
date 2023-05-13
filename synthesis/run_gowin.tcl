set a1 [lindex $argv 0] 
set a2 [lindex $argv 1] 
puts "Place Option $a1"
puts "Route Option $a2"
set basename HTL146818$a1$a2

add_file -type vhdl "../rtl/bin_2_bcd.vhd"
add_file -type vhdl "../rtl/bin_2_bcdpm.vhd"
add_file -type vhdl "../rtl/binpm_2_bin.vhd"
add_file -type vhdl "../rtl/redge.vhd"
add_file -type vhdl "../rtl/ram_synch_in.vhd"
add_file -type vhdl "../rtl/mem_block_rtl.vhd"
add_file -type vhdl "../rtl/redge3ff.vhd"
add_file -type vhdl "../rtl/clock_gen_rtl.vhd"
add_file -type vhdl "../rtl/timefsm.vhd"
add_file -type vhdl "../rtl/bin_2_binpm.vhd"
add_file -type vhdl "../rtl/bcd_2_bin.vhd"
add_file -type vhdl "../rtl/alarm_rtl.vhd"
add_file -type vhdl "../rtl/bcdpm_2_bin.vhd"
add_file -type vhdl "../rtl/htl146818.vhd"

#add_file -type cst  "htl146818.cst"
add_file -type sdc  "htl146818.sdc"
set_device GW1NZ-LV1QN48C6/I5 -name GW1NZ-1
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name HTL146818$a1$a2
set_option -rpt_auto_place_io_info 1
set_option -gen_text_timing_rpt 1
set_option -top_module HTL146818
set_option -vhdl_std vhd2008
set_option -use_mspi_as_gpio 1
set_option -use_sspi_as_gpio 1
set_option -print_all_synthesis_warning 1


#default 1, option 0
set_option -timing_driven 1

# default 0, option 1
set_option -place_option $a1

#default 0 option 1,2
set_option -route_option $a2

#set_option -gen_vhdl_sim_netlist 1
#set_option -gen_sdf 1 
run all
