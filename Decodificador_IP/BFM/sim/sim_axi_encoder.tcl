# source sim_axi_encoder.tcl

set axi_encoder         /DUT
set axi_lite_adapter    $axi_encoder/axi_encoder_v1_0_S_AXI_inst
set axi_motor_enc       $axi_lite_adapter/Conexion_Encoder
set filtro              $axi_motor_enc/Conexion_Filtro_Digital
set prescaler           $filtro/Conexion_Prescaler
set FSM                 $axi_motor_enc/Conexion_FSM
set Posicion            $axi_motor_enc/Conexion_contador_posicion
set Cont_Periodo        $axi_motor_enc/Conexion_contador_periodo





quit -sim


vsim -voptargs=+acc -t 1ps work.axi_encoder_tb

set NumericStdNoWarnings 1
configure wave -signalnamewidth 1
configure wave -namecolwidth  160
#configure wave -valuecolwidth 100
configure wave -valuecolwidth 150

add wave -noupdate -divider {TESTBENCH}
add wave            /axi_aresetn
add wave            /axi_aclk

add wave -hex       /axi_awaddr
add wave            /axi_awprot
add wave            /axi_awvalid
add wave            /axi_awready

add wave -hex       /axi_wdata
add wave            /axi_wstrb
add wave            /axi_wvalid
add wave            /axi_wready

add wave            /axi_bresp
add wave            /axi_bvalid
add wave            /axi_bready

add wave -hex       /axi_araddr
add wave            /axi_arprot
add wave            /axi_arvalid
add wave            /axi_arready

add wave -hex       /axi_rdata
add wave            /axi_rresp
add wave            /axi_rvalid
add wave            /axi_rready



add wave -noupdate -divider {BFM}
add wave            /BFM/m_axi

add wave -noupdate -divider {AXI-LITE ADAPTER}
add wave              $axi_lite_adapter/S_AXI_ARESETN
add wave              $axi_lite_adapter/S_AXI_ACLK   
                                                   
add wave -hex         $axi_lite_adapter/S_AXI_AWADDR 
add wave              $axi_lite_adapter/S_AXI_AWPROT 
add wave              $axi_lite_adapter/S_AXI_AWVALID
add wave              $axi_lite_adapter/S_AXI_AWREADY
                                                   
add wave -hex         $axi_lite_adapter/S_AXI_WDATA  
add wave              $axi_lite_adapter/S_AXI_WSTRB  
add wave              $axi_lite_adapter/S_AXI_WVALID 
add wave              $axi_lite_adapter/S_AXI_WREADY 
                                                   
add wave              $axi_lite_adapter/S_AXI_BRESP  
add wave              $axi_lite_adapter/S_AXI_BVALID 
add wave              $axi_lite_adapter/S_AXI_BREADY 

add wave -hex         $axi_lite_adapter/S_AXI_ARADDR 
add wave              $axi_lite_adapter/S_AXI_ARPROT 
add wave              $axi_lite_adapter/S_AXI_ARVALID
add wave              $axi_lite_adapter/S_AXI_ARREADY
                                                   
add wave -hex         $axi_lite_adapter/S_AXI_RDATA  
add wave              $axi_lite_adapter/S_AXI_RRESP  
add wave              $axi_lite_adapter/S_AXI_RVALID 
add wave              $axi_lite_adapter/S_AXI_RREADY 


add wave -co yellow   $axi_lite_adapter/slv_reg_wren  
add wave -co magenta  $axi_lite_adapter/slv_reg_rden 

add wave -bin         $axi_lite_adapter/S_AXI_WSTRB;   #Señal de STROBE

add wave -bin         $axi_lite_adapter/enc_reset_pos; #Señal interna Reset_Position

add wave -hex         $axi_lite_adapter/slv_reg0
add wave -hex         $axi_lite_adapter/slv_reg1

add wave -uns         $axi_lite_adapter/reg_data_out;  #Valor Salida Lectura

add wave -noupdate -divider {DAC_CORE}

add wave              $axi_motor_enc/clk
add wave              $axi_motor_enc/rst

#Señal encoder entrada
add wave 		      $axi_motor_enc/CHA
add wave 	          $axi_motor_enc/CHB
#################################Filtro digital####################################################
#Señales Internas
add wave -uns         $prescaler/contador_100Hz
add wave 	          $prescaler/CE
#Señales de Salida
add wave              $filtro/CHA_out
add wave              $filtro/CHB_out

#################################FSM####################################################
add wave              $FSM/pos_cnt_en;  #Sañal de incremento del contador
add wave              $FSM/pos_cnt_dir; #Señal de direccion de giro
add wave              $FSM/cambio;      #Señal de deteccion de cambio de direccion

#################################Contador de Periodo####################################################
add wave -uns         $Cont_Periodo/obs_period
add wave              $Cont_Periodo/period_end

#################################Contador de Velocidad####################################################
add wave              $axi_motor_enc/reset_pos
add wave -uns         $Posicion/pos_cnt_i
add wave -uns         $axi_motor_enc/position

add wave -uns         $Posicion/speed_i
add wave -uns         $axi_motor_enc/speed
add wave -uns         $axi_lite_adapter/enc_speed

add wave              $Posicion/sped_vld_i
add wave              $axi_motor_enc/update

#################################Dentro del AXI####################################################
add wave              $axi_lite_adapter/interrupt_i
add wave              $axi_lite_adapter/interrupt_flag
add wave              $axi_lite_adapter/interrupt


set sim_time {200 us}

run $sim_time
