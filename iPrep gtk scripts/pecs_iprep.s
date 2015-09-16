// $BACKGROUND$
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

	string GVState // open or closed
	string stageState // up or down
	number stageAngle // angle
	number lockState // UI lockout state, 1 = ui locked, 0 = unlocked

	// store gv state in tag for safety
	object GVPersistance = alloc(statePersistance)

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
			return 1
		else
			return 0

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

	void setMFCsToZero(object self)
	{
		// *** public ***
		// set both MFCs to 0 in order to not flood the SEM chamber
		// TODO: find script commands for doing this
	}

	string getGVState(object self)
	{
		// *** public ***
		// gets gate valve state from sensors, SI10 = open, SI11 = closed
		// 07-14-15: sensors do not work reliably, disabling..
		// 09-16-15: use tag to save state

		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")
	/*
		string SI10Value, SI11Value
		
		number openReturns = 0
		number closedReturns = 0
		number i =0
		while (i<6)
		{
			// open sensor
			PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_38", SI10Value)   //works set cpld bits individually
			if (SI10Value == "true")
			{
				openReturns++
				SI10Value = ""
			}
			// closed sensor
			PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_39", SI11value)   //works set cpld bits individually
			if (SI11Value == "true") 
			{
				closedReturns++
				SI11Value = ""
			}
			i++
				
			//result("SI10 = " + value + "\n")
			//result("SI11 = " + value + "\n")
			

		}
		
		//result("openReturns: "+openReturns+", closedReturns: "+closedReturns+"\n")
		
		if (closedReturns > 2 && openReturns < 3)
			GVState = "closed"
		else if (openReturns > 2 && closedReturns < 3)
			GVState = "open"
	*/	

		//GVState = "SI10: "+SI10Value+", SI11: "+SI11Value

		return GVState
		

	}

	string getStageState(object self)
	{
		// *** public ***`
		// read stage state from system (WL valve). 1=down, 0=up
		
		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")

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
		//sleep(1)
		
		// now issue homing command
		PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")
		
		// wait 5 second in order for the stage to make sure it is at home
		sleep(4)

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


	void PECS(object self)
	{
		//constructor
		GVPersistance.init("GVState")
		self.getGVState()
		self.getStageState()
		self.getStageAngle()
	}

	void moveStageUp(object self)
	{
		// *** public ***
		// moves stage up (use with caution)

		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")

		self.print("raising stage")

		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVent", "set_active", "1")
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveWhisperlok", "set_active", "0")
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveLoadLock", "set_active", "0")
		sleep(.25)
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVacuum", "set_active", "1")
		sleep(5)
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVacuum", "set_active", "0")
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "1")  
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "1")  

		self.getStageState()
		
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
		
		self.getStageState()
		// Stage is lowered
		self.print("stage is lowered")
	}

	/*
	void init(object self)
	{
		// *** public ***
	}
	*/
	
	void openGV(object self)
	{
		// *** private ***
		// opens gate valve (AV2)
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_22", "1")
		//sleep(1)

	}

	void closeGV(object self)
	{
		// *** private ***
		// closes gate valve (AV2)
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_22", "0")
		//sleep(1)
	}
	

/* Patch to interlock Gate Valve
void closeGV(object self)	// #TODO: REMOVE enableGV, temp patch
	{
		// *** private ***
		// closes gate valve (AV2)
		number enableGV=0
		GetPersistentTagGroup().TagGroupGetTagAsLong("IPrep:enableCloseGV", enableGV)
		if ( enableGV )
			PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_22", "0")
		else
			result("GATE VALUE REQUEST TO CLOSE DENIED. ENABLE WITH enableCloseGV TAG.")

		//sleep(1)
	}
*/

	void openGVandCheck(object self)
	{
		// *** public ***
		// opens GV and checks that status has changed

		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")

		self.print("opening GV")

		self.OpenGV()

		// set state 
		GVState = "open"
		GVPersistance.setState("open")



	/*
		if (self.getGVState() == "open")
		{
			self.print("GV opened succesfully")
			return
		} else {
			if(!ContinueCancelDialog( "GV problem. continue?" ))
				throw("GV did not open correctly")
		}
	*/


	}

	void closeGVandCheck(object self)
	{
		// *** public ***
		// closes GV and checks that status has changed

		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")

		self.print("closing GV")

		// safety check: check that parker is out of the way
		if (checkParker() > 150)
		{
			self.print("safetycheck: Parker system not out of the way ("+checkParker()+")! cannot close GV")
			throw("safetycheck: Parker system not out of the way")
		}


		self.closeGV()

	/*
		if (self.getGVState() == "closed")
		{
			self.print("GV closed succesfully")
			return
		} else {
			if(!ContinueCancelDialog( "GV problem. continue?" ))
				throw("GV did not close correctly")
		}
	*/

		GVState = "closed"
		GVPersistance.setState("closed")

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





