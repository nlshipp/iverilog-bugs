iverilog -pfileline=1 -s inc_test_TB  inc_test_TB.v

vvp a.out

gtkwave inc_test_tb.vcd inc_test_tb.gtkw

