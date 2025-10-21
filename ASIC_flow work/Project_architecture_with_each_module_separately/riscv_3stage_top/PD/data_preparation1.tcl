
####### Setting Up Target & Link Libraries #############
source ./common_setup1.tcl

####### Creating library of the block ########
set DESIGN_REF_PATH "/home/student/24MVD1016_Thesis/Project4_3/riscv_3stage_top/PD/ref_32nm_ndm"
set link_library  $LINK_LIBRARY_FILES_CLG
set target_library $TARGET_LIBRARY_FILES_CLG

create_lib -ref_libs $NDM_REFERENCE_LIB_DIRS_CLG -technology $TECH_FILE ./lib

#read netlist
read_verilog ./riscv_core_top_netlist.v

#set current design -top level module name
current_design riscv_core_top
#linking library + netlist
link

save_lib -as post_import_design2


#defining attributes for metal layers -- HVH (preferable) or VHV 
define_user_attribute -type string -name routing_direction -classes routing_rule

#for horizontal 
set_attribute -objects [get_layers {M1 M3 M5 M7 M9}] -name routing_direction -value horizontal

#for vertical
set_attribute -objects [get_layers {M2 M4 M6 M8 MRDL}] -name routing_direction -value vertical


#reading TLU+ file ---max file
read_parasitic_tech -tlup ${DESIGN_REF_PATH}/tech/starrc/saed32nm_1p9m_Cmax.tluplus -layermap ${DESIGN_REF_PATH}/tech/starrc/saed32nm_tf_itf_tluplus.map  -name worst_para

#min file
read_parasitic_tech -tlup ${DESIGN_REF_PATH}/tech/starrc/saed32nm_1p9m_Cmin.tluplus -layermap ${DESIGN_REF_PATH}/tech/starrc/saed32nm_tf_itf_tluplus.map -name best_para

#reading the .sdc file 
source -e -v ./mcmm1.tcl


#save_block -as minsoc_data1
save_block -as import_done

save_lib

#close_blocks -force
#close_lib








