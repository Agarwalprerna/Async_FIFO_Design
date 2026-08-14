#=========================================================
# DESIGN
#=========================================================
current_design asyncfifo

#=========================================================
# CLOCK DEFINITIONS
#=========================================================
create_clock -name wclk -period 50 [get_ports wclk]
create_clock -name rclk -period 50 [get_ports rclk]

set_propagated_clock [get_clocks wclk]
set_propagated_clock [get_clocks rclk]

#=========================================================
# ASYNCHRONOUS CLOCK DOMAINS
#=========================================================
set_clock_groups -asynchronous \
    -group {wclk} \
    -group {rclk}

#=========================================================
# CLOCK TRANSITION (SLEW)
#=========================================================
set_clock_transition 0.1 [get_clocks wclk]
set_clock_transition 0.1 [get_clocks rclk]

#=========================================================
# CLOCK SOURCE LATENCY
#=========================================================
set_clock_latency -source 1.0 [get_clocks wclk]
set_clock_latency -source 1.0 [get_clocks rclk]

#=========================================================
# CLOCK UNCERTAINTY
#=========================================================
set_clock_uncertainty 0.2 [get_clocks wclk]
set_clock_uncertainty 0.2 [get_clocks rclk]

#=========================================================
# INPUT DELAYS
#=========================================================
set_input_delay 2.0 -clock wclk \
  [get_ports {we re din[*]}]

#=========================================================
# OUTPUT DELAYS
#=========================================================
set_output_delay 2.0 -clock wclk [all_outputs]
