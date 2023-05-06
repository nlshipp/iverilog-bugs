iverilog -s OpenJTAG_TB  OpenJTAG_TB.v

vvp a.out

gtkwave openjtag_tb.vcd openjtag_tb.gtkw

