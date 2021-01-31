1)compile
iverilog -o test CPU_TEST.v

2)Run
vvp test

3)openwith gtkwave
gtkwave cpu_wavedata.vcd