//PIPS_SetPropertyDevice("subsystem_imaging", "device_shutter", "set_position", "1")   //closed  doesn't work
//PIPS_SetPropertyDevice("subsystem_imaging", "device_shutter", "set_position", "1")   //open   doesn't work

//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "1")  // works, enable top illuminator on=1, off=0
//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "1")  // works, activate top illuminator on=1, off=0

//string stagepos
//PIPS_GetPropertySubsystem("subsystem_pumping", "read_stage_position",  stagepos)  // works (but always returns 1) read stage location: 0=?, 1=up, 2=down
//result(stagepos + " =stage location (0=?, 1=up, 2=down)\n")


// ** stage functions
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "5")  // works,  stage to left front
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "6")  // works,  stage to left rear
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "8")  // works,  stage to right rear
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_custom_angle_deg10", "2700")  // works, set custom align angle
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "4")  // works, go to custom align angle
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_speed_RPM", "3")  // , set stage RPM
//string value
//PIPS_GetPropertyDevice("subsystem_milling", "device_stage", "read_stage_pos_deg10", value)  // ,  read stage angle in .1 degs
//result("stage angle in .1 degs = " + value + "\n")

// ** Vacuum and valve functions
//string torr
//PIPS_GetPropertyDevice("subsystem_pumping", "device_backingGauge", "read_pressure_Torr", Torr)  // works, read backing pressure in Torr
//PIPS_GetPropertyDevice("subsystem_pumping", "device_coldCathodGauge", "read_pressure_Torr", Torr)  // need to test, read CC gauge pressure in Torr
//result(torr + " Torr\n")
//string value
//PIPS_GetPropertyDevice("subsystem_pumping", "device_valveWhisperlok", "set_active", value) //works? read state of valve (what it's set to)
//PIPS_GetPropertyDevice("subsystem_pumping", "device_valveLoadLock", "set_active", value)   //works? read state of valve (what it's set to)
//PIPS_GetPropertyDevice("subsystem_pumping", "device_valveVent", "set_active", value)       //works? read state of valve (what it's set to)
//PIPS_GetPropertyDevice("subsystem_pumping", "device_valveVacuum", "set_active", value)     //works? read state of valve (what it's set to)
//result(value + "\n")

// **  system functions
//string answer
//PIPS_GetPropertySystem("read_process_activity", answer)       //works, reads process activity
   // 0=none, 1=initializing, 2=stabilizing, 3=rotating stage, 4=aligning, 5=milling, 6=calibrating, 7=lowering stage
   // 8=raising stage, 9=cold delay, 10=pumping, 11=venting, 12=finalizing, 13=paused, 14=resuming
//PIPS_GetPropertySystem("ready", answer)       // works returns true or false
//PIPS_GetPropertySystem("activeProcess", answer)       // works
  //0=reset, 1=home, 2=mill, 3=align, 4=vent chamber, 5=pump chamber, 6=stage lower, 7=stage raise, 8=gas calibrate, 9=recipe mill
//result(answer + " \n")



// ** CPLD functions  (only use as last resort, the UI will not know about any changes made with these functions)
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_01", "1")   //works set buzzer control
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_02", "1")   //works set CC gauge power
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_03", "1")   //works set  CSO valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_04", "1")   //works set  DP control
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_05", "1")   //works set  DP speed
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_06", "1")   //works set  AG valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_07", "1")   //works set  SO valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_08", "1")   //works set  SI valve
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_09", "1")   //works set  WL valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_10", "1")   //works set  LL valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_11", "1")   //works set  Vent valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_12", "1")   //works set  VAC valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_13", "1")   //works set  BV valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_14", "1")   //works set  PV valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_15", "1")   //works set  Top LED color
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_16", "1")   //works set  CSI valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_17", "1")   //works set  Sensor 1 out
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_18", "1")   //works set  Sensor 2 out
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_19", "1")   //works set  Sensor 3 out
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_20", "1")   //works set  Sensor 4 out
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_21", "1")   //works set  GS valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_22", "1")   //works set  AV2 valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_23", "1")   //works set  AV3 valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", "1")   //works set  LED1 power
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_25", "1")   //works set  LED2 power
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_26", "1")   //works set  LED3 power
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_27", "1")   //works set  AV7 valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_28", "1")   //works set  AV8 valve

// can also query the above by changing Set to Get and "1" to value.
//string value
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_09", value)   //works read  WL valve state
//result("WL = " + value + " \n")

//string value
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_33", value)   //works set cpld bits individually
//result("TSO = " + value + "\n")
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_34", value)   //works set cpld bits individually
//result("SSO = " + value + "\n")
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_35", value)   //works set cpld bits individually
//result("LSC = " + value + "\n")
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_36", value)   //works set cpld bits individually
//result("GSC = " + value + "\n")
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_37", value)   //works set cpld bits individually
//result("VSC = " + value + "\n")                                               // note:  gate closed returns false
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_38", value)   //works set cpld bits individually
//result("SI10 = " + value + "\n")
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_39", value)   //works set cpld bits individually
//result("SI11 = " + value + "\n")
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_40", value)   //works set cpld bits individually
//result("SI12 = " + value + "\n")

