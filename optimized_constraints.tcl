# Optimized constraints generated at Thu Apr 17 02:09:48 2025
set optimized_clock_period 1.18
set optimized_power_budget 100.00
set optimized_area_budget 1000

# Recommended constraints for synthesis
create_clock -period $optimized_clock_period [get_ports clk]
set_max_area $optimized_area_budget
set_max_power ${optimized_power_budget}mW

puts "Optimized constraints set:"
puts "  Clock period: $optimized_clock_period ns"
puts "  Power budget: $optimized_power_budget mW"
puts "  Area budget: $optimized_area_budget LUTs"
