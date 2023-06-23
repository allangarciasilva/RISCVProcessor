set_global_assignment -entity "ProcessorPLL" -library "lib_ProcessorPLL" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "ProcessorPLL" -library "lib_ProcessorPLL" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "ProcessorPLL" -library "lib_ProcessorPLL" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_ProcessorPLL" -name SPD_FILE [file join $::quartus(sip_path) "ProcessorPLL.spd"]

set_global_assignment -library "lib_ProcessorPLL" -name MISC_FILE [file join $::quartus(sip_path) "ProcessorPLL_sim/ProcessorPLL.vho"]
