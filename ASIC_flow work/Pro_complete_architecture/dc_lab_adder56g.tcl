set DESIGN_REF_PATH "/home/student/24MVD1016_Thesis/Pro3"

set SEARCH_PATH      "${DESIGN_REF_PATH}"

set_app_var search_path "$SEARCH_PATH"

set link_library   {saed32hvt_ff0p95v125c.db saed32hvt_ff0p95vn40c.db} 

set target_library  {saed32hvt_ff0p95v125c.db saed32hvt_ff0p95vn40c.db}

analyze -format verilog {./riscv_3stage.v}
read_file -format verilog {./riscv_3stage.v}


link

check_design

write_file -format verilog -output ./riscv_3stage56g.vs


source ./constraints1.sdc
compile_ultra 

# Step 7: Generate reports for area, power, and timing
report_area > riscv_3stage_area.rpt
report_power > riscv_3stage_power.rpt
report_timing > riscv_3stage_timing.rpt
report_constraint -verbose
report_qor


# Step 9: Write the final netlist (Verilog) and constraints
write -hierarchy -format verilog -output ./riscv_3stage_netlist.v
write_sdc ./riscv_3stage_synth.sdc
