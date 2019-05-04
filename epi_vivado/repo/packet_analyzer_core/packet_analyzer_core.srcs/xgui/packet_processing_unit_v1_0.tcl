# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_M_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_ARUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_AWUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_BURST_LEN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_BUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_RUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_THREAD_ID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_WUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ARUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_AWUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_BUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RNG00_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RNG00_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RNG01_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RNG01_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RNG02_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RNG02_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RNG03_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RNG03_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_WUSER_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_M_AXI_ADDR_WIDTH { PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to update C_M_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ADDR_WIDTH { PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_M_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_ARUSER_WIDTH } {
	# Procedure called to update C_M_AXI_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_ARUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_AWUSER_WIDTH } {
	# Procedure called to update C_M_AXI_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_AWUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_BURST_LEN { PARAM_VALUE.C_M_AXI_BURST_LEN } {
	# Procedure called to update C_M_AXI_BURST_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_BURST_LEN { PARAM_VALUE.C_M_AXI_BURST_LEN } {
	# Procedure called to validate C_M_AXI_BURST_LEN
	return true
}

proc update_PARAM_VALUE.C_M_AXI_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_BUSER_WIDTH } {
	# Procedure called to update C_M_AXI_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_BUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_DATA_WIDTH { PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_DATA_WIDTH { PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_RUSER_WIDTH } {
	# Procedure called to update C_M_AXI_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_RUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH { PARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH } {
	# Procedure called to update C_M_AXI_THREAD_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH { PARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_THREAD_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_WUSER_WIDTH } {
	# Procedure called to update C_M_AXI_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_WUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ARUSER_WIDTH { PARAM_VALUE.C_S_AXI_ARUSER_WIDTH } {
	# Procedure called to update C_S_AXI_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ARUSER_WIDTH { PARAM_VALUE.C_S_AXI_ARUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_AWUSER_WIDTH { PARAM_VALUE.C_S_AXI_AWUSER_WIDTH } {
	# Procedure called to update C_S_AXI_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_AWUSER_WIDTH { PARAM_VALUE.C_S_AXI_AWUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BUSER_WIDTH { PARAM_VALUE.C_S_AXI_BUSER_WIDTH } {
	# Procedure called to update C_S_AXI_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BUSER_WIDTH { PARAM_VALUE.C_S_AXI_BUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ID_WIDTH { PARAM_VALUE.C_S_AXI_ID_WIDTH } {
	# Procedure called to update C_S_AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ID_WIDTH { PARAM_VALUE.C_S_AXI_ID_WIDTH } {
	# Procedure called to validate C_S_AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RNG00_BASEADDR { PARAM_VALUE.C_S_AXI_RNG00_BASEADDR } {
	# Procedure called to update C_S_AXI_RNG00_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RNG00_BASEADDR { PARAM_VALUE.C_S_AXI_RNG00_BASEADDR } {
	# Procedure called to validate C_S_AXI_RNG00_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RNG00_HIGHADDR { PARAM_VALUE.C_S_AXI_RNG00_HIGHADDR } {
	# Procedure called to update C_S_AXI_RNG00_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RNG00_HIGHADDR { PARAM_VALUE.C_S_AXI_RNG00_HIGHADDR } {
	# Procedure called to validate C_S_AXI_RNG00_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RNG01_BASEADDR { PARAM_VALUE.C_S_AXI_RNG01_BASEADDR } {
	# Procedure called to update C_S_AXI_RNG01_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RNG01_BASEADDR { PARAM_VALUE.C_S_AXI_RNG01_BASEADDR } {
	# Procedure called to validate C_S_AXI_RNG01_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RNG01_HIGHADDR { PARAM_VALUE.C_S_AXI_RNG01_HIGHADDR } {
	# Procedure called to update C_S_AXI_RNG01_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RNG01_HIGHADDR { PARAM_VALUE.C_S_AXI_RNG01_HIGHADDR } {
	# Procedure called to validate C_S_AXI_RNG01_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RNG02_BASEADDR { PARAM_VALUE.C_S_AXI_RNG02_BASEADDR } {
	# Procedure called to update C_S_AXI_RNG02_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RNG02_BASEADDR { PARAM_VALUE.C_S_AXI_RNG02_BASEADDR } {
	# Procedure called to validate C_S_AXI_RNG02_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RNG02_HIGHADDR { PARAM_VALUE.C_S_AXI_RNG02_HIGHADDR } {
	# Procedure called to update C_S_AXI_RNG02_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RNG02_HIGHADDR { PARAM_VALUE.C_S_AXI_RNG02_HIGHADDR } {
	# Procedure called to validate C_S_AXI_RNG02_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RNG03_BASEADDR { PARAM_VALUE.C_S_AXI_RNG03_BASEADDR } {
	# Procedure called to update C_S_AXI_RNG03_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RNG03_BASEADDR { PARAM_VALUE.C_S_AXI_RNG03_BASEADDR } {
	# Procedure called to validate C_S_AXI_RNG03_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RNG03_HIGHADDR { PARAM_VALUE.C_S_AXI_RNG03_HIGHADDR } {
	# Procedure called to update C_S_AXI_RNG03_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RNG03_HIGHADDR { PARAM_VALUE.C_S_AXI_RNG03_HIGHADDR } {
	# Procedure called to validate C_S_AXI_RNG03_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RUSER_WIDTH { PARAM_VALUE.C_S_AXI_RUSER_WIDTH } {
	# Procedure called to update C_S_AXI_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RUSER_WIDTH { PARAM_VALUE.C_S_AXI_RUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_WUSER_WIDTH { PARAM_VALUE.C_S_AXI_WUSER_WIDTH } {
	# Procedure called to update C_S_AXI_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_WUSER_WIDTH { PARAM_VALUE.C_S_AXI_WUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_WUSER_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AWUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_AWUSER_WIDTH PARAM_VALUE.C_M_AXI_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ARUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_ARUSER_WIDTH PARAM_VALUE.C_M_AXI_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_WUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_WUSER_WIDTH PARAM_VALUE.C_M_AXI_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_RUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_RUSER_WIDTH PARAM_VALUE.C_M_AXI_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_BUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_BUSER_WIDTH PARAM_VALUE.C_M_AXI_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH PARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_THREAD_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_BURST_LEN { MODELPARAM_VALUE.C_M_AXI_BURST_LEN PARAM_VALUE.C_M_AXI_BURST_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_BURST_LEN}] ${MODELPARAM_VALUE.C_M_AXI_BURST_LEN}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RNG00_BASEADDR { MODELPARAM_VALUE.C_S_AXI_RNG00_BASEADDR PARAM_VALUE.C_S_AXI_RNG00_BASEADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RNG00_BASEADDR}] ${MODELPARAM_VALUE.C_S_AXI_RNG00_BASEADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RNG00_HIGHADDR { MODELPARAM_VALUE.C_S_AXI_RNG00_HIGHADDR PARAM_VALUE.C_S_AXI_RNG00_HIGHADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RNG00_HIGHADDR}] ${MODELPARAM_VALUE.C_S_AXI_RNG00_HIGHADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RNG01_BASEADDR { MODELPARAM_VALUE.C_S_AXI_RNG01_BASEADDR PARAM_VALUE.C_S_AXI_RNG01_BASEADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RNG01_BASEADDR}] ${MODELPARAM_VALUE.C_S_AXI_RNG01_BASEADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RNG01_HIGHADDR { MODELPARAM_VALUE.C_S_AXI_RNG01_HIGHADDR PARAM_VALUE.C_S_AXI_RNG01_HIGHADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RNG01_HIGHADDR}] ${MODELPARAM_VALUE.C_S_AXI_RNG01_HIGHADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RNG02_BASEADDR { MODELPARAM_VALUE.C_S_AXI_RNG02_BASEADDR PARAM_VALUE.C_S_AXI_RNG02_BASEADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RNG02_BASEADDR}] ${MODELPARAM_VALUE.C_S_AXI_RNG02_BASEADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RNG02_HIGHADDR { MODELPARAM_VALUE.C_S_AXI_RNG02_HIGHADDR PARAM_VALUE.C_S_AXI_RNG02_HIGHADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RNG02_HIGHADDR}] ${MODELPARAM_VALUE.C_S_AXI_RNG02_HIGHADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RNG03_BASEADDR { MODELPARAM_VALUE.C_S_AXI_RNG03_BASEADDR PARAM_VALUE.C_S_AXI_RNG03_BASEADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RNG03_BASEADDR}] ${MODELPARAM_VALUE.C_S_AXI_RNG03_BASEADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RNG03_HIGHADDR { MODELPARAM_VALUE.C_S_AXI_RNG03_HIGHADDR PARAM_VALUE.C_S_AXI_RNG03_HIGHADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RNG03_HIGHADDR}] ${MODELPARAM_VALUE.C_S_AXI_RNG03_HIGHADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ID_WIDTH { MODELPARAM_VALUE.C_S_AXI_ID_WIDTH PARAM_VALUE.C_S_AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ID_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_AWUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_AWUSER_WIDTH PARAM_VALUE.C_S_AXI_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ARUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_ARUSER_WIDTH PARAM_VALUE.C_S_AXI_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_WUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_WUSER_WIDTH PARAM_VALUE.C_S_AXI_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_RUSER_WIDTH PARAM_VALUE.C_S_AXI_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_BUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_BUSER_WIDTH PARAM_VALUE.C_S_AXI_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_BUSER_WIDTH}
}

