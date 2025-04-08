####################################################Read_RTL###########################################

set search_path "${demo_chip_rtl_dir}/rtl/mips32r1/trunk/Hardware/MIPS32_Standalone \
                 ${demo_chip_rtl_dir}/rtl/usb_phy/trunk/rtl/verilog \
                 ${demo_chip_rtl_dir}/rtl/usb/trunk/rtl/verilog \
                 ${demo_chip_rtl_dir}/rtl/nova/tags/Start/src \
                 ${demo_chip_rtl_dir}/rtl/nova/trunk/src \
                 ${demo_chip_rtl_dir}/rtl/demo_chip \
                 ${demo_chip_rtl_dir}/rtl/hpdmc/trunk/hpdmc_ddr32/rtl \
                 ${demo_chip_rtl_dir}/rtl/mem_wrapper \
                 ${demo_chip_rtl_dir}/rtl/lib_cells \
                 ${demo_chip_rtl_dir}/rtl/sondrel \
                 ${demo_chip_rtl_dir}/rtl/openmsp430 \
                 ${demo_chip_rtl_dir}/rtl/openmsp430/periph \
                 ${demo_chip_rtl_dir}/rtl/hpdmc/trunk/hpdmc_ddr32/rtl \
                 ${demo_chip_rtl_dir}/rtl/hpdmc/trunk/hpdmc_ddr32/rtl"

set rtl_list { cpu_sys.v
usb_sys.v
nova_defines.v 
BitStream_buffer.v 
BitStream_controller.v 
bitstream_gclk_gen.v 
BitStream_parser_FSM_gating.v 
bs_decoding.v 
cavlc_consumed_bits_decoding.v 
cavlc_decoder.v 
CodedBlockPattern_decoding.v 
dependent_variable_decoding.v 
DF_mem_ctrl.v 
DF_pipeline.v 
DF_reg_ctrl.v 
DF_top.v 
end_of_blk_decoding.v 
exp_golomb_decoding.v 
ext_RAM_ctrl.v 
heading_one_detector.v 
hybrid_pipeline_ctrl.v 
Inter_mv_decoding.v 
Inter_pred_CPE.v 
Inter_pred_LPE.v 
Inter_pred_pipeline.v 
Inter_pred_reg_ctrl.v 
Inter_pred_sliding_window.v 
Inter_pred_top.v 
Intra4x4_PredMode_decoding.v 
Intra_pred_PE.v 
Intra_pred_pipeline.v 
Intra_pred_reg_ctrl.v 
Intra_pred_top.v 
IQIT.v 
level_decoding.v 
nC_decoding.v 
nova.v 
NumCoeffTrailingOnes_decoding.v 
pc_decoding.v 
QP_decoding.v 
ram_async_1r_sync_1w.v 
ram_sync_1r_sync_1w.v 
rec_DF_RAM_ctrl.v 
rec_gclk_gen.v 
reconstruction.v 
run_decoding.v 
sum.v 
syntax_decoding.v 
total_zeros_decoding.v 
Add.v 
ALU.v 
Compare.v 
Control.v 
CPZero.v 
Divide.v 
EXMEM_Stage.v 
Hazard_Detection.v 
IDEX_Stage.v 
IFID_Stage.v 
MemControl.v 
MEMWB_Stage.v 
Mux2.v 
Mux4.v 
Processor.v 
RegisterFile.v 
Register.v 
TrapDetect.v 
usbf_crc16.v 
usbf_crc5.v 
usbf_defines.v 
usbf_ep_rf_dummy.v 
usbf_ep_rf.v 
usbf_idma.v 
usbf_mem_arb.v 
usbf_pa.v 
usbf_pd.v 
usbf_pe.v 
usbf_pl.v 
usbf_rf.v 
usbf_utmi_if.v 
usbf_utmi_ls.v 
usbf_wb.v 
usbf_top.v 
usb_phy.v 
usb_rx_phy.v 
usb_tx_phy.v 
hpdmc_banktimer.v 
hpdmc_busif.v 
hpdmc_ctlif.v 
hpdmc_datactl.v 
hpdmc_mgmt.v 
hpdmc.v 
spartan6/hpdmc_ddrio.v 
spartan6/hpdmc_iddr32.v 
spartan6/hpdmc_iobuf32.v 
spartan6/hpdmc_obuft4.v 
spartan6/hpdmc_oddr32.v 
spartan6/hpdmc_oddr4.v 
nova_wrapper.v 
demo_chip.v 
powerdown_control.v 
IOBUF.v 
MemGen_32_12.v 
MemGen_32_14.v 
ddr_alignment.v 
ddr_pad_lib.v 
demo_chip.v }
