set script_dir [file dirname [info script]]
set ekit_dir   [file normalize [file dirname ${script_dir}]]
set libs_dir   ${ekit_dir}/nangate/libs
set lefs_dir   ${ekit_dir}/nangate/lefs
puts "Base Dir: ${ekit_dir}"


#set lib(io)  "${libs_dir}/lib_WCLCOM_ss_0p95v/LowPowerOpenCellLibrary_worst_low_ccs.lib  \
#              ${libs_dir}/lib_WCLCOM_ss_0p95v/NangateOpenCellLibrary_worst_low_ccs.lib 
set lib(io)  "${libs_dir}/IO.lib \
              ${libs_dir}/PLL.lib \
              ${libs_dir}/MemGen_16_10.lib"

set lib(hvt) "${libs_dir}/lib_WCLCOM_ss_0p85v/0p85/NangateOpenCellLibrary_45nm_HVT_worst_low_0p85V_conditional_nldm.lib \
              ${libs_dir}/lib_WCLCOM_ss_0p95v/0p95/NangateOpenCellLibrary_45nm_HVT_worst_low_conditional_nldm.lib"

set lib(svt) "${libs_dir}/lib_WCLCOM_ss_0p85v/0p85/NangateOpenCellLibrary_45nm_SVT_slow_0p85V_conditional_nldm.lib  \
              ${libs_dir}/lib_WCLCOM_ss_0p95v/0p95/NangateOpenCellLibrary_45nm_SVT_worst_low_conditional_nldm.lib"

set lib(lvt) "${libs_dir}/lib_WCLCOM_ss_0p85v/0p85/NangateOpenCellLibrary_45nm_LVT_slow_0p85V_conditional_nldm.lib \
              ${libs_dir}/lib_WCLCOM_ss_0p95v/0p95/NangateOpenCellLibrary_45nm_LVT_worst_low_conditional_nldm.lib"

#Specify the Physical libraries
set lef(io)  "${lefs_dir}/IO.lef \
              ${lefs_dir}/PLL.lef \
              ${lefs_dir}/MemGen_16_10.lef "
#              ${lefs_dir}/NangateOpenCellLibrary.macro.lef"
set lef(hvt)  ${lefs_dir}/NangateOpenCellLibrary_HVT.macro.lef
set lef(svt)  ${lefs_dir}/NangateOpenCellLibrary_SVT.macro.lef
set lef(lvt)  ${lefs_dir}/NangateOpenCellLibrary_LVT.macro.lef

#################################################
### Build the library ODB
#################################################
read_lef ${lefs_dir}/tech_lef/NangateOpenCellLibrary.tech.lef
read_ptf -temperature 0 ${ekit_dir}/nangate/ptf/NCSU_FreePDK_45nm.ptf
foreach vt [list io hvt svt lvt] {
  puts "processing ${vt}... " 
  read_library  $lib(${vt})
  read_lef $lef(${vt})
}
write_db -data library ${ekit_dir}/libs/nangate_mvt.odb
puts "wrote ${vt}: ${libs_dir}/libs/nangate_mvt.odb" 

