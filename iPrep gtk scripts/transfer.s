// $BACKGROUND$
class positionManager: object
{
	
	// TODO: detect kill switch in parker software and throw error if set
	
	number savePosition(object self, string positionName, number position)
	{
		//save (or overwrite) position with name
		TagGroupSetTagAsNumber(GetPersistentTagGroup(),"IPrep:parkerpositions:"+positionName,position)
	}
	
	TagGroup getStoredPositions(object self)
	{
		//return taglist of all stored positions
		TagGroup tg = GetPersistentTagGroup() 
		TagGroup subtag
		tg.TagGroupGetTagAsTagGroup( "IPrep:parkerpositions", subtag )
		return subtag
	}
	


	number getPosition(object self, string positionName)
	{
		//return position based on name of tag and throws error if it does not exist
		number position
		taggroup subtag = self.getStoredPositions()
		if (TagGroupDoesTagExist(subtag,positionName)) {
			TagGroupGetTagAsNumber(subtag,positionname,position)
			return position
		} else {
			throw("tag"+positionName+"does not exist")
		}
	}

	void saveLastState(object self, string laststate)
	{
		TagGroupSetTagAsString(GetPersistentTagGroup(),"IPrep:parkerState:lastState",laststate)	
	}

	void saveCurrentState(object self, string currentstate)
	{
		TagGroupSetTagAsString(GetPersistentTagGroup(),"IPrep:parkerState:currentState",currentstate)
	}
	
	void saveCurrentPosition(object self, number current)
	{
		TagGroupSetTagAsNumber(GetPersistentTagGroup(),"IPrep:parkerState:currentPosition",current)
	}
	
	string getCurrentState(object self)
	{
		TagGroup tg = GetPersistentTagGroup() 
		string current
		TagGroupGetTagAsString(tg,"IPrep:parkerState:currentState", current )
		return current
	}

	string getLastState(object self)
	{
		TagGroup tg = GetPersistentTagGroup() 
		string current
		TagGroupGetTagAsString(tg,"IPrep:parkerState:lastState", current )
		return current
	}

}


// --- testing positionmanager ---

//object apositionManager = alloc(positionManager)
//apositionManager.savePosition("testposition3",33)
//taggroup currentPositions
//currentPositions = apositionManager.getStoredPositions()
//currentPositions.TagGroupOpenBrowserWindow( 0 ) 

//number pos
//pos = apositionManager.getPosition("testposition3")
//result("\n"+pos+"\n")
//apositionManager.saveCurrentState("teststate")
//apositionManager.saveLastState("teststate")
//result(apositionManager.getCurrentState())

// --- end testing positionmanager ---

class parkerTransfer:object
{
	// manages transfers of the parker system between discrete positions
	// max parker position is 545 mm

	object parkerPositions // manages positions in tags

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
			Parker_SendCommand(cmd, reply)
		break
		}
		//self.print("Reply to command \""+cmd+"\" is "+reply)
		sleep(0.1)
		return reply
	}	
	
	void parkerTransfer(object self)
	{
		// *** public ***
		// constructor

		
		timeout = 60
		accuracy = 0.15
	
		// load positions from globaltags
		parkerPositions = alloc(positionManager)
		self.restoreState()
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
		number position
		position = val(self.sendCommand("?P12290"))/PPU
		return position

	}

	void setMovingParameters(object self)
	{
		// *** private ***
		// set speed for normal movement between points
		self.sendCommand("ACC 50.000000")
		self.sendCommand("DEC 50.000000")
		self.sendCommand("JRK 20.000000")
		self.sendCommand("VEL 80.000000")
	}



	void init(object self)
	{
		// *** public ***
		// initializes hardware with strings similar to ACR software
		self.sendCommand("ECHO 1") // first send echo to set echo level
		self.sendCommand("prog0")
		self.sendCommand("ECHO")
		self.sendCommand("DETACH")
		self.sendCommand("ATTACH MASTER0")
		self.sendCommand("ATTACH SLAVE0 AXIS0 \"X\"")
		self.sendCommand("ATTACH AXIS0 ENC0 DAC0 ENC0")
		self.sendCommand("PPU X 1600.000000") // sets step size as function of lead screw lead
		self.sendCommand("BIT8464=0") // Enable CW/CCW (versus Step/Dir)
		self.sendCommand("BIT8468=1") // Enable Drive I/O
		self.sendCommand("AXIS0 ON")
		self.sendCommand("SLIM X0")
		self.sendCommand("HLIM X0")
		self.sendCommand("BIT16144=1") // Positive EOT Limit Level Invert
		self.sendCommand("BIT16145=1") // Negative EOT Limit Level Invert
		self.sendCommand("BIT16146=1") // Home Limit Level Invert
		self.sendCommand("BIT8469=1") // Enable EXC Response
		self.sendCommand("EXC X(0.5, -0.5)")
		self.sendCommand("AXIS0 DRIVE ON")
		self.sendCommand("BIT799=0") // HSINT Aborted
		self.setMovingParameters()
		self.sendCommand("BIT798=0") // HSINT Registered
		self.sendCommand("JOG ACC X50.000000")
		self.sendCommand("JOG DEC X50.000000")
		self.sendCommand("JOG JRK X20.000000")
		self.sendCommand("JOG VEL X40.000000")
		self.sendCommand("C14=0.1") // set torque limit (in Nm)
		//save PPU (factor for encoder position to get to linear position)
		PPU = val(self.sendCommand("?P12375"))	
		self.turnOff()
		
		self.print("parker initialized")

	}



	void home(object self)
	{
		// *** public ***
		// homes in negative direction at slow speed
		// only use when close to 0 (like, 29) since it returns immediately

		if (self.killSwitchEngaged()==0) 
		{

			self.print("homing..")

			self.turnOn()
			self.sendCommand("BIT16152=1") // Home Backup Enable
			self.sendCommand("BIT16153=0") // Home Negative Edge Select
			self.sendCommand("BIT16154=1") // Home Negative Final Direction
			self.sendCommand("JOG HOMVF X1")
			self.sendCommand("BIT799=0") // HSINT Aborted
			self.sendCommand("BIT798=0") // HSINT Registered
			self.sendCommand("JOG JRK X10.000000") // lower jerk for homing
			self.sendCommand("JOG VEL X5.000000") // lower speed for homing
			self.sendCommand("JOG HOME X-1") // HOMING COMMAND

			// save previous state
			laststate=state
			parkerPositions.saveLastState(laststate)
			
			// save current state
			self.setManualState("outofway")
			parkerPositions.saveCurrentPosition(0)

			self.print("homing, current pos: "+self.getCurrentPosition())
		}
		else
		{
			self.print("kill switch engaged, cannot move, staying at "+state)
			throw("kill switch engaged, cannot move, staying at "+state)
		}
	}
	
	number movetoposition(object self, number setpoint)
	{
		// *** private ***
		// moves to coordinates as number. 
		

		self.turnOn()

		self.setMovingParameters()
		number current_pos = self.getCurrentPosition()
		self.print("moveposition: going to move. current pos is: "+current_pos+", going to: "+setpoint)
		// go to setpoint
		self.sendCommand("X"+setpoint)
		
		number i=0
		current_pos = self.getCurrentPosition()
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



		if (self.killSwitchEngaged()==0) 
		{
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
		} else
		{
			self.print("kill switch engaged, cannot move, staying at "+state)
			throw("kill switch engaged, cannot move, staying at "+state)
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

