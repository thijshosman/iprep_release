// $BACKGROUND$
class planarSEMdock : object 
{
	string state // up or down
	number sampleStatus // 1 means sample present
	number address // 2 by default
	number timeout // time allowed to take to get to intended position
	string cmd,reply
	//object SEMdockPersistance
	

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
			state = "down"
		else if (downsw == 1 && upsw == 0)
			state = "up"
		else 
			state = "inbetween"

		if (view == 1)
			self.print("current state is "+state+", individual sensors: up: "+upsw+", down: "+downsw+", pogo: "+pogo)
		
	}
	
	void init(object self)
	{
		// *** public ***
		// set string 2 in controller, executed after close
		self.sendCommand("s2T")
		// set current (2x), speed (2x), holding current, acc

		// changed to m27, I27 instead of 16 in order to overcome some stickyness
		self.sendCommand("m30h0I27L24V10000v2500R")
		self.print("dock initialized")
	}
	
	void PLANARsemDOCK(object self) 
	{
		// contructor
		//object gripperPersistance = alloc(statePersistance)
		//SEMdockPersistance.init("SEMdock")
		address = 2
		timeout = 30
		self.lookupState(1)
		self.init()
	}


	void setManualState(object self,string newstate)
	{
		// *** private ***
		state = newstate
		self.print("state manually set. state is: "+state)
	}


	void goUp_once(object self)
	{
		// *** public ***
		// moves dock up (loading position)

		self.print("going up, current state is: "+state)	
		if (state == "down")
		{
			// run until sensor gets triggered
			self.sendCommand("gD800S11e2G10000R")
			sleep(0.5)
			number i = 0
			while(state != "up")
			{
				i++
				self.lookupState(0)
				sleep(0.1)
				if (i>10*timeout)
				{
					self.sendCommand("T")
					self.log(5,"dock does not go up")
					throw("dock does not get to up")
					break
				}

			}
			self.lookupState(1)
			return
		}
	}

	void goDown_once(object self)
	{
		// *** public ***
		// moves dock down (imaging/moving SEM Stage position)

		self.print("going down, current state is: "+state)	
		if (state == "up" || state == "inbetween")
		{
			// run until sensor is triggered 
			self.sendCommand("gP800S13e2G10000R")
			sleep(0.5)
			number i = 0
			while(state != "down")
			{
				i++
				self.lookupState(0)
				sleep(0.1)
				if (i>10*timeout)
				{
					self.sendCommand("T")
					self.log(4,"dock does not go down")
					throw("dock does not get to down")
					break
				}

			}
			self.lookupState(1)
			return
		}
	}

	void goUp(object self)
	{
		try
			self.goUp_once()
		catch
		{
			self.print("Dock failed to go up first time, going down and trying one more time.\n")
			self.goDown_once()
			self.goUp_once()
			break
		}
	}


	void goDown(object self)
	{
		try
			self.goDown_once()
		catch
		{
			self.print("Dock failed to go down first time, going up and trying one more time.\n")
			self.goUp_once()
			self.goDown_once()
			break
		}
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




