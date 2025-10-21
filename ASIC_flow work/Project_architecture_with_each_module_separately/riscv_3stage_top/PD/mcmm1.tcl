set Constraints_file "./riscv_core_top_synth.sdc"

set DESIGN_REF_PATH "/home/student/24MVD1016_Thesis/Project4_3/riscv_3stage_top/PD/ref_32nm_ndm"
remove_corners -all
remove_modes -all
remove_scenarios -all
#remove_propagated_clocks [all_clocks]
#remove_propagated_clocks [get_ports]
#remove_propagated_clocks [get_pins -hierarchical]

create_corner slow
create_corner fast

read_parasitic_tech -tlup ${DESIGN_REF_PATH}/tech/starrc/saed32nm_1p9m_Cmin.tluplus -layermap ${DESIGN_REF_PATH}/tech/starrc/saed32nm_tf_itf_tluplus.map -name tlup_min

read_parasitic_tech -tlup ${DESIGN_REF_PATH}/tech/starrc/saed32nm_1p9m_Cmax.tluplus -layermap ${DESIGN_REF_PATH}/tech/starrc/saed32nm_tf_itf_tluplus.map -name tlup_max

set_parasitics_parameters \
	-early_spec tlup_max \
	-late_spec tlup_max \
	-early_temperature 125 \
	-late_temperature 125 \
	-corners {slow}

set_parasitics_parameters \
	-early_spec tlup_min \
	-late_spec tlup_min \
	-early_temperature -40 \
	-late_temperature -40 \
	-corners {fast}

create_mode func
current_mode func
create_scenario -mode func -corner fast -name func_fast
create_scenario -mode func -corner slow -name func_slow

current_scenario func_slow
read_sdc $Constraints_file

current_scenario func_fast
read_sdc $Constraints_file

set_scenario_status func_slow -none -setup true -hold false -leakage_power true -dynamic_power true -max_transition true -max_capacitance true -min_capacitance false -active true
set_scenario_status func_fast -none -setup false -hold true -leakage_power true -dynamic_power false -max_transition true -max_capacitance false -min_capacitance true -active true


## To remove duplicate modes, corners, scenarios, and to improve runtime and capacity without loss of constraints :
remove_duplicate_timing_contexts

# Grouping paths ---
group_path -name MACRO2REG -from [get_cells -physical_context -filter design_type==macro] -to [all_registers ]

group_path -name REG2MACRO -from [all_registers ] -to [get_cells -physical_context -filter design_type==macro]

group_path -name INPUTS -from [all_inputs ]

group_path -name OUTPUTS -to [all_outputs ]

group_path -name REG2REG -from [all_registers ] -to [all_registers ]

