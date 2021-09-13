# source comp.tcl


#----

set ip_repo_path            "../../../Decodificador_IP"
set axi_encoder_path       "$ip_repo_path"
set bench_path              "../bench"



# IP:
# que no optimice -libreria vhdl 93 -libreria destino en la que se almacena
vcom -O0 -93 -work work       $axi_encoder_path/Filtro_digital_A.vhd
vcom -O0 -93 -work work       $axi_encoder_path/Filtro_digital_B.vhd
vcom -O0 -93 -work work       $axi_encoder_path/Prescaler.vhd
vcom -O0 -93 -work work       $axi_encoder_path/Filtro_Digital.vhd
vcom -O0 -93 -work work       $axi_encoder_path/Contador_Periodo.vhd
vcom -O0 -93 -work work       $axi_encoder_path/FSM.vhd
vcom -O0 -93 -work work       $axi_encoder_path/Contador_Posicion.vhd
vcom -O0 -93 -work work       $axi_encoder_path/axi_motor_enc.vhd

vcom -O0 -93 -work work       $axi_encoder_path/ip_repo/axi_encoder_1.0/hdl/axi_encoder_v1_0_S_AXI.vhd
vcom -O0 -93 -work work       $axi_encoder_path/ip_repo/axi_encoder_1.0/hdl/axi_encoder_v1_0.vhd

# BFM:
vcom -O0 -93 -work work       $bench_path/interfaces_pkg.vhd
vcom -O0 -93 -work work       $bench_path/m_axi_lite_expansor.vhd
vcom -O0 -93 -work work       $bench_path/m_axi_lite_bfm.vhd

# testbench:
vcom -O0 -93 -work work       $bench_path/axi_encoder_tb.vhd

