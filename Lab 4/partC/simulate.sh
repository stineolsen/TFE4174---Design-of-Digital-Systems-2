rm -rf work
vlib work
vlog +cover=bcefsx -sv test-toplevel.sv toplevel.v ex1-1.v toplevel-property.sv
vcom alu.vhd 
vsim -c -coverage test_toplevel  -do "run 1000ns; coverage report -memory -cvg -details -file coverage_rep.txt;exit"
