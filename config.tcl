# User config
set ::env(DESIGN_NAME) ALU
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

##Comment this part if u don't wanna manually set the pins
#set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

##########################################################################################################################################
#GENERAL 
##########################################################################################################################################
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
##########################################################################################################################################
# CLOCK
##########################################################################################################################################
set ::env(CLOCK_PERIOD) {15}
set ::env(RUN_CTS) 1
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
set ::env(RT_MAXLAYER) {met4}
set ::env(RT_MINLAYER) {met1}
##########################################################################################################################################
#FLOW CONTROL 
##########################################################################################################################################
set ::env(RUN_DRT) 1
set ::env(RUN_CVC) 1
set ::env(LEC_ENABLE) 0

##########################################################################################################################################
#SYNTHESIS
##########################################################################################################################################
set ::env(SYNTH_STRATEGY) {AREA 3}
set ::env(MAX_FANOUT_CONSTRAINT) 100
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
##########################################################################################################################################
#Floorplanning
##########################################################################################################################################
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) {0 0 700 700}
set ::env(FP_CORE_UTIL) 35
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1
set ::env(FP_PDN_CHECK_NODES) 1
set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]

set ::env(FP_PDN_CORE_RING_VWIDTH) 3 
# The vertical sides width of the core rings
set ::env(FP_PDN_CORE_RING_HWIDTH) $::env(FP_PDN_CORE_RING_VWIDTH) 
# The horizontal sides width of the core rings
set ::env(FP_PDN_CORE_RING_VOFFSET) 14 
# The vertical sides offset from the design boundaries for the core rings
set ::env(FP_PDN_CORE_RING_HOFFSET) $::env(FP_PDN_CORE_RING_VOFFSET)
 # The horizontal sides offset from the design boundaries for the core rings
set ::env(FP_PDN_CORE_RING_VSPACING) 1.7 
# The vertical spacing between the core ring straps
set ::env(FP_PDN_CORE_RING_HSPACING) $::env(FP_PDN_CORE_RING_VSPACING) 
# The horizontal spacing between the core ring straps

set ::env(FP_PDN_VWIDTH) 3 
# The width of the vertical straps
set ::env(FP_PDN_HWIDTH) 3 
# The width of the horizontal straps
set ::env(FP_PDN_VOFFSET) 5 
# The vertical offset for the straps
set ::env(FP_PDN_HOFFSET) $::env(FP_PDN_VOFFSET) 
# The horizontal offset for the straps
set ::env(FP_PDN_VPITCH) 180 
# The pitch between the vertical straps
set ::env(FP_PDN_HPITCH) $::env(FP_PDN_VPITCH) 
# The pitch between the horizontal straps

set ::env(FP_PDN_VSPACING) [expr 5*$::env(FP_PDN_CORE_RING_VWIDTH)]
set ::env(FP_PDN_HSPACING) [expr 5*$::env(FP_PDN_CORE_RING_HWIDTH)]
set ::env(DECAP_CELL) "\
	sky130_fd_sc_hd__decap_3\
	sky130_fd_sc_hd__decap_4\
	sky130_fd_sc_hd__decap_6\
	sky130_fd_sc_hd__decap_8\
	sky130_fd_sc_hd__decap_12"

##########################################################################################################################################
#PLACEMENT
##########################################################################################################################################
set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) 0.55
#[expr 0.01*(1.5*($::env(FP_CORE_UTIL)))]
#0.45
set ::env(PL_TIME_DRIVEN) 0
set ::env(PL_ROUTABILITY_DRIVEN) 1
set ::env(PL_MAX_DISPLACEMENT_X) 75
set ::env(PL_MAX_DISPLACEMENT_Y) 60
set ::env(CELL_PAD) 4
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 1
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 1
set ::env(PL_RESIZER_HOLD_MAX_BUFFER_PERCENT) 40
set ::env(PL_RESIZER_SETUP_MAX_BUFFER_PERCENT) 60
set ::env(PL_RESIZER_ALLOW_SETUP_VIOS) 0
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.2
set ::env(PL_RESIZER_SETUP_SLACK_MARGIN) 0.1
set ::env(PL_RESIZER_MAX_WIRE_LENGTH) 180
set ::env(PL_RANDOM_GLB_PLACEMENT) 0
##########################################################################################################################################
#CTS
##########################################################################################################################################
set ::env(CTS_TARGET_SKEW) 150
set ::env(CTS_TOLERANCE) 25
set ::env(CTS_CLK_BUFFER_LIST)  {sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 }
#set ::env(CTS_CLK_BUFFER_LIST) "sky130fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(CTS_SINK_CLUSTERING_SIZE) 5
set ::env(CLOCK_BUFFER_FANOUT) 5
set ::env(CTS_CLK_MAX_WIRE_LENGTH) 60
##########################################################################################################################################
#ANTENNA DIODE
##########################################################################################################################################
set ::env(DIODE_PADDING) 2
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 3

##########################################################################################################################################
#DETAILED ROUTING
##########################################################################################################################################
set ::env(DRT_OPT_ITERS) 45
set ::env(ROUTING_CORES) 10
set ::env(DETAILED_ROUTER) tritonroute
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 1
