
#########################################################
#                 1_load_design.tcl
#
# Description:  Load the design input files into
#               Oasys-RTL and set design
#               conditions. Must be run after the
#               init_design.tcl script
#
# Usage:        source in Oasys-RTL Command prompt
#
# Dependencies: init_design.tcl
#               Launched from Oasys-RTL shell
#
#########################################################

set script_dir [file dirname [info script]]
set ekit_dir   [file dirname ${script_dir}]

#Check if dependent scripts have been loaded
if {![info exists top_module]} {
  source ${script_dir}/init_design.tcl
}

#=======================================================#
#Load technology libraries (Liberty and LEF)
#=======================================================#

# Read Oasys libraries (ODB)
read_db ${ekit_dir}/libs/nangate_mvt.odb
foreach vt [list hvt svt lvt] {
  set vtUC [string toupper $vt]
  set lib_cells(${vt}) [get_lib_cells *${vtUC}*]
  if { [sizeof_collection $lib_cells(${vt})] > 0 } {
    create_threshold_voltage_group ${vtUC} -lib_cells $lib_cells($vt)
  }
}
report_operating_conditions

#=======================================================#
#Config the tolerance level for RTL parser for elobration
#=======================================================#

config_tolerance -blackbox true -connection_mismatch true \
        -missing_physical_library true \
        -continue_on_error false

#=======================================================#
#Read verilog design files
#=======================================================#

if {[file exists ${ekit_dir}/demo_chip_rtl/rtl/nova/trunk/src/Intra4x4_PredMode_decoding.v]} {
  read_verilog $rtl_list  -include $search_path
}

#=======================================================#
#Set design-specific parameters before synthesis
#=======================================================#

#Set the max routing layer (defined in 1_init_design.tcl)
set_max_route_layer $max_route_layer  				

#Reset dont_use property on all lib cells
set_dont_use [get_lib_cell * ] false 				

#Specify clock gating options
set_clock_gating_options -control_point before \
	-minimum_bitwidth 4 -sequential_cell latch 			

echo "\n-----------------------------"
echo "\nDone preparing design for synthesis"
echo "\n-----------------------------\n"
