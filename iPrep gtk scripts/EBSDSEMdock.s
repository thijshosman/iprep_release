// $BACKGROUND$
class EBSDSEMdock : object 
{
	string state // unclamped (for transfer etc) or clamped (imaging, moving) or inbetween
	number sampleStatus // 1 means sample present
	number address // 2 by default
	number timeout // time allowed to take to get to intended position
	string cmd,reply
	object SEMdockPersistance
	

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("DOCK", level, text)
	}

	void print(object self, string text)
	{
		// print to console output. also log as info
		result("SEMdock: "+text+"\n")
		self.log(2,text)
	}

	string sendCommand(object self, string command)
	{
		// *** private ***
		// send generic command and get reply

		cmd = command
		if (cmd == "")
			{
				throw("allmotion command string empty")
			}
		reply = ""
		Allmotion_SendCommand(address, cmd, reply)
		//result("\nALLMOTION DOCK: Reply to command \""+cmd+"\" is "+reply+"\n")
		return reply
	}

	number readSensor(object self)
	{
		// *** private ***
		// read sensor and get number back
		number sensorStateInt
		sensorStateInt = val(self.sendCommand("?4"))
		return sensorStateInt
	}

	string sensorToBitStr(object self)
	{
		// *** private ***
		// read the sensor and get bits back

		number sensorStateInt
		sensorStateInt = self.readSensor()
		string errStr = binary(sensorStateInt,4) // 4 is the length of the string
		return errStr
		//result("\n"+errStr)
	}


	void lookupState(object self, number view)
	{
		// *** private ***
		// check state from sensor input
		string bitStr
		bitStr = self.sensorToBitStr()

		number pogo 
		pogo = val(chr(bitStr[2]))

		if (pogo == 0)
			sampleStatus = 1
		else
			sampleStatus = 0

		number upsw 
		upsw = val(chr(bitStr[3]))

		number downsw
		downsw = val(chr(bitStr[1]))

		if (downsw == 0 && upsw == 1)
			state = "clamped"
		else if (downsw == 1 && upsw == 0)
			state = "unclamped"
		else 
			state = "inbetween"

		if (view == 1)
			self.print("current state is "+state+", individual sensors: up: "+upsw+", down: "+downsw+", pogo: "+pogo)
		
	}
	
	void init(object self)
	{
		// *** public ***
		// set string 2 in controller, executed after close
		self.sendCommand("s2TR")
		// set current (2x), speed (2x), holding current, acc

		// changed to m27, I27 instead of 16 in order to overcome some stickyness
		//self.sendCommand("m30h0I27L24V10000v2500R")
		
		// thijs update 10/02/2015 when testing ebsd dock
		self.sendCommand("m30h0l27L10000V5000R")
		self.print("dock initialized")
	}
	
	void EBSDSEMdock(object self) 
	{
		// contructor
		SEMdockPersistance = alloc(statePersistance)
		SEMdockPersistance.init("SEMdock")
		address = 1 // 1 is gripper, 2 is dock on iprep. 
		timeout = 30
		self.lookupState(1)

	}


	void setManualState(object self,string newstate)
	{
		// *** private ***
		state = newstate
		self.print("state manually set. state is: "+state)
	}


	void unclamp_once(object self)
	{
		// *** public ***
		// moves dock up (unclamped position)

		self.print("going up, unclamping, current state is: "+state)	
		if (state == "clamped" || state == "inbetween")
		{
			SEMdockPersistance.setState("inbetween")
			// run until sensor gets triggered
			self.sendCommand("gD800S11e2G10000R")
			sleep(0.5)
			number i = 0
			while(state != "unclamped")
			{
				i++
				self.lookupState(0)
				sleep(0.1)
				if (i>10*timeout)
				{
					self.sendCommand("T")
					self.log(5,"dock does unclamp")
					throw("dock does unclamp")
					break
				}

			}
			self.sendCommand("T")
			self.lookupState(1)
			return
		}
	}

	void clamp_once(object self)
	{
		// *** public ***
		// moves dock down (clamped position)

		self.print("going down, clamping, current state is: "+state)	
		if (state == "unclamped" || state == "inbetween")
		{
			SEMdockPersistance.setState("inbetween")
			// run until sensor is triggered 
			self.sendCommand("gP800S13e2G10000R")
			sleep(0.5)
			number i = 0
			while(state != "clamped")
			{
				i++
				self.lookupState(0)
				sleep(0.1)
				if (i>10*timeout)
				{
					self.sendCommand("T")
					self.log(4,"dock does clamp")
					throw("dock does not clamp")
					break
				}
			}
			self.sendCommand("T")
			self.lookupState(1)
			return
		}
	}

	void Unclamp(object self)
	{
		try
			self.unclamp_once()
		catch
		{
			self.print("Dock failed to unclamp first time, will clamp and trying to unclamp one more time.\n")
			self.clamp_once()
			self.unclamp_once()
			break
		}
		SEMdockPersistance.setState("unclamped")
	}


	void Clamp(object self)
	{
		try
			self.clamp_once()
		catch
		{
			self.print("Dock failed to clamp first time, will unclamp and trying to clamp one more time.\n")
			self.unclamp_once()
			self.clamp_once()
			break
		}
		SEMdockPersistance.setState("clamped")
	}



	string getState(object self)
	{
		// *** public ***
		// returns current state

		self.lookupState(0)
		return state
	}

	number checkSamplePresent(object self)
	{
		// *** public ***
		// checks if sample is present

		self.lookupState(1)
		return sampleStatus

	}



}



//object aplanarSEMdock = alloc(planarSEMdock)

//aplanarSEMdock.init()

//aplanarSEMdock.setManualState("up")

//aplanarSEMdock.goUp()
//result("sensor input: "+aplanarSEMdock.sensorToBitStr()+"\n")
//result("current state: "+aplanarSEMdock.getState()+"\n")
//sleep(5)
//aplanarSEMdock.goDown()
//result("current state: "+aplanarSEMdock.getState()+"\n")

//result("sample present: "+aplanarSEMdock.checkSamplePresent()+"\n")




