read_verilog /home/tinumathew/My_TINGS/scr/scripting/counter.v
read_xdc design_constraints.sdc
synth_design -top [file rootname [file tail /home/tinumathew/My_TINGS/scr/scripting/counter.v]] -part xc7a100tcsg324-1
opt_design
place_design
route_design
report_timing_summary -file temp_timing.txt
report_power_summary -file temp_power.txt
report_utilization -file temp_area.txt
exit
