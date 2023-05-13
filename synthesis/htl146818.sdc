// 27.008MHz 
create_clock -name clk -period 37 -waveform {0 18.5} [get_ports {clk}]
