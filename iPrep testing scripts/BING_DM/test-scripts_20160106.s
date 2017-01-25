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

//PIPS_SetPropertySystem("set_control_lockout_enable", "1")           // to lock out UI during iprep move
//PIPS_SetPropertyDevice("subsystem_pumping", "device_valveLoadLock", "set_active", "0")

//PIPS_Execute(“SETP_SUB0000,subsystem_milling,set_milling_variation,1")    // 1=set to coating mode, 2=etching mode (iprep, not tested, set b4 [start milling])


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
  //10-mfc_reset, 11=transfer(PECS), 12=move to etch(PECS), 13=move to coat(PECS), 14=align raise(PECS), 15=align lower(PECS)
//result(answer2 + " \n")

//PIPS_Execute(“SETP_SUB0000,subsystem_milling,set_milling_variation,1")  // tell system if you will be milling or coating, 0=milling,1=coating
//  then [set terminating condition] then [start milling], you have to set this flag every time just before you start
//PIPS_GetPropertySubSystem("subsystem_milling","read_coat_condition_remaining_s","value")  //read coating time remaining

//PIPS_GetPropertySubsystem("subsystem_milling", "set_gas_mode", current_value)  //read gas flow mode
//PIPS_SetPropertySubsystem("subsystem_milling", "set_gas_mode", 1)   // set gas flow mode: 0=auto, 1=manual
//PIPS_SetPropertySystem("set_calibrate_gasflow_mode", "1")    // 0=all, 1=single
//PIPS_SetPropertySystem("set_calibrate_gasflow_index", "7")   //0=.25kV,1=.5,2=.75,3=1,4=2,5=3,6=4,7=5,8=6,9=7,10=8kV
//PIPS_StartProcess(“process_gascalibrate")

// ** Imaging functions
//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "1")  // works, enable top illuminator on=1, off=0
//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "1")  // works, activate top illuminator on=1, off=0
//PIPS_SetPropertySubsystem("subsystem_imaging", "set_imaging_mode",  "0")       // works, 0=off, 1=live, 2=record milling


// ** stage functions
//PIPS_SetPropertyDevice("STRTPROC0000","process_movetocoat"}  // PECS, move to coating mode  (haven't tested)
//PIPS_SetPropertyDevice("STRTPROC0000","process_movetoetch"}  // PECS, move to etching mode  (haven't tested)
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "0")  // works,  rotation off
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "1")  // works,  rotation on
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "2")  // does NOT work,  rotation backwards
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "4")  // works,  stage to custom angle
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "5")  // works,  stage to left front
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "6")  // works,  stage to left rear
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "8")  // works,  stage to right rear
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "9")  // works,  stage to reverse correction
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_custom_angle_deg10", "2700")  // works, set custom align angle
//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_speed_RPM", "3")  // works,  set stage rot'n speed
//PIPS_GetPropertySubsystem("subsystem_pumping", "read_stage_position",  stagepos)  // works (but always returns 1) read stage location: 0=?, 1=up, 2=down
//result(stagepos + " =stage location (0=?, 1=up, 2=down)\n")
// **cold stage functions
//PIPS_GetPropertyDevice ( "subsystem_coldstage", "device_coldFinger", "read_temperature_C", temp )  // Eric uses this
//PIPS_SetPropertyDevice ( "subsystem_coldstage", "device_coldStageHeater", "set_setpoint_C", "100" )  // Eric uses this
//PIPS_SetPropertyDevice ( "subsystem_coldstage", "device_coldStageHeater", "set_enable", "1" )  // Eric uses this, 1=enable, 0=disable
//PIPS_GetPropertyDevice ( "subsystem_coldstage", "device_dewarHeater", "read_active" , dewar_heater_on )  //Eric uses this
//PIPS_Execute(“D_ACTION0000,subsystem_coldstage,device_dewarHeater,0”)       //start heating
//PIPS_SetPropertyDevice("subsystem_coldstage", "device_dewarHeater", "set_cancel_heating", "1")    //cancel/stop heating

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
//PIPS_GetPropertySubsystem("subsystem_milling", "set_gas_mode", current_value)  // read gas mode (0=auto, 1=manual)
//PIPS_SetPropertySubsystem("subsystem_milling", "set_gas_mode", 1)              // set gas mode  (0=auto, 1=manual)

// ** Motorized gun functions
//PIPS_SetPropertyDevice("SETP_DEV0000","subsystem_milling","device_gunLeft","set_target_angle_deg","5.1"}
//PIPS_Execute("D_ACTION0000","subsystem_milling","device_gunLeft","0")                                        //0=start 1=stop
//PIPS_SetPropertyDevice("SETP_DEV0000","subsystem_milling","device_gunRight","set_target_angle_deg","5.1"}
//PIPS_Execute("D_ACTION0000","subsystem_milling","device_gunRight","0")



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
//PIPS_GetPropertyDevice("subsystem_coldstage", "device_coldFinger", "read_temperature_C ", cstemp)     // does NOT work (eric uses it)


/*      complete list of process identifiers
        PROCESS_RESET          = 0,
        PROCESS_HOME           = 1,
        PROCESS_MILL           = 2,
        PROCESS_ALIGN          = 3,
        PROCESS_AIRLOCK_VENT   = 4,
        PROCESS_AIRLOCK_PUMP   = 5,
        PROCESS_STAGE_DOWN     = 6,
        PROCESS_STAGE_UP       = 7,
        PROCESS_GAS_CALIBRATE  = 8,
        PROCESS_RECIPE_MILL    = 9,
        PROCESS_MFC_RESET      = 10,
        PROCESS_TRANSFER       // 11 on PECS
        PROCESS_MOVETOETCH,    // 12 on PECS
        PROCESS_MOVETOCOAT,    // 13 on PECS
        PROCESS_ALIGNRAISE,    // 14 on PECS
        PROCESS_ALIGNLOWER,    // 15 on PECS
        
        ROTATE_MODE_NONE                                = 0,
        ROTATE_MODE_ROTATE                              = 1,
        ROTATE_MODE_BACKWARDS                           = 2,
        ROTATE_MODE_ALIGN_HOME                          = 3,
        ROTATE_MODE_ALIGN_CUSTOM                        = 4,
        ROTATE_MODE_ALIGN_LEFT_FRONT_BEAM_SECTOR        = 5,
        ROTATE_MODE_ALIGN_LEFT_REAR_BEAM_SECTOR         = 6,
        ROTATE_MODE_ALIGN_RIGHT_FRONT_BEAM_SECTOR       = 7,
        ROTATE_MODE_ALIGN_RIGHT_REAR_BEAM_SECTOR        = 8,
        ROTATE_MODE_REVERSE_CORRECTION                  = 9,    // added 1/28/2015
 
*/