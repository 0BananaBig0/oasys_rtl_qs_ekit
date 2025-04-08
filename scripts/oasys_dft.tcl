#=======================================================#
#Enable shift registers identification
#=======================================================#
infer_shift_registers

#=======================================================#
#Define dft settings
#=======================================================#
define_test_pin -pin SCAN_ENABLE -scan 1 -default_scan_enable -create_port
define_test_pin -pin scan_mode -scan 1
define_test_clock -pin sysclk_byp -test_domain A
connect_clock_gating_test_pin -test_pin SCAN_ENABLE

#Check the DFT violation and use autofix feature to adress them
check_dft -auto_test_clock -auto_test_pins
report_dft_violations

#=======================================================#
# Pre fix_dft_violation database
#=======================================================#
write_db ${output_dir}/odb/demo_chip.oasysdft_pre_fix.odb

fix_dft_violations -type all -test_clock sysclk_byp -test_control scan_mode
check_dft
report_dft_violations

#=======================================================#
#Disable scan on enable_nova0_reg & enable_nova1_reg
#=======================================================#
set_dont_scan -verbose [get_cell  enable_nova0_reg] true
set_dont_scan -verbose [get_cell  enable_nova1_reg] true

#=======================================================#
#Final optimize
#=======================================================#
optimize 
write_db ${output_dir}/odb/demo_chip.oasysdft_post_fix.odb
write_verilog ${output_dir}/demo_chip.oasysdft_post_fix.v
report_timing
report_endpoints
report_power
report_path_groups


### Using partitioned based DFT Flow

# Should report 'default' as current dft partition
current_dft_partition

# Define DFT partitions 
define_dft_partition P1 -instances {i_cpu_sys nova1}
define_dft_partition P2 -instances { nova0}


report_dft_partitions

## define_scan_chain 
define_scan_chain -scan_in SI_1 -scan_out SO_1 -create_port -partition P1

current_dft_partition P2
# following definition scope is limited to P2
define_scan_chain -scan_in SI_2 -scan_out SO_2 -create_port

# Resetting the partition definition to 'Default'
reset_dft_partition

# Following scan chains should be created corresponding to 'Default' partition, meaning any logic outside of already coverd partitions.
define_scan_chain -scan_in SI_3 -scan_out SO_3 -create_port

#connect_scan_chains
connect_scan_chains -physical -mix_clock_edges

