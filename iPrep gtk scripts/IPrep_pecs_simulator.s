// $BACKGROUND$
// --- this class is intended to do the following:
// --- * open/close gate valve, check status
// --- * check status of gate valve through sensors
// --- * lower/raise PECS stage
// --- * check status (up/down) of PECS stage
// --- * home the rotation stage
// --- * some secondary stuff, check pressures, etc. 

// pecs simulator class
// assumes all operations are succesful and sets the state accordingly

class pecs_simulator: object
{
	// handles communication with PECS for iPrep

	string GVState // open or closed
	string stageState // up or down
	number stageAngle // angle
	number lockState // UI lockout state, 1 = ui locked, 0 = unlocked

	// store gv state in tag for safety
	object GVPersistance
	object stagePersistance 

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
		string argonStatus = "1"
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

		string tmpSpeed = "1500"
		
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
		
		lockState = 1
		self.print("UI locked")
	}

	void unlock(object self)
	{
		// unlock UI
		
		lockState = 0
		self.print("UI unlocked")		
	} 

	void startMilling(object self)
	{
		// *** public ***
		sleep(5)
		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")
		
	}

	void startCoating(object self)
	{
		// *** public ***

		if (!self.argonCheck())
			throw("argon pressure check failed, aborting")

	}

	void stopMilling(object self)
	{
		// *** public ***
		//PIPS_StopMilling()
	}

	number millingTimeRemaining(object self)
	{
		// *** public ***
		// returns time remaining in milling in seconds
		number t = 6
		//PIPS_GetTimeRemaining(0,t)
		return t
	}

	void goToCoatMode(object self)
	{
		// go to coating mode

		self.print("now in coating mode")
	}

	void goToEtchMode(object self)
	{
		// go to etching mode

		self.print("now in etching mode")
	}


	string getGVState(object self)
	{
		// *** public ***
		// return gvstate as found in tag



		return GVPersistance.getState()
		

	}

	string getStageState(object self)
	{
		// *** public ***`
		// read stage state from system (WL valve). 1=down, 0=up
		
		return stagePersistance.getState()
	}

	string getSystemStatus(object self)
	{
		// *** public ***
		string answer
		answer = "0"
   		// 0=none, 1=initializing, 2=stabilizing, 3=rotating stage, 4=aligning, 5=milling, 6=calibrating, 7=lowering stage
   		// 8=raising stage, 9=cold delay, 10=pumping, 11=venting, 12=finalizing, 13=paused, 14=resuming
   		return answer
	}

	number getMillingStatus(object self)
	{
		// *** public ***
		// checks if system is milling. return 1 if milling, 0 if done

		string answer
		answer = "true" // works returns true or false, will return false if the system is milling and true when it is done
		
		if (answer == "false")
			return 1	
		else if (answer == "true")
			return 0

	}

	number getStageAngle(object self)
	{
		// *** public ***
		return 0
	}

	void stageHome(object self)
	{
		// *** public ***

		self.print("homing stage")

		// first move stage to right front to make sure that it rotates when homing and does not just stay
		//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  
		
		// wait
		//sleep(1)
		
		// now issue homing command
		//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")
		
		// wait 5 second in order for the stage to make sure it is at home
		sleep(4)

		self.print("stage homed")
	}

	void ilumOn(object self)
	{
		// *** public ***
		// turn top illuminator on and activate it

		//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "1")  // works, enable top illuminator on=1, off=0
		//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "1")  // works, activate top illuminator on=1, off=0
	}

	void ilumOff(object self)
	{
		// *** public ***
		// turn top illuminator off and deactivate it

		//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "0")  // works, enable top illuminator on=1, off=0
		//PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "0")  // works, activate top illuminator on=1, off=0
	
	}


	void pecs_simulator(object self)
	{
		//constructor
		
		GVPersistance = alloc(statePersistance)
		GVPersistance.init("GVState")

		stagePersistance = alloc(statePersistance)
		stagePersistance.init("PECSStageState")

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
			self.print()
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

		
		sleep(3)
		
		self.getStageState()
		stagePersistance.setState("down")

		// Stage is lowered
		self.print("stage is lowered")
	}

	void init(object self)
	{
		// *** public ***
		self.print("simulator initialized")
		
		// register with mediator
		myMediator = returnMediator()
		myMediator.registerPecs(self)
	}


	void openGVandCheck(object self)
	{
		// *** public ***
		// opens GV and checks that status has changed


		self.print("opening GV")

		GVPersistance.setState("open")

		if (self.getGVState() == "open")
		{
			// success
			self.print("GV opened succesfully")
			GVState = "open"
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


		self.print("closing GV")



		// safety check: check that parker is out of the way
		if (myMediator.getCurrentPosition() > 150)
		{
			self.print("safetycheck: Parker system not out of the way ("+myMediator.getCurrentPosition()+")! cannot close GV")
			throw("safetycheck: Parker system not out of the way")
		}

		GVPersistance.setState("closed")

		if (self.getGVState() == "closed")
		{
			// success
			self.print("GV closed succesfully")
			GVState = "closed"
			GVPersistance.setState("closed")
			return
		}
		else
		{
			self.print("sensors do not detect GV in closed state")
			throw("sensors do not detect GV in closed state")
		}


	}


	void moveShutterIn(object self)
	{
		// *** public ***
		// move shutter in

		self.print("Shutter inserted")

	}

	void moveShutterOut(object self)
	{
		// *** public ***
		// move shutter out

		self.print("Shutter retracted")

	}

	void shutoffArgonFlow(object self)
	{
		// *** public ***
		// shuts off argon flow to maximize vacuum during transfer

	}


	void restoreArgonFlow(object self)
	{
		// *** public ***
		// restore argon flow to previous values

	}

}



