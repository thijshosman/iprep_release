// ** system functions
//PIPS_StartMilling()                    //works
//PIPS_StopMilling()                     //works
//PIPS_PauseMilling()                    //works
//PIPS_ResumeMilling()                   //works

// PIPS_StartRecipe()                    // haven't tested
// PIPS_StopRecipe()                     // haven't tested
// PIPS_PauseRecipe()                    // haven't tested
// PIPS_ResumeRecipe()                   // haven't tested
// PIPS_RecipeNextStep()                 // haven't tested 

//PIPS_SetPropertySystem("set_control_lockout_enable", "1")
//PIPS_SetPropertyDevice("subsystem_pumping", "device_valveLoadLock", "set_active", "0")

//number answer1
//PIPS_GetVoltage(answer1)               // sometimes returns the wrong voltage, rounds to kV, not useful
//PIPS_GetAngleLeft(answer1)             // haven't tested
//PIPS_GetAngleRight(answer1)            // haven't tested
//PIPS_GetCurrentLeft(answer1)           // reads Ia
//PIPS_GetCurrentRight(answer1)          //  reads Ia
//PIPS_GetModulation(answer1)            //no=0, single=1, double=2, stationary left=3 stationary right =4, custom=5
//PIPS_GetTimeRemaining(0,answer1)       // works, in seconds, set: 0=no recipe, 1=is recipe
//PIPS_GetTimeElapsed(answer1)           // works, in seconds
//result(answer1 + " \n")                

//PIPS_SetVoltage(5)                     // does NOT work
//PIPS_SetAngleLeft(5)                  // haven't tested (gun angles)
//PIPS_SetAngleRight(5)                 // haven't tested (gun angles)
//PIPS_SetModulation(1)                  // works;  no=0, single=1, double=2, stationary left=3 stationary right =4, custom=5
//result("done \n")

//string answer2
//PIPS_GetPropertySystem("read_process_activity", answer2)       //works, reads process activity
   // 0=none, 1=initializing, 2=stabilizing, 3=rotating stage, 4=aligning, 5=milling, 6=calibrating, 7=lowering stage
   // 8=raising stage, 9=cold delay, 10=pumping, 11=venting, 12=finalizing, 13=paused, 14=resuming
//PIPS_GetPropertySystem("ready", answer2)       // works returns true or false
//PIPS_GetPropertySystem("activeProcess", answer2)       // works
  //0=reset, 1=home, 2=mill, 3=align, 4=vent chamber, 5=pump chamber, 6=stage lower, 7=stage raise, 8=gas calibrate, 9=recipe mill
//result(answer2 + " \n")


// ** Imaging functions
//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "1")  // works, enable top illuminator on=1, off=0
//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "1")  // works, activate top illuminator on=1, off=0
//PIPS_SetPropertySubsystem("subsystem_imaging", "set_imaging_mode",  "0")       // works, 0=off, 1=live, 2=record milling


// ** stage functions
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "0")  // works,  rotation off
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "1")  // works,  rotation on
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "2")  // does NOT work,  rotation backwards
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "5")  // works,  stage to left front
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "6")  // works,  stage to left rear
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "8")  // works,  stage to right rear
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_custom_angle_deg10", "2700")  // works, set custom align angle
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "4")  // works, go to custom align angle
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_speed_RPM", "3")  // works,  set stage rot'n speed

//PIPS_GetPropertySubsystem("subsystem_pumping", "read_stage_position",  stagepos)  // works (but always returns 1) read stage location: 0=?, 1=up, 2=down
//result(stagepos + " =stage location (0=?, 1=up, 2=down)\n")


// **  HVPS functions
//PIPS_SetPropertyDevice("subsystem_milling", "device_hvps", "set_accelerating_voltage_keV", "3.2") // works
//PIPS_SetPropertyDevice("subsystem_milling", "device_hvps", "set_discharge_voltage_keV", ".55")    // works
//PIPS_SetPropertyDevice("subsystem_milling", "device_hvps", "set_focus_voltage_keV", "1.1")        // does NOT work
/*
string Vacc, Vdis, Vfoc, IaL, IaR, IdL, IdR, Ifoc
PIPS_GetPropertyDevice("subsystem_milling", "device_hvps", "read_accelerating_voltage_keV", Vacc)     // works
PIPS_GetPropertyDevice("subsystem_milling", "device_hvps", "read_discharge_voltage_keV", Vdis)        // works
PIPS_GetPropertyDevice("subsystem_milling", "device_hvps", "read_focus_voltage_keV", Vfoc)            // works
PIPS_GetPropertyDevice("subsystem_milling", "device_hvps", "read_accelerating_current_left_uA", IaL)  // works
PIPS_GetPropertyDevice("subsystem_milling", "device_hvps", "read_accelerating_current_right_uA", IaR) // works
PIPS_GetPropertyDevice("subsystem_milling", "device_hvps", "read_discharge_current_left_uA", IdL)     // works
PIPS_GetPropertyDevice("subsystem_milling", "device_hvps", "read_discharge_current_right_uA", IdR)    // works
PIPS_GetPropertyDevice("subsystem_milling", "device_hvps", "read_focus_current_uA", Ifoc)             // works
result( "Va = "+Vacc+"  Vd = " +Vdis +"  Vf = " +Vfoc +"\n")
result("Ia left = " + IaL + "  Ia right = " + IaR + "  Id left = " + IdL + " Id right = " + IdR + "  If = " + Ifoc + "\n") 
*/

//  ** Vacuum and valve functions
//string backinggauge, ccgauge, turbohz, turbow, Arpressure, Ar_status
//PIPS_GetPropertyDevice("subsystem_pumping", "device_backingGauge", "read_pressure_Torr", backinggauge)  // works, read backing pressure in Torr
//PIPS_GetPropertyDevice("subsystem_pumping", "device_coldCathodeGauge", "read_pressure_Torr", ccgauge)  // works, read CC gauge pressure in Torr
//PIPS_GetPropertyDevice("subsystem_pumping", "device_gasPressure", "read_pressure_PSI", Arpressure)     // works, read Argon pressure
//PIPS_GetPropertyDevice("subsystem_pumping", "device_turboPump", "read_speed_Hz", turbohz)              // works  read turbo speed
//PIPS_GetPropertyDevice("subsystem_pumping", "device_turboPump", "read_power_W", turbow)                // works  read turbo power
//PIPS_GetPropertyDevice("subsystem_pumping", "device_gasPressure", "read_pressure_status", Ar_status)    // works  read Argon pressure status 0=off, 1=OK, 2=low, 3=high
//result("Backing = " + backinggauge.left(3) + " Torr    " + "Chamber = " + ccgauge.left(4) + ccgauge.right(4) + " Torr" + "   Argon = "+Arpressure.left(4)+" PSI   Turbo = " + turbohz + " Hz  " + turbow +  " Watt\n")
//result(Ar_status + "\n")
//PIPS_SetPropertyDevice("subsystem_pumping", "device_turboPump", "set_active", "1")                     //works  enable turbo pump

/*
string valveWL, valveLL, valveVT, valveVA
PIPS_GetPropertyDevice("subsystem_pumping", "device_valveWhisperlok", "set_active", valveWL) //works, read state of valve (what it's set to)
PIPS_GetPropertyDevice("subsystem_pumping", "device_valveLoadLock", "set_active", valveLL)   //works, read state of valve (what it's set to)
PIPS_GetPropertyDevice("subsystem_pumping", "device_valveVent", "set_active", valveVT)       //works, read state of valve (what it's set to)
PIPS_GetPropertyDevice("subsystem_pumping", "device_valveVacuum", "set_active", valveVA)     //works, read state of valve (what it's set to)
result("WL= "+valveWL +"  LL= "+valveLL+"  Vent= "+valveVT+"  VAC= "+valveVA+"\n")
*/
//PIPS_SetPropertyDevice("subsystem_pumping", "device_diaphragmPump", "set_active", "1") //works, turn on/off DP
//PIPS_SetPropertyDevice("subsystem_pumping", "device_turboPump", "set_active", "1") //works, turn on/off Turbo
//PIPS_SetPropertyDevice("subsystem_pumping", "device_coldCathodeGauge", "set_enable", "1") //works, turn on/off CC gauge


// ** MFC functions
//string leftsccm, rightsccm
//PIPS_GetPropertyDevice("subsystem_milling", "device_mfcLeft", "read_gas_flow_sccm", leftsccm)  // works
//PIPS_GetPropertyDevice("subsystem_milling", "device_mfcRight", "read_gas_flow_sccm", rightsccm)  // works
//result("Left MFC = " + leftsccm + " sccm ; Right MFC = " + rightsccm + " sccm \n")
//PIPS_SetPropertyDevice("subsystem_milling", "device_mfcLeft", "set_gas_flow_sccm", ".1")  // works,  only for manual mode
//PIPS_SetPropertyDevice("subsystem_milling", "device_mfcRight", "set_gas_flow_sccm", ".1")  // works,  only for manual mode
//PIPS_SetPropertyDevice("subsystem_milling", "device_mfcLeft", "set_auto_gas_flow_sccm", ".1")  // works,  only for auto mode, overrides angle table
//PIPS_SetPropertyDevice("subsystem_milling", "device_mfcRight", "set_auto_gas_flow_sccm", ".1")  // works,  only for auto mode, overrides angle table


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
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", "0")   //works set  LED1 power
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_25", "1")   //works set  LED2 power
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_26", "1")   //works set  LED3 power
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_27", "1")   //works set  AV7 valve
//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_28", "1")   //works set  AV8 valve

// should be able to query some of the above by changing Set to Get and "1" to value. Doesn't work for bits 01-28!! 
//string value
//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", value)   //does not work, read valve state
//result("? = " + value + " \n")
/*
string value
PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_33", value)   //works get cpld bits individually
result("TSO = " + value + "\n")
PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_34", value)   //works get cpld bits individually
result("SSO = " + value + "\n")
PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_35", value)   //works get cpld bits individually
result("LSC = " + value + "\n")
PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_36", value)   //works get cpld bits individually
result("GSC = " + value + "\n")
PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_37", value)   //works get cpld bits individually
result("VSC = " + value + "\n")                                               // note:  VTD gate closed returns false (it's backwards)
PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_38", value)   //works get cpld bits individually
result("SI10 = " + value + "\n")
PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_39", value)   //works get cpld bits individually
result("SI11 = " + value + "\n")
PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_40", value)   //works get cpld bits individually
result("SI12 = " + value + "\n")
*/


// things that don't work
//PIPS_SetPropertyDevice("subsystem_imaging", "device_shutter", "set_position", "1")   // does NOT work
//PIPS_GetPropertySubsystem("subsystem_pumping", "read_stage_position",  stagepos)  // works (but always returns 1) read stage location: 0=?, 1=up, 2=down
//result(stagepos + " =stage location (0=?, 1=up, 2=down)\n")
//PIPS_SetPropertyDevice("subsystem_pumping", "device_buzzer", "set_active", "1") // does NOT work, turn on/off buzzer
//PIPS_GetPropertyDevice("subsystem_coldstage", "device_coldFinger", "read_temperature_C ", cstemp)     // does NOT work

