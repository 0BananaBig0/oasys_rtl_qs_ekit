#########################################################
#                 open_database.tcl
#
# Description:  Load the generated Oasys-RTL databases (.odb)
#               into the tool
#
# Usage:        source in Oasys-RTL Command prompt
#
# Dependencies: 1_init_design.tcl
#               Existing odb created from the 
#               Launched from Oasys-RTL shell
#
#########################################################

# Check if dependent scripts have been loaded
if {![info exists top_module]} {
  source scripts/init_design.tcl
}

# Read existing Oasys-RTL database (design and libraries)	
if {[file exists ${ekit_dir}/output/odb/demo_chip.oasys_final.odb]} {
  puts "Using ODB from output directory" 
  read_db ${ekit_dir}/output/odb/demo_chip.oasys_final.odb
} elseif {[file exists ${ekit_dir}/demo_chip_rtl/demo_chip.odb]} {
  puts "Using pre-defined ODB from demo_chip_rtl directory" 
  read_db ${ekit_dir}/demo_chip_rtl/demo_chip.odb
} else {
  puts "unable to locate ODB file for demo_chip design" 
}

# Report DFT if scan chains exist
if { [get_scan_chains] > 0 } {
  check_dft
  report_scan_chains
}

# Report design	
puts "Running timing reports..."
report_path_groups
report_timing

