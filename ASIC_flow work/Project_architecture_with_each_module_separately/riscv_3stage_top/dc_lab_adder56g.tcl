set DESIGN_REF_PATH "/home/student/24MVD1016_Thesis/Project4_3/riscv_3stage_top"

set SEARCH_PATH      "${DESIGN_REF_PATH}"

set_app_var search_path "$SEARCH_PATH"

set link_library   {saed32hvt_ff0p95v125c.db saed32hvt_ff0p95vn40c.db} 

set target_library  {saed32hvt_ff0p95v125c.db saed32hvt_ff0p95vn40c.db}

analyze -format verilog {./riscv_core_top.v ./riscv_regfile.v ./riscv_id.v ./riscv_ex.v ./riscv_dmem_syncram.v}
read_file -format verilog {./riscv_core_top.v ./riscv_regfile.v ./riscv_id.v ./riscv_ex.v ./riscv_dmem_syncram.v}


link

check_design

write_file -format verilog -output ./riscv_core_top.v56g.vs


source ./constraints1.sdc
compile_ultra 

# Step 7: Generate reports for area, power, and timing
report_area > riscv_core_top_area.rpt
report_power > riscv_core_top_power.rpt
report_timing > riscv_core_top_timing.rpt
report_constraint -verbose
report_qor


# Step 9: Write the final netlist (Verilog) and constraints
write -hierarchy -format verilog -output ./riscv_core_top_netlist.v
write_sdc ./riscv_core_top_synth.sdc
