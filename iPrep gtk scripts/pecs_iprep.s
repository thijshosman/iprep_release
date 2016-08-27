//$BACKGROUND$
// --- this class is intended to do the following:
// --- * open/close gate valve, check status
// --- * check status of gate valve through sensors
// --- * lower/raise PECS stage
// --- * check status (up/down) of PECS stage
// --- * home the rotation stage
// --- * some secondary stuff, check pressures, etc. 

class pecs_iprep: object
{
	// handles communication with PECS for iPrep

	
	
	number stageAngle // angle
	number lockState // UI lockout state, 1 = ui locked, 0 = unlocked

	// store gv state in tag for safety
	object GVPersistance 
	object stagePersistance 

	// store gas flow values in tag for safety (and mode)
	object rightsccmPersistance
	object leftsccmPersistance
	object mfcmodePersistance

	object myMediator

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("PECS", level, text)
	}

	void print(object self, string text)
	{
		result("PECS: "+text+"\n")
		self.log(2,text)
	}
	
	number argonCheck(object self)
	{
		// *** public ***
		// return 1 if pressure sufficient, 0 if not
		string argonStatus
		PIPS_GetPropertyDevice("subsystem_pumping", "device_gasPressure", "read_pressure_status", argonStatus)
		self.log(2,"argon status: "+argonStatus)
		/*
		PRESSURE_OFF = 0,
		PRESSURE_OK = 1,
		PRESSURE_LOW = 2,
		PRESSURE_HIGH = 3
		*/

		if (argonStatus == "1")
			return 1
		else
			return 0

	}

	number TMPCheck(object self)
	{
		// *** public ***

		string tmpSpeed
		PIPS_GetPropertyDevice("subsystem_pumping", "device_turboPump", "read_speed_Hz", tmpSpeed)
		self.log(2,"tmpspeed: "+tmpSpeed)
		if (val(tmpSpeed)>1275)
		{
			return 1	
		}
		else
		{
			// check again to make sure:
			PIPS_GetPropertyDevice("subsystem_pumping", "device_turboPump", "read_speed_Hz", tmpSpeed)
			self.log(2,"tmpspeed extra check: "+tmpSpeed)
			if (val(tmpSpeed)>1275)
			{ 
				// return 1 like nothing happened
				return 1
			}
			else 
			{ 
				// now we have a real problem
				return 0
			}
		}

	}

	number getLockOut(object self)
	{
		return lockState
	}

	void lockOut(object self)
	{
		// lock UI
		PIPS_SetPropertySystem("set_control_lockout_enable", "1")
		lockState = 1
		self.print("UI locked")
	}

	void unlock(object self)
	{
		// unlock UI
		PIPS_SetPropertySystem("set_control_lockout_enable", "0")
		lockState = 0
		self.print("UI unlocked")		
	} 


	void startMilling(object self)
	{
		// *** public ***
		
		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")
		PIPS_Execute("SETP_SUB0000,subsystem_milling,set_milling_variation,0")
		sleep(10) // wait for PECS to set itself in the right position (move gun angles, etc) until start milling
		PIPS_StartMilling()
	}

	void startCoating(object self)
	{
		// *** public ***

		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")
		
		PIPS_Execute("SETP_SUB0000,subsystem_milling,set_milling_variation,1")
		PIPS_StartMilling()	

	}

	void stopMilling(object self)
	{
		// *** public ***
		PIPS_StopMilling()
	}

	number millingTimeRemaining(object self)
	{
		// *** public ***
		// returns time remaining in milling in seconds
		number t
		PIPS_GetTimeRemaining(0,t)
		return t
	}

	void goToCoatMode(object self)
	{
		// go to coating mode
		PIPS_Execute("STRTPROC0000,process_movetocoat")
		PIPS_Execute("SETP_SUB0000,subsystem_milling,set_milling_variation,1")
		self.print("now in coating mode")
	}

	void goToEtchMode(object self)
	{
		// go to etching mode
		PIPS_Execute("STRTPROC0000,process_movetoetch")
		PIPS_Execute("SETP_SUB0000,subsystem_milling,set_milling_variation,0")
		self.print("now in etching mode")
	}

	string getGVState(object self)
	{
		// *** public ***
		// gets gate valve state from sensors, SI10 = open, SI11 = closed


		string GVState // open or closed

		string SI10Value, SI11Value
		
		number openReturns = 0
		number closedReturns = 0
		number i = 0

			// open sensor
			PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_38", SI10Value)   //works set cpld bits individually
			if (SI10Value == "true")
			{
				openReturns++
				//SI10Value = ""
			}
			// closed sensor
			PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_39", SI11value)   //works set cpld bits individually
			if (SI11Value == "true") 
			{
				closedReturns++
				//SI11Value = ""
			}
			i++
				
			//self.print("SI10 = " + SI10Value )
			//self.print("SI11 = " + SI11Value )
			

		
		
		//result("openReturns: "+openReturns+", closedReturns: "+closedReturns+"\n")
		
		if (SI11Value == "true" & SI10Value == "false")
			GVState = "closed"
		else if (SI11Value == "false" & SI10Value == "true")
			GVState = "open"
		else
			GVState = "undefined"
	

		

		return GVState
		

	}

	string getStageState(object self)
	{
		// *** public ***`
		// read stage state from system (WL valve). 1=down, 0=up
		
		string stageState // up or down

		if (!self.argonCheck())
		{	
			stageState = "undefined"
			return stageState
		}

		string value
		PIPS_GetPropertyDevice("subsystem_pumping", "device_valveWhisperlok", "set_active", value) 

		if (value == "0")
		{
			stageState = "up"
			return "up"
		}
		else if (value == "1")
		{
			stageState = "down"
			return "down"
		}
	}

	string getSystemStatus(object self)
	{
		// *** public ***
		string answer
		PIPS_GetPropertySystem("read_process_activity", answer) 
   		// 0=none, 1=initializing, 2=stabilizing, 3=rotating stage, 4=aligning, 5=milling, 6=calibrating, 7=lowering stage
   		// 8=raising stage, 9=cold delay, 10=pumping, 11=venting, 12=finalizing, 13=paused, 14=resuming
   		return answer
	}

	number getMillingStatus(object self)
	{
		// *** public ***
		// checks if system is milling. return 1 if milling, 0 if done

		string answer
		PIPS_GetPropertySystem("ready", answer) // works returns true or false, will return false if the system is milling and true when it is done
		if (answer == "false")
			return 1	
		else if (answer == "true")
			return 0

	}

	string getStageAngle(object self)
	{
		// *** public ***
		return ""
	}

	void stageHome(object self)
	{
		// *** public ***

		self.print("homing stage")

		// first move stage to right front to make sure that it rotates when homing and does not just stay
		PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  
		
		// wait
		sleep(1)
		
		// now issue homing command
		PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")
		
		// wait 5 second in order for the stage to make sure it is at home
		sleep(5)

		self.print("stage homed")
	}

	void ilumOn(object self)
	{
		// *** public ***
		// turn top illuminator on and activate it

		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "1")  // works, enable top illuminator on=1, off=0
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "1")  // works, activate top illuminator on=1, off=0
	}

	void ilumOff(object self)
	{
		// *** public ***
		// turn top illuminator off and deactivate it

		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "0")  // works, enable top illuminator on=1, off=0
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "0")  // works, activate top illuminator on=1, off=0
	
	}


	void pecs_iprep(object self)
	{
		//constructor
		
		GVPersistance = alloc(statePersistance)
		GVPersistance.init("GVState")

		stagePersistance = alloc(statePersistance)
		stagePersistance.init("PECSStageState")

		leftsccmPersistance = alloc(persistentTag)
		leftsccmPersistance.init("IPrep:PECSParameters:leftsccm")

		rightsccmPersistance = alloc(persistentTag)
		rightsccmPersistance.init("IPrep:PECSParameters:rightsccm")

		mfcmodePersistance = alloc(persistentTag)
		mfcmodePersistance.init("IPrep:PECSParameters:mfcmode")

		self.getGVState()
		self.getStageState()
		self.getStageAngle()
	}

	number GVConsistencyCheck(object self)
	{
		// check if GV state from sensors is consistent with tag in DM
		string tagstate = GVPersistance.getState()
		string sensorstate = self.getGVState()

		if(sensorstate=="undefined") // check if sensor in some in between state, for example after powerloss
		{
			self.print("GV in undefined state, needs to be manually set to right state")
			return 0
		}

		if (tagstate == sensorstate)
		{
			// success
			return 1
		} else { 
			// not the same
			self.print("GV sensor and tag not in agreement")
			self.print("sensorstate: "+sensorstate)
			self.print("tagstate: "+tagstate)
			return 0
		}
	}

	number StageConsistencyCheck(object self)
	{
		// check if stage state from wl sensor is consistent with tag in DM
		string tagstate = stagePersistance.getState()
		string sensorstate = self.getStageState()

		if (sensorstate == "undefined")
		{
			self.print("stage in undefined state, needs to be manually set to right state")
			return 0
		}

		if (tagstate == sensorstate)
		{
			// success
			return 1
		} else {
			self.print("pecs stage not in correct state")
			return 0
		}
	}




	void moveStageUp(object self)
	{
		// *** public ***
		// moves stage up (use with caution)

		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")

		if (myMediator.getCurrentPosition() > 20)
		{
			self.print("safetycheck: Parker system not out of the way ("+myMediator.getCurrentPosition()+")! cannot raise stage")
			throw("safetycheck: Parker system not out of the way before raising stage")
		}


		self.print("raising stage")

		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVent", "set_active", "1")
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveWhisperlok", "set_active", "0")
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveLoadLock", "set_active", "0")
		sleep(.25)
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVacuum", "set_active", "1")
		sleep(7)
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVacuum", "set_active", "0")
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "1")  
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "1")  
		sleep(1) // changed with faster commands
		self.getStageState()
		stagePersistance.setState("up")
		
		// Stage is raised
		self.print("stage is raised")
	}

	void moveStageDown(object self)
	{
		// *** public ***
		// moves stage down (use with caution)

		if (!self.argonCheck())
			throw("argon pressure low, aborting")

		self.print("lowering stage")

		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveWhisperlok", "set_active", "1")
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "0")  
		sleep(3)
		sleep(1) // changed with faster commands
		self.getStageState()
		stagePersistance.setState("down")

		// Stage is lowered
		self.print("stage is lowered")
	}

	
	void init(object self)
	{
		// *** public ***
		// register with mediator
		myMediator = returnMediator()
		myMediator.registerPecs(self)
		self.print("pecs initialized")
	}
	
	// 2016-06-06
	// now av2 (bit 22) is gate valve push/pull circuit, av3 (bit 23) is coating target push/pull circuit
	// state 0 == open/out, state 1 == closed/in
	// sensors for gate valve are still the same

	void openGVandCheck(object self)
	{
		// *** public ***
		// opens GV and checks that status has changed
		// 2016-06-08 update: only open if actually closed

		if (self.getGVState() == "open")
		{
			self.print("GV already open")
			return
		}

		self.print("opening GV")

		// TODO: probably want to check that the pressures support this at some point (through mediator)

		// turn off av2
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_22", "0")
		sleep(3)
		if (self.getGVState() == "open")
		{
			// success
			self.print("GV opened succesfully")

			GVPersistance.setState("open")
			return
		}
		else
		{
			self.print("sensors do not detect GV in open state")
			throw("sensors do not detect GV in open state")
		}

	}

	void closeGVandCheck(object self)
	{
		// *** public ***
		// closes GV and checks that status has changed
		// 2016-06-08 update: only close if actually open

		if (self.getGVState() == "closed")
		{
			self.print("GV already closed")
			return
		}
		self.print("closing GV")

		// safety check: check that parker is out of the way
		if (myMediator.getCurrentPosition() > 150)
		{
			self.print("safetycheck: Parker system not out of the way ("+myMediator.getCurrentPosition()+")! cannot close GV")
			throw("safetycheck: Parker system not out of the way")
		}

		// turn on av2
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_22", "1")
		sleep(3)
		if (self.getGVState() == "closed")
		{
			// success
			self.print("GV closed succesfully")

			GVPersistance.setState("closed")
			return
		}
		else
		{
			self.print("sensors do not detect GV in closed state")
			throw("sensors do not detect GV in closed state")
		}

	}

	
	// TODO: synchronize the following with simulator
	// make sure the state of the reed relay sensor is read in BING
	
	// value == "false" for inserted state, value == "true" for retracted state
	
	string getShutterState(object self)
	{
		// *** public ***
		// get state of shutter. value == "false" for inserted state, value == "true" for retracted state
		string value
		PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_33", value)   //TSO state
		if (value=="true")
		{
			return "out"
		}
		else if (value == "false")
		{
			return "in"
		}
		else
		{
			return  "unknown"
		}

	}

	void moveShutterIn(object self)
	{
		// *** public ***
		// move shutter in

		if(!self.argonCheck())
		{
			self.print("argon check failed when trying to insert shutter")
			throw("argon check failed when trying to insert shutter")
		}

		if(self.getStageState() != "down")
		{
			self.print("argon check failed when trying to insert shutter")
			throw("argon check failed when trying to insert shutter")		
		}

		// turn on av3
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_23", "1")

		self.print("Shutter inserted")

	}

	void moveShutterOut(object self)
	{
		// *** public ***
		// move shutter in

		// check if it is already there. if so, do nothing
		if (self.getShutterState() == "out")
		{
			self.print("Shutter already retracted")
			return
		}

		// turn off av3
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_23", "0")

		self.print("Shutter retracted")

	}

	void shutoffArgonFlow(object self)
	{
		// *** public ***
		// shuts off argon flow to maximize vacuum during transfer
		
		// only save values when they are nonzero. otherwise set gas flow to defualt value
		// #TODO: this is not the nicest way to do this, but ok for now. 
		string leftsccm, rightsccm

		// read the gas flow mode first
		string gasflowmode
		PIPS_GetPropertySubsystem("subsystem_milling", "set_gas_mode", gasflowmode) // 0 for automatic, 1 for manual 

		// save the state, manual or automatic
		mfcmodePersistance.set(gasflowmode)

		// if manual, remember value and set to 0
		if (gasflowmode == "1") // manual
		{
			// get manual set points
			PIPS_GetPropertyDevice("subsystem_milling", "device_mfcLeft", "set_gas_flow_sccm", leftsccm)  // works
			PIPS_GetPropertyDevice("subsystem_milling", "device_mfcRight", "set_gas_flow_sccm", rightsccm)  // works

		}
		else if (gasflowmode == "0") // automatic
		{
			// get auto set points
			PIPS_GetPropertyDevice("subsystem_milling", "device_mfcLeft", "set_auto_gas_flow_sccm", leftsccm)  // works
			PIPS_GetPropertyDevice("subsystem_milling", "device_mfcRight", "set_auto_gas_flow_sccm", rightsccm)  // works		

		}

		// now save the values
		if (leftsccm != "0" && rightsccm != "0") // make sure we are not just saving 0, if so, dont save them
		{
			rightsccmPersistance.set(rightsccm)
			leftsccmPersistance.set(leftsccm)
		}
		else
		{
			self.print("warning: attempted to set mfcs to 0. skipping..")
		}
		
		// set them to 0 for manual mode
		PIPS_SetPropertyDevice("subsystem_milling", "device_mfcLeft", "set_gas_flow_sccm", "0")  // works,  only for manual mode
		PIPS_SetPropertyDevice("subsystem_milling", "device_mfcRight", "set_gas_flow_sccm", "0")  // works,  only for manual mode

		if (gasflowmode == "0") // automatic
		{
			self.print("setting PECS to manual gas flow mode")
			PIPS_SetPropertySubsystem("subsystem_milling", "set_gas_mode", "1") // set to manual if not already so
		}
		else
		{
			self.print("PECS already in manual mode")
		}




		self.print("shutting off gas flow. remembered values are: "+leftsccm+", "+rightsccm)

		// debug to check values
		//sleep(2)
		//string leftsccm1, rightsccm1
		//PIPS_GetPropertyDevice("subsystem_milling", "device_mfcLeft", "read_gas_flow_sccm", leftsccm1)  // works
		//PIPS_GetPropertyDevice("subsystem_milling", "device_mfcRight", "read_gas_flow_sccm", rightsccm1)  // works
		//self.print("gas flow values debug: left="+leftsccm1+", right="+rightsccm1)


	}


	void restoreArgonFlow(object self)
	{
		// *** public ***
		// restore argon flow to previous values
		
		string leftsccm, rightsccm, gasflowmode
		leftsccm = leftsccmPersistance.get()
		rightsccm = rightsccmPersistance.get()
		gasflowmode = mfcmodePersistance.get()


		if (leftsccm == "0" || rightsccm == "0")
		{
			self.print("warning: attempting to restore gas flow values to 0. using default values instead")
		}

		if (gasflowmode == "0") // automatic, should automatically put them back
		{
			// set back to automatic
			PIPS_SetPropertySubsystem("subsystem_milling", "set_gas_mode", "0")
		}


		self.print("restoring gasflow to previous values: "+leftsccm+", "+rightsccm)

		// set gas flow to previously remembered values
		PIPS_SetPropertyDevice("subsystem_milling", "device_mfcLeft", "set_gas_flow_sccm", leftsccm)  // works,  only for manual mode
		PIPS_SetPropertyDevice("subsystem_milling", "device_mfcRight", "set_gas_flow_sccm", rightsccm)  // works,  only for manual mode

		// debug to check values
		//sleep(2)
		//string leftsccm1, rightsccm1
		//PIPS_GetPropertyDevice("subsystem_milling", "device_mfcLeft", "read_gas_flow_sccm", leftsccm1)  // works
		//PIPS_GetPropertyDevice("subsystem_milling", "device_mfcRight", "read_gas_flow_sccm", rightsccm1)  // works
		//self.print("gas flow values debug: left="+leftsccm1+", right="+rightsccm1)

	}






}

//object aPecs = alloc(pecs_iprep)

//result("start\n")

// +++ pecs stage +++

//result("stage status: "+aPecs.getStageState()+"\n")
//aPecs.moveStageUp()
//result("stage status: "+aPecs.getStageState()+"\n")
//aPecs.moveStageUp()
//result("stage status: "+aPecs.getStageState()+"\n")

//aPecs.stageHome()

// +++ milling +++

//aPecs.startMilling()
//sleep(2)
//result("system status: "+aPecs.getSystemStatus()+"\n")
//result("milling status: "+aPecs.getMillingStatus()+"\n")

//aPecs.stopMilling()
//sleep(2)
//result("system status: "+aPecs.getSystemStatus()+"\n")
//result("milling status: "+aPecs.getMillingStatus()+"\n")



// +++ gate valve +++
//aPecs.openGV()
//aPecs.closeGV()
//result("GVstate: "+aPecs.getGVstate()+"\n")





