if {[info exists tessent_build] && [string match $dft_flow tessent]} {
    puts "INFO::using $tessent_build build to run the Tessent DFT flow"
  } else {
    puts "ERROR::To run the tessent DFT flow, Please set the "tessent build" variable in script/init_design.tcl"
    return 0 
  }

#=======================================================#
#Define dft settings
#=======================================================#
define_test_pin -pin scan_mode_pad/C -scan 1 -default_scan_enable
define_test_pin -pin scan_mode -scan 1
define_test_pin -pin reset_n_pad/C -scan 1 
define_test_pin -pin nova0/reset_n_sync_reg/Q -scan 1
define_test_pin -pin nova1/reset_n_sync_reg/Q -scan 1
define_test_clock -pin nova1/clk
define_test_clock -pin nova0/clk
define_test_clock -pin usbclk_byp
define_test_clock -pin sysclk_byp

connect_clock_gating_test_pin -test_pin scan_mode_pad/C

#Check the DFT violation and use autofix feature to adress them
check_dft -auto_test_clock -auto_test_pins

#=======================================================#
# Pre fix_dft_violation database
#=======================================================#
write_db  ${output_dir}/odb/demo_chip.tessent_pre_fix.odb

fix_dft_violations -type all -test_clock sysclk_byp -test_control scan_mode_pad/C
check_dft
report_dft_violations

#=======================================================#
#Final optimize
#=======================================================#
optimize 
write_db      ${output_dir}/odb/demo_chip.tessent_post_fix.odb
write_verilog ${output_dir}/demo_chip.tessent_post_fix.v
report_timing
report_endpoints
report_power
report_path_groups

#========================================================#
# Formalpro verification command
#========================================================#

#verify ${output_dir}/verilog/post_optimize.v -base_directory post_optimize


#=======================================================#
# configuring Tessent build
#=======================================================#
#Specify the path to Tessent exec.

config_tessent -exec_path $tessent_build

#=======================================================#
# Tessent TPI
#=======================================================#

set fastscan_path "${ekit_dir}/libs/fastscan"
config_tessent -ignore_clock_gating "on"
set lib_list [glob -nocomplain $fastscan_path/*.fslib ]
config_tessent -library $lib_list
config_tessent_tpi  -total_number 2% -control_point_enable control_test_point_en -observe_point_enable observe_test_point_en

run_tessent_tpi

#========================================================#
# Formalpro verification command
#========================================================#

#verify ${output_dir}/verilog/post_tpi.v -base_directory post_tpi


#=======================================================#
# Tessent SCAN 
#=======================================================#
check_dft
for {set i 1} {$i < 5} {incr i} {
    define_scan_chain -scan_in SI_$i -scan_out SO_$i  -create_port
 }

run_tessent_scan

write_db      ${output_dir}/odb/demo_chip.tessent_post_scan.odb
write_verilog ${output_dir}/demo_chip.tessent_post_scan.v
report_power
report_path_groups
report_scan_chains

#========================================================#
#Formalpro verification command
#========================================================#

#verify ${output_dir}/verilog/post_dft.v -base_directory post_dft



