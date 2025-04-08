set rtVersion [get_parameter version]

## remove all placement
delete_physical -all -verbose true
##  create a new rectilinear die given a list of points
create_chip -points {{0  0} {0  700} {700  700} {700  1600} {2500  1600} {2500  0} } -overwrite true -verbose true
report_design_metrics
#optimize -place
