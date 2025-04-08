
#########################################################
#                  3_export_design.tcl
#
# Description:  Export the design data
#
# Usage:        source in Oasys-RTL Command prompt
#
# Dependencies: init_design.tcl
#               1_load_design.tcl
#               2_synthesize_optimize.tcl
#               Launched from Oasys-RTL shell after
#               synthesis and optimization
#
#########################################################

#Check if dependent scripts have been loaded
if {![info exists top_module]} {
  source scripts/init_design.tcl
}

# Write results
write_db      ${output_dir}/odb/demo_chip.oasys_final.odb
write_verilog ${output_dir}/demo_chip.oasys_final.v
write_sdc     ${output_dir}/demo_chip.oasys_final.sdc
write_def     ${output_dir}/demo_chip.def
write_stil    ${output_dir}/demo_chip.stil
write_ctl     ${output_dir}/demo_chip.ctl

echo "\n-----------------------------"
echo "\nDesign data exported to output dir."
echo "\n-----------------------------\n"
