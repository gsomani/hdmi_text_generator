##Clock signal
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L11P_T1_SRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

##Buttons
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { rst }]; #IO_L20N_T3_34 Sch=BTN0
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { clear }]; #IO_L24N_T3_34 Sch=BTN1

##HDMI Signals
set_property -dict { PACKAGE_PIN H17   IOSTANDARD TMDS_33 } [get_ports clk_n]; #IO_L13N_T2_MRCC_35 Sch=HDMI_CLK_N
set_property -dict { PACKAGE_PIN H16   IOSTANDARD TMDS_33 } [get_ports clk_p]; #IO_L13P_T2_MRCC_35 Sch=HDMI_CLK_P
set_property -dict { PACKAGE_PIN D20   IOSTANDARD TMDS_33 } [get_ports { data_n[0] }]; #IO_L4N_T0_35 Sch=HDMI_D0_N
set_property -dict { PACKAGE_PIN D19   IOSTANDARD TMDS_33 } [get_ports { data_p[0] }]; #IO_L4P_T0_35 Sch=HDMI_D0_P
set_property -dict { PACKAGE_PIN B20   IOSTANDARD TMDS_33 } [get_ports { data_n[1] }]; #IO_L1N_T0_AD0N_35 Sch=HDMI_D1_N
set_property -dict { PACKAGE_PIN C20   IOSTANDARD TMDS_33 } [get_ports { data_p[1] }]; #IO_L1P_T0_AD0P_35 Sch=HDMI_D1_P
set_property -dict { PACKAGE_PIN A20   IOSTANDARD TMDS_33 } [get_ports { data_n[2] }]; #IO_L2N_T0_AD8N_35 Sch=HDMI_D2_N
set_property -dict { PACKAGE_PIN B19   IOSTANDARD TMDS_33 } [get_ports { data_p[2] }]; #IO_L2P_T0_AD8P_35 Sch=HDMI_D2_P

##Pmod Header JE
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { Col[0] }]; #IO_L4P_T0_34 Sch=JE1
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { Col[1] }]; #IO_L18N_T2_34 Sch=JE2
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { Col[2] }]; #IO_25_35 Sch=JE3
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { Col[3] }]; #IO_L19P_T3_35 Sch=JE4
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { Row[0] }]; #IO_L3N_T0_DQS_34 Sch=JE7
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { Row[1] }]; #IO_L9N_T1_DQS_34 Sch=JE8
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { Row[2] }]; #IO_L20P_T3_34 Sch=JE9
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { Row[3] }]; #IO_L7N_T1_34 Sch=JE10
