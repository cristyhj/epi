# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ENGINES_NUMBER" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ENGINE_MAX_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_PACKET_LENGTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TCQ" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.ENGINES_NUMBER { PARAM_VALUE.ENGINES_NUMBER } {
	# Procedure called to update ENGINES_NUMBER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENGINES_NUMBER { PARAM_VALUE.ENGINES_NUMBER } {
	# Procedure called to validate ENGINES_NUMBER
	return true
}

proc update_PARAM_VALUE.ENGINE_MAX_SIZE { PARAM_VALUE.ENGINE_MAX_SIZE } {
	# Procedure called to update ENGINE_MAX_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENGINE_MAX_SIZE { PARAM_VALUE.ENGINE_MAX_SIZE } {
	# Procedure called to validate ENGINE_MAX_SIZE
	return true
}

proc update_PARAM_VALUE.MAX_PACKET_LENGTH { PARAM_VALUE.MAX_PACKET_LENGTH } {
	# Procedure called to update MAX_PACKET_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_PACKET_LENGTH { PARAM_VALUE.MAX_PACKET_LENGTH } {
	# Procedure called to validate MAX_PACKET_LENGTH
	return true
}

proc update_PARAM_VALUE.TCQ { PARAM_VALUE.TCQ } {
	# Procedure called to update TCQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TCQ { PARAM_VALUE.TCQ } {
	# Procedure called to validate TCQ
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.MAX_PACKET_LENGTH { MODELPARAM_VALUE.MAX_PACKET_LENGTH PARAM_VALUE.MAX_PACKET_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_PACKET_LENGTH}] ${MODELPARAM_VALUE.MAX_PACKET_LENGTH}
}

proc update_MODELPARAM_VALUE.TCQ { MODELPARAM_VALUE.TCQ PARAM_VALUE.TCQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TCQ}] ${MODELPARAM_VALUE.TCQ}
}

proc update_MODELPARAM_VALUE.ENGINES_NUMBER { MODELPARAM_VALUE.ENGINES_NUMBER PARAM_VALUE.ENGINES_NUMBER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENGINES_NUMBER}] ${MODELPARAM_VALUE.ENGINES_NUMBER}
}

proc update_MODELPARAM_VALUE.ENGINE_MAX_SIZE { MODELPARAM_VALUE.ENGINE_MAX_SIZE PARAM_VALUE.ENGINE_MAX_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENGINE_MAX_SIZE}] ${MODELPARAM_VALUE.ENGINE_MAX_SIZE}
}

