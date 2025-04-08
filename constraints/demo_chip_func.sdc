######################################################################
#   Design    : demo_chip
#     SDC timing constraint file
######################################################################
set clock_period        100.0 
set sysclk_multiplier   40
set usbclk_multiplier   6 
set clock_margin        0.20
set pad_load            10  
set transition          0.1
set io_clock_period     [ expr ${clock_period} / ${sysclk_multiplier} ]
set io_clock_period_ddr [ expr ${io_clock_period} / 2 ]

#  ------------------------------------------------------------------
#     Clock definitions
#  ------------------------------------------------------------------
# PLL input clock 10MHz
create_clock -name lfxt_clk -period ${clock_period} [ get_ports lfxt_clk ]

# Main system clock - 400MHz
create_generated_clock \
    -name sysclk \
    -source [ get_pins i_MAIN_PLL/REF ] \
    -multiply_by ${sysclk_multiplier} \
    -add -master_clock lfxt_clk \
    [ get_pins i_MAIN_PLL/PLLOUT ]

# USB clock - 60MHz
create_generated_clock \
    -name usbclk \
    -source [ get_pins i_USB_PLL/REF ] \
    -multiply_by ${usbclk_multiplier} \
    -add -master_clock lfxt_clk \
    [ get_pins i_USB_PLL/PLLOUT ]

# Scan mode clocks 
create_clock -name sysclk_byp -period ${clock_period} [ get_ports sysclk_byp ]
create_clock -name usbclk_byp -period ${clock_period} [ get_ports usbclk_byp ]

# Virtual clocks for I/O and DDR timing
create_clock -name vsysclk -period ${io_clock_period}
create_clock -name vsysclk_ddr -period ${io_clock_period_ddr}

# Apply uncertainties to clocks
set_clock_uncertainty -setup ${clock_margin} [ get_clocks sysclk ] 
set_clock_uncertainty -setup ${clock_margin} [ get_clocks usbclk ] 

#  ------------------------------------------------------------------
#     port timings
#  ------------------------------------------------------------------
set_input_delay 0.4 [get_ports usb_minus]
set_input_delay 0.4 [get_ports usb_plus]
set_input_delay  -clock vsysclk [ expr 0.4 *${io_clock_period}  ] \
    [ remove_from_collection [ all_inputs ] [ get_ports { lfxt_clk usb_plus usb_minus ddr*dq }] ]
set_output_delay -clock vsysclk [ expr 0.3 * ${io_clock_period} ] \
    [ remove_from_collection [ all_outputs ] [ get_ports { usb_plus usb_minus }] ]

# DDR input timings
set_input_delay  -clock vsysclk_ddr [ expr 0.4 * ${io_clock_period_ddr} ] \
        [ get_ports {  ddr*dq* }]

#  ------------------------------------------------------------------
#     external conditions
#  ------------------------------------------------------------------
set_load                ${pad_load}   [ all_outputs ]
set_input_transition    ${transition} [ all_inputs ]

#  ------------------------------------------------------------------
#     Exceptions
#  ------------------------------------------------------------------
# NMI and reset are asynchronous
set_false_path   -from [ get_ports nmi ]
set_false_path   -from [ get_ports reset_n ]

# Power up/down will take long time --> set false paths
set_false_path -through [  get_pins {nova0/power_control nova0/power_ack nova1/power_control nova1/power_ack i_usbf/*power_control i_usbf/*power_ack }]

# All clock domain crossings are async
set_clock_groups -asynchronous \
    -group lfxt_clk \
    -group sysclk   \
    -group usbclk

# Block scan clocks with case analysis
set_case_analysis 0 [get_ports scan_mode]
set_false_path -from SCAN_ENABLE

set_input_delay 0.7 [get_ports usb_minus]
set_input_delay 0.7 [get_ports usb_plus]
