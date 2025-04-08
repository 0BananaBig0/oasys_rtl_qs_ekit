
#########################################################
#                 2_synthesize_optimize.tcl
#
# Description:  Synthesize and optimize the 
#               DEMO CHIP and generate
#               the Oasys-RTL databases. 
#
# Usage:        source in Oasys-RTL Command prompt
#
# Dependencies: init_design.tcl
#               1_read_design.tcl
#               Launched from Oasys-RTL shell
#
#########################################################


#=======================================================#
#Check Status of Flow and load prior scripts if needed
#=======================================================#
set script_dir [file dirname [info script]]
set ekit_dir   [file dirname ${script_dir}]

#Check if dependent scripts have been loaded
if {![info exists top_module]} {
     source ${script_dir}/init_design.tcl
     source ${script_dir}/1_read_design.tcl
}
#=======================================================#
#Synthesize the DEMO CHIP RTL core
#=======================================================#

if {![file exists ${ekit_dir}/demo_chip_rtl/rtl/nova/trunk/src/Intra4x4_PredMode_decoding.v]} {
  puts "ERROR: RTL source files from OpenCores.org were not found.\n"
  puts "You can read a design database for a previously optimized design"
  puts "by running the following command:\n"
  puts "read_db ${ekit_dir}/demo_chip_rtl/demo_chip.odb\n\n"
  return
}

#Perform Synthesis
synthesize -module ${top_module} -map_to_scan -gate_clock

set_route_layer_max_usage metal2 0.5
set_route_layer_max_usage metal3 0.8
set_route_layer_max_usage metal6 0.8

write_db  ${output_dir}/odb/demo_chip.syn.odb

#=======================================================#
##Read constraints (logical and physical)
#=======================================================#
read_sdc -verbose $demo_chip_sdc_files 
#read_sdc -verbose constraints/cts_constraints.sdc 
report_design_metrics
check_timing

# Create User Path groups
group_path -name I2R -from [all_inputs]
group_path -name I2O -from [all_inputs] -to [all_outputs]
group_path -name R2O                    -to  [all_outputs]
report_path_groups

#=======================================================#
#Optimize for timing 
#=======================================================#
optimize -virtual
write_db  ${output_dir}/odb/demo_chip.virtual_opt.odb
report_timing
report_path_groups


######################################################################
# create_chip with appropriate bloackages for IO pads
######################################################################
redirect -file ${output_dir}/demo_chip.create_chip.log { create_chip   -bottom_clearance 30 -left_clearance 30 -right_clearance 30 -top_clearance 30 -utilization 60 }
set die [ exec cat ${output_dir}/demo_chip.create_chip.log | grep "create new die" | cut -c46-56 ]
set core [ expr $die - 30]

create_blockage -name  blk_top -type macro -left 0 -right $die -bottom $core -top $die
create_blockage -name  blk_bottom -type macro -left 0 -right $die -bottom 0 -top 30
create_blockage -name  blk_left  -type macro -left 0 -right 30 -bottom 0 -top $die
create_blockage -name  blk_right  -type macro -left $core -right $die -bottom 0 -top $die

#optimize for placement 
optimize -place
write_db  ${output_dir}/odb/demo_chip.placed_opt.odb
report_timing
report_path_groups

echo "\n-------------------------------------"
echo "\nSynthesis and optimization complete"
echo "\n-------------------------------------\n"
#=======================================================#	
#Perform DFT
#=======================================================#
if {[info exists dft_flow] && [string match $dft_flow tessent]} {
  puts "INFO::Running oasys Tessent DFT flow"
  source scripts/oasys_tessent_dft.tcl
  echo "\n-------------------------------------"
  echo "\n Tessent DFT complete"
  echo "\n-------------------------------------\n"
} elseif {[info exists dft_flow] && [string match $dft_flow oasys]} {
  puts "INFO::Running oasys native DFT flow"
  source scripts/oasys_dft.tcl
  report_scan_chains
  echo "\n-------------------------------------"
  echo "\n Oasys DFT complete"
  echo "\n-------------------------------------\n"
} else {
  puts "\nINFO:: 'dft_flow'  variable not set to 'tessent' or 'oasys'."
  puts "       skipping DFT flow. 'source' following script to run DFT"
  puts "       source ${ekit_dir}/scripts/oasys_dft.tcl"
  puts "       source ${ekit_dir}/scripts/oasys_tessent_dft.tcl"
}

#exit
