# Enable capture of commands
 config_shell -echo true

###################Top Module Specification###########
set top_module "demo_chip"
set max_route_layer "10"

#Set design file path variables
set script_dir [file dirname [info script]]
set ekit_dir   [file dirname ${script_dir}]
set demo_chip_rtl_dir "${ekit_dir}/demo_chip_rtl"
set demo_chip_sdc_files "${ekit_dir}/constraints/demo_chip_func.sdc"
set output_dir "${ekit_dir}/output"

##set a consistant reporting format for timing
config_report timing -format "cell edge arrival delay arc_delay net_delay slew net_load load fanout location power_domain"

# Set DFT flow settings 
# To run the tessent DFT flow, please set the dft_flow variable to "tessent" from "oasys" and update tessent_build path 
# set dft_flow "oasys"
# set tessent_build $env(TESSENT)/bin/tessent

#Source the script that sets the path variables for all input files
source ${script_dir}/demo_chip_design_files.tcl

echo "\n-----------------------------"
echo "\nDone setting design variables"
echo "\n-----------------------------\n"

