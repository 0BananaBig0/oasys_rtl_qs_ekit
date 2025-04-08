###POWER PLANNING####
##Make PG rails and stripes and connect macros to the power pins##

create_supply_net -net_name VDD -power_net true 
create_supply_net -net_name VSS -power_net false

connect_supply_net VDD -pins [get_pins *vdd* ] 
connect_supply_net VSS -pins [get_pins *gnd* ] 

## Adding Power Structure
remove_routing  -route_types pre_route

create_pg_rings -partitions "demo_chip" -nets "VDD VSS" -window false -layers { metal9 metal10 } -widths { 45000a 50000a } -step 32000a -spacing 15000a -offset { 165000a 165000a 165000a 165000a } -keep_pattern all -bridge_pattern single -ignore_blockages { placement } -check_drc { all } -measure_from edge -corner_style concentric -insert_vias true -location auto

create_pg_stripes -partitions "demo_chip" -nets "VDD VSS" -window false -layer metal10 -widths { 80000a 80000a } -step 500000a -spacing 20000a -direction vertical -offset { 500000a 500000a } -margin { 300000a 300000a } -measure_from center_line -keep_pattern false -ignore_blockages { placement } -check_drc { all }

create_pg_stripes -partitions "demo_chip" -nets "VDD VSS" -window false -layer metal9 -widths { 80000a 80000a } -step 500000a -spacing 20000a -direction horizontal -offset { 500000a 500000a } -margin { 300000a 300000a } -measure_from center_line -keep_pattern false -ignore_blockages { placement } -check_drc { all }

insert_pg_vias -nets {VDD VSS} -layers {metal9 metal10} -extend true -from_type stripe -to_type ring
insert_pg_vias -nets {VDD VSS} -from_type stripe -to_type stripe -layers {metal9 metal10}

create_pg_stripes -partitions "demo_chip" -nets "VDD VSS" -window false -layer metal4 -widths { 40000a 40000a } -step 500000a -spacing 20000a -direction vertical -offset { 800000a 800000a } -margin { 300000a 300000a } -measure_from center_line -keep_pattern false -ignore_blockages { placement } -check_drc { all }

insert_pg_vias -nets {VDD VSS} -from_type stripe -to_type stripe -layers {metal9 metal4}  -extend true 
insert_pg_vias -nets {VDD VSS} -from_type ring -to_type stripe -layers {metal9 metal4}  -extend true 

create_pg_rails -partitions "demo_chip" -nets "VDD VSS" -window false -sites "FreePDK45_38x28_10R_NP_162NW_34O" -ignore_blockages { none }
insert_pg_vias -from_type stripe -to_type rail -layers {metal1 metal4}

insert_pg_vias -nets {VDD VSS} -layers {metal6 metal10} -from_type stripe -to_type macro_port
insert_pg_vias -nets {VDD VSS} -layers {metal4 metal5} -from_type stripe -to_type macro_port 


####################Check DRC####################
check_drc  -only false 
clean_drc -force
check_drc -with_pre_route
