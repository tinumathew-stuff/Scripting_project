read_verilog /home/tinumathew/My_TINGS/scr/scripting/sample.v
read_xdc design_constraints.sdc
synth_design -top counter -part xc7a100tcsg324-1
opt_design
place_design
route_design
report_timing -file timing_report.txt
report_power -file power_report.txt
report_utilization -file area_report.txt
exit
