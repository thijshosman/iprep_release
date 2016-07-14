// $BACKGROUND$
class planarSEMdock : object 
{
	string state // unclamped (for transfer etc) or clamped (imaging, moving) or inbetween
	number sampleStatus // 1 means sample present
	number address // 2 by default
	number timeout // time allowed to take to get to intended position
	string cmd,reply
	object SEMdockPersistance
	
	object myMediator

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

	string detectMode(object self)
	{
		// *** private ***
		// detects mode based on the encoder signal used as input
		// ebsd = CH_A to ground (bit1)
		// planar = CH_B to ground (bit2)
		string mode = "undefined"

		number encSensorState = val(self.sendCommand("?a4"))
		string senStr = binary(encSensorState,8) // 8 is length of binary word

		number bit_1 = val(chr(senStr[2]))
		number bit_2 = val(chr(senStr[3]))

		self.print("dock detection: sensor = "+senStr+", value="+encSensorState+", bit1="+bit_1+", bit2="+bit_2)

		if (bit_1 == 0 && bit_2 == 1)
		{
			mode = "ebsd"
		}
		else if (bit_1 == 1 && bit_2 == 0)
		{
			mode = "planar"
		}
		else if (bit_1 == 1 && bit_2 == 1)
		{
			mode = "disconnected"
			self.print("dock disconnected")
			return mode
			//throw("dock disconnected. sensor = "+senStr+", value="+encSensorState+", bit1="+bit_1+", bit2="+bit_2)
		} 
		else 
		{
			return mode
			//throw("dock mode is not detected. sensor = "+senStr+", value="+encSensorState+", bit1="+bit_1+", bit2="+bit_2)
		}

		self.print(mode+" dock detected")
		return mode

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

		// register with mediator
		myMediator = returnMediator()
		myMediator.registerDock(self)

		// set string 2 in controller, executed after close
		self.sendCommand("s2TR")
		// set current (2x), speed (2x), holding current, acc

		// changed to m27, I27 instead of 16 in order to overcome some stickyness
		//self.sendCommand("m30h0I27L24V10000v2500R")
		
		// thijs update 11/26/2015 after spring increased force
		//self.sendCommand("m30h0l27L10000V4000R")

		// thijs update 2016-06-20 after testing with new PA-built unit
		self.sendcommand("m30h0I27L10000V2000j64R")

		self.sendCommand("T")
		self.print("dock initialized (planar)")
	}
	
	void hold(object self)
	{
		// set holding torque to finite value to make sure motor does not move
		self.sendcommand("h15R")
		self.print("holding torque SET")
	}

	void unhold(object self)
	{
		// set holding torque to finite value to make sure motor does not move
		self.sendcommand("h0R")
		self.print("holding torque UNSET")
	}


	void PLANARsemDOCK(object self) 
	{
		// contructor
		SEMdockPersistance = alloc(statePersistance)
		SEMdockPersistance.init("SEMdock")
		address = 2 // 1 is gripper, 2 is dock on iprep manchester. 
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
		{
			self.unclamp_once()
			sleep(1)
			self.sendCommand("h0R")
		}
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

	string getDockState(object self)
	{
		// for Mediator
		return self.getState()
	}

	number checkSamplePresent(object self)
	{
		// *** public ***
		// checks if sample is present

		self.lookupState(0)
		return sampleStatus

	}

	void camOn(object self)
	{
		// turn chamberscope camera and aillumination on
		self.sendCommand("J4R")
		self.print("chamberscope turned ON")
	}


	void camOff(object self)
	{
		// turn chamberscope camera and aillumination on
		self.sendCommand("J0R")
		self.print("chamberscope turned OFF")
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




