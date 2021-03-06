// $BACKGROUND$

// assumes parker IPA controller
// hardware/software used: ACR-View 6.4.0.1053
// project ipa_attempt2, device ipa_2

// for parker ARIES, we may need to create new class that takes specific flags/parameters into account





class parkerTransfer_IPA:object
{
	// manages transfers of the parker system between discrete positions
	// max parker position is 545 mm

	object parkerPositions // manages positions in tags
	object myMediator

	number direction // defines direction of positive axis. 
	// 0=unset, 1=neg(motor close, as on demo unit), 2=pos(motor far, as in manchester)

	String cmd, reply, state, laststate
	number PPU // factor between encoder ticks and position (function of lead)
	number timeout // timeout for going to position
	number accuracy // accuracy for getting to position

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("TRANSFER", level, text)
	}

	void print(object self, string text)
	{
		// *** public ***
		result("Transfer: "+text+"\n")
		self.log(2,text)
	}

	object returnParkerPositions(object self)
	{
		return parkerPositions
	}


	void restoreState(object self)
	{
		// *** private ***
		// restore state from tags
		state = parkerPositions.getCurrentState()
		laststate = parkerPositions.getLastState()
		self.print("current state is "+state+", last state was "+laststate)
	}

	string sendCommand(object self, string command)
	{
		// *** private ***
		// send generic command to parker and receive reply
		reply = ""
		cmd = command
		// try sending command. if it throws exception, silently ignore it once and try again
		// this will help the occasional error as observed in testing
		try 
		{
			Parker_SendCommand(cmd, reply)
		}
		catch
		{
			self.print("level 1 error generated with command: "+cmd)
			debug("level 1 error generated with command: "+cmd+"\n")
			sleep(2)
			try
			{ 
				Parker_SendCommand(cmd, reply) // trying again
			}
			catch
			{
				self.print("level 2 error generated with command: "+cmd)
				debug("level 2 error generated with command: "+cmd+"\n")
				sleep(2)
				Parker_SendCommand(cmd, reply) // trying final time
				break
			}
			break
		}
		//self.print("Reply to command \""+cmd+"\" is "+reply)
		sleep(0.1)

		return reply
	}	
	
	void parkerTransfer_IPA(object self)
	{
		// *** public ***
		// constructor

		direction = 0 // unset
		timeout = 60
		accuracy = 0.15	

	}

	number driveFaulted(object self)
	{
		// if drive faulted, this means a major hardware problem
		// TODO: needs to be tested on real hardware
		if (self.sendCommand("?BIT9498") == "1")
			return 1
		else
			return 0
	}


	number killSwitchEngaged(object self)
	{
		if (self.sendCommand("?BIT8467") == "-1")
			return 1
		else
			return 0
	}

	void setKillSwitch(object self)
	{
		self.sendCommand("BIT8467=1")
		self.print("kill all moves bit set")
	}

	void resetKillSwitch(object self)
	{
		self.sendCommand("BIT8467=0")
		self.print("kill all moves bit reset to 0")
	}

	void setManualState(object self,string state)
	{
		// *** private ***
		parkerPositions.SaveCurrentState(state)
	}

	void turnOff(object self)
	{
		// *** private ***
		// turn off the motor to limit any vibration resulting from non-optimal PID tuning
		self.sendCommand("AXIS0 DRIVE OFF")
		self.print("parker off")
	}

	void turnOn(object self)
	{
		// *** private ***
		// turn motor back on
		self.sendCommand("AXIS0 DRIVE ON")
		self.print("parker on")
	}

	void setPositionTag(object self, string name, number coordinate)
	{
		// *** public ***
		// saves a default positions (as of now) to tags

		parkerPositions.savePosition(name,coordinate) // home position, without going through homing sequence
		self.print("saved position: "+name+" with coordinate: "+coordinate)

		// example positions
		//parkerPositions.savePosition("open_pecs",30) // location where arms can open in PECS
		//parkerPositions.savePosition("pickup_pecs",50) // location where open arms can be used to pickup sample
		//parkerPositions.savePosition("beforeGV",90) // location where open arms can be used to pickup sample
		//parkerPositions.savePosition("dropoff_sem",450) // location where sample gets dropped off (arms will open)
		//parkerPositions.savePosition("pickup_sem",450) // location where sample gets picked up
		//parkerPositions.savePosition("dropoff_pecs",50) // location where sample gets dropped off in PECS

	}

	number getCurrentPosition(object self)
	{
		// *** public ***
		// returns current position, adjusted for lead screw factor (PPU)
		
		// check if drive faulted
		if (self.driveFaulted()==1) 
		{
			self.print("drive faulted!")
			throw("drive faulted!")
		}


		number position
		position = val(self.sendCommand("?P12290"))/PPU
		
		
		if (direction == 2) // return position for moving in positive direction (motor on outside)
			return position
		else if (direction == 1)// return position for moving in negative direction (motor close to pecs chamber)
			return position*-1

	}

	void setMovingParameters(object self)
	{
		// *** private ***
		// set speed for normal movement between points
		//self.sendCommand("ACC 1000.000000") // lower this because it causes kill all motion errors when moving back to 0 (home)
		self.sendCommand("ACC 80.000000")
		self.sendCommand("DEC 1000.000000")
		//self.sendCommand("JRK 200.000000") // 
		self.sendCommand("JRK 100.000000")
		//self.sendCommand("VEL 400.000000") // set after long calibration, but may be too high when moving pos (back to home)
		self.sendCommand("VEL 100.000000")
		//self.sendCommand("VEL 25.000000") // testing for dovetail problems 2016-06-23
		self.sendCommand("stp 1000.000000")
	}

	void init(object self)
	{
		// *** public ***
		// initializes hardware with strings similar to ACR software
		
		// register with mediator
		myMediator = returnMediator()
		myMediator.registerTransfer(self)

		// load direction from tag
		object dir = alloc(persistentTag)
		dir.init("IPrep:parkerdirection:direction")
		direction = val(dir.get())
		if (direction == 2)
			self.print("direction: 2 (positive)")
		else if (direction == 1)
			self.print("direction: 1 (negative)")
		else
		{
			string er = "direction of parker system not set. direction read = "+direction
			self.print(er)
			throw(er)
		}

		// load positions from globaltags
		// #TODO: check that stage has been homed since last reboot
		parkerPositions = alloc(positionManager)
		self.restoreState()

		self.sendCommand("ECHO 1") // first send echo to set echo level
		self.sendCommand("prog0")
		//self.sendCommand("ECHO")
		//self.sendCommand("DETACH")
		//self.sendCommand("ATTACH MASTER0")
		//self.sendCommand("ATTACH SLAVE0 AXIS0 \"X\"")
		//self.sendCommand("ATTACH AXIS0 ENC0 DAC0 ENC0")
		//self.sendCommand("PPU X 1600.000000") // sets step size as function of lead screw lead
		//self.sendCommand("BIT8464=0") // Enable CW/CCW (versus Step/Dir)
		//self.sendCommand("BIT8468=1") // Enable Drive I/O
		//self.sendCommand("AXIS0 ON")
		//self.sendCommand("SLIM X0")
		//self.sendCommand("HLIM X0")
		//self.sendCommand("BIT16144=1") // Positive EOT Limit Level Invert
		//self.sendCommand("BIT16145=1") // Negative EOT Limit Level Invert
		//self.sendCommand("BIT16146=1") // Home Limit Level Invert
		//self.sendCommand("BIT8469=1") // Enable EXC Response
		//self.sendCommand("EXC X(0.5, -0.5)")
		//self.sendCommand("AXIS0 DRIVE ON")
		//self.sendCommand("BIT799=0") // HSINT Aborted
		//self.setMovingParameters()
		//self.sendCommand("BIT798=0") // HSINT Registered
		//self.sendCommand("C14=0.1") // set torque limit (in Nm)
		//save PPU (factor for encoder position to get to linear position)
		PPU = val(self.sendCommand("?P12375"))	
		//self.turnOff()
		
		// set torque limit to verified number
		self.sendCommand("TLM AXIS0 0.150")


		self.print("parker IPA initialized")

	}

	number consistencycheck(object self)
	{
		// see if position last saved in tags is different from what controller thinks
		if (abs(self.getCurrentPosition() - parkerPositions.getCurrentPosition())<accuracy)
			return 1
		else
			return 0
	}

	void home(object self)
	{
		// *** public ***
		// homes in negative direction at slow speed
		// only use when close to 0 (like, 29) since it returns immediately

		if (self.killSwitchEngaged()==1) 
		{
			self.print("kill switch engaged, cannot move, staying at "+state)
			throw("kill switch engaged, cannot move, staying at "+state)
		}
		
		self.print("homing..")

		self.turnOn()

		// these home commands are for homing in the negative direction (motor on end)
		//self.sendCommand("BIT16152=1") // Home Backup Enable
		//self.sendCommand("BIT16153=0") // Home Negative Edge Select
		//self.sendCommand("BIT16154=1") // Home Negative Final Direction
		//self.sendCommand("JOG HOMVF X1")
		//self.sendCommand("BIT799=0") // HSINT Aborted
		//self.sendCommand("BIT798=0") // HSINT Registered
		//self.sendCommand("JOG JRK X10.000000") // lower jerk for homing
		//self.sendCommand("JOG VEL X5.000000") // lower speed for homing
		//self.sendCommand("JOG HOME X-1") // HOMING COMMAND

		// these commands home in the positive direction (motor close to chamber)
		

		// set speed for normal movement between points
		self.sendCommand("jog ACC x100.000000") 
		self.sendCommand("jog DEC x100.000000")
		self.sendCommand("jog JRK x0.000000")
		self.sendCommand("jog VEL x25.000000")
		
		if (direction == 1)
			self.sendCommand("JOG HOME x1") //home in positive direction
		else if (direction == 2)
			self.sendCommand("JOG HOME x-1") //home in negative direction

		// save previous state
		laststate=state
		parkerPositions.saveLastState(laststate)
		
		// save current state
		self.setManualState("outofway")
		parkerPositions.saveCurrentPosition(0)

		self.print("homing, current pos: "+self.getCurrentPosition())
		
	}

	number movetoposition(object self, number setpoint)
	{
		// *** private ***
		// moves to coordinates as number. 

		if (self.killSwitchEngaged()==1) 
		{
			self.print("kill switch engaged, cannot move, staying at "+state)
			throw("kill switch engaged, cannot move, staying at "+state)
		}

		// safetychecks

		if (myMediator.getStageState() != "down")
		{
			self.print("safetycheck: trying to move parker when PECS stage is up")
			throw("safetycheck: trying to move parker when PECS stage is up")
		}

		if (setpoint > 150)
		{
			if (myMediator.getGVState() != "open")
			{
				self.print("safetycheck: trying to move beyond GV with GV closed")
				throw("safetycheck: trying to move beyond GV with GV closed")
			}
		}

		if (setpoint > 400)
		{
			if (myMediator.getSEMState() != "clear" & myMediator.getSEMState() != "pickup_dropoff")
			{
				self.print("safetycheck: SEM not in pickup_dropoff or clear and trying to move parker inside SEM chamber")
				throw("safetycheck: SEM not in pickup_dropoff or clear and trying to move parker inside SEM chamber")
			}
		}

		self.turnOn()

		self.setMovingParameters()
		number current_pos = self.getCurrentPosition()
		self.print("moveposition: going to move. current pos is: "+current_pos+", going to: "+setpoint)

		if (direction == 1)// go to setpoint in negative direction
		{
			self.sendCommand("X-"+setpoint)
		}
		else if (direction == 2)// go to setpoint in positive direction
		{
			self.sendCommand("X"+setpoint)
		}
			
		

		number i = 0
		while ((abs(setpoint-current_pos))>accuracy)
	    	{
	    		
	    		current_pos = self.getCurrentPosition()
	    		parkerPositions.saveCurrentPosition(current_pos)
			sleep(1)
	    		i++
	    		if (i>timeout)
	    		{
	    			self.print("warning, did not get to position. cur="+current_pos+", setp="+setpoint)
	    			throw("timeout. did not get to position. current pos: "+current_pos+", setp: "+setpoint)
	    			return 0
	    		}
	    		self.print("moveposition: current pos: "+current_pos+", setpoint: "+setpoint)
	    	}
		self.print("moveposition: arrived at: "+current_pos+", setpoint was: "+setpoint)
		
		return 1
	}

	void move(object self, string positionName)
	{
		// *** public ***
		// moves to position by name as defined in tag

		// get position coordinate from tag by name
		number pos
		pos = parkerPositions.getPosition(positionName)

		// store new state name
		string newstate = positionName
		
		// save last state name, both in object and in tag
		parkerPositions.saveLastState(state)
		laststate = state

		if (self.movetoposition(pos)==1) {
			parkerPositions.saveCurrentState(newstate)
			state=newstate
		} else {
			state="undefined"
			throw("did not get to desired position when trying to get to "+newstate+". last known state = "+laststate+"\n")
		}

	}

	string getCurrentState(object self)
	{
		// *** public ***

		return state
	}

	string getLastState(object self)
	{
		// *** public ***
		
		return laststate
	}

}




// --- testing parker system ---

//object aParkerTransfer = alloc(parkerTransfer)
//aParkerTransfer.setDefaultPositions()
//aParkerTransfer.init()
//aParkerTransfer.sendCommand("AXIS0 ON")
//aParkerTransfer.setManualState("outofway")
//result("parker current position is: "+aParkerTransfer.getCurrentPosition()+"\n")
//result("move to position, result is: "+aParkerTransfer.movetoposition(60)+"\n")
//aParkerTransfer.move("beforeGV")
//aParkerTransfer.move("pickup_pecs")
//aParkerTransfer.move("beforeGV")
//aParkerTransfer.move("pickup_sem")
//aParkerTransfer.home()
//result("parker current position is: "+aParkerTransfer.getCurrentPosition()+"\n")
//result("parker current state: "+aParkerTransfer.getCurrentState()+"\n")
//result("parker last state: "+aParkerTransfer.getLastState()+"\n")

//aParkerTransfer.sendCommand("?P12290")
//aParkerTransfer.sendCommand("?P12290")

