
#########################################################
#                 dse_base.tcl
#
# Description:  Sets up the design for exploration
#
#
# Usage:        source in Oasys-RTL Command prompt
#
# Dependencies: init_design.tcl
#
#########################################################

#Initialize script parameters
source scripts/init_design.tcl

#Disable warning messages
message -enable false TA-116
message -enable false LIB-136
message -enable false LIB-114
message -enable false NL-138
message -enable false NL-120


#Read logical libraries
foreach lib $high_vt_libs {
    read_library $lib -target_library high_vt
}
foreach lib $low_vt_libs {
    read_library $lib -target_library low_vt
}
read_lef $tech_file

foreach lef $lef_files {
    read_lef $lef
}

#Specify the target liberty library
set_target_library high_vt

set_dont_use [get_lib_cell * ] false


#Read the verilog files for the core
read_verilog $rtl_list  -include $search_path

#Synthesize the top module
synthesize -module ${top_module} -map_to_scan -gate_clock

# constraints: 1.5ns clock
read_sdc -verbose $demo_chip_sdc_files

#insert clk explorer here

#Optimize
optimize -virtual
report_clocks
report_power
report_design_metrics

