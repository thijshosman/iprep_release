// $BACKGROUND$

// rev2: as in demounit, includes extra steps when closing

class gripper_rev2:object
{

	string state
	number address, timeout, timeout_2
	string cmd,reply
	object gripperPersistance
	object myMediator


	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("GRIPPER", level, text)
	}

	void print(object self, string text)
	{
		result("Gripper: "+text+"\n")
		self.log(2,text)
	}
	
	void restoreState(object self)
	{
		// *** private ***
		// restore state from tags
		state = gripperPersistance.getState()
		self.print("Gripper: current state restored from tags is "+state)
	}

	void setManualState(object self,string newstate)
	{
		// *** private ***
		// overwrite sensor state information
		gripperPersistance.SetState(newstate)
		state = newstate
		self.print("state now "+state)
	}

	string sendCommand(object self, string command)
	{
		// *** private ***
		// sends command to allmotion controller at address and receives reply
		cmd = command
		if (cmd == "")
			{
				throw("allmotion command string empty")
			}
		reply = ""
		Allmotion_SendCommand(address, cmd, reply)
		//result("\nALLMOTION GRIPPER: Reply to command \""+cmd+"\" is "+reply+"\n")
		return reply
	}

	number readSensor(object self)
	{
		// *** private ***
		// read sensor and get number back
		number sensorStateInt
		sensorStateInt = val(self.sendCommand("?4"))
		/*		Returns the status of all four inputs, 0-15 representing a 4-
				bit binary pattern.
				Bit 0 = Switch1 Bit 1 = Switch2
				Bit 2 = Opto 1 Bit 3 = Opto 2
		*/
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
		string bitStr_extra
		bitStr = self.sensorToBitStr()
		bitStr_extra = self.sensorToBitStr()
		
		if (bitStr != bitStr_extra)
			self.print("warning, 2 sensor reads not equal: "+bitStr+", "+bitStr_extra)

		//self.print(bitStr)

		number open 
		open = val(chr(bitStr[1]))
		//result("open: "+open+"\n")

		number close
		close = val(chr(bitStr[0]))
		//result("close: "+close+"\n")

		if (open == 1 && close == 0)
			state = "open"
		else if (open == 0 && close == 1)
			state = "closed"
		else if (open == 1 && close == 1)
			state = "inbetween"
		else
		{
			state = "invalid"
			//throw("invalid state, open and closed sensors engaged at the same time")
		}

		if (view == 1)
			self.print("GRIPPER: bitstr: "+bitStr+", current state is "+state+"; individual sensors: open: "+open+", close: "+close)
		
	}

	string lookupStateNTimes(object self, number n)
	{
		// *** private ***
		// check state from sensor input n times
		string bitStr
		number open1
		number closed1

		//bitStr = self.sensorToBitStr()

		number i
		for (i=0; i<n; i++)
		{
			bitStr = self.sensorToBitStr()
			open1 = open1 + val(chr(bitStr[1]))
			closed1 = closed1 + val(chr(bitStr[0]))
		}
		
		number openSum = open1/n
		number closedSum = closed1/n 

		self.print("sum of "+n+" readings. open: "+openSum+", closed: "+closedSum)

		if (openSum == 1 && closedSum != 1) // assume open
		{
			return "open"	
		}
		else if (closedSum == 1 && openSum != 1) // assume closed
		{
			return "closed"
		}
		else
		{
			return "undefined"
		}

	}

	void init(object self)
	{
		// *** public ***
		// sends some strings to controller to initialize

		// register with mediator
		myMediator = returnMediator()
		myMediator.registerGripper(self)

		// set string 2 in controller, executed after close
		
		//old string, moves back, not used
		//self.sendCommand("s2D10000R")
		//self.sendCommand("s2T")
		// set speed
		//self.sendCommand("V300000")
		// set acc
		//self.sendCommand("L1400")
		// set holding current
		//self.sendCommand("h0")
		// set running current
		//self.sendCommand("m46")

		// set all operating parameters
		self.sendCommand("s2T")
		self.sendCommand("V300000L1400h0m25j64R")

		// set all operating parameters
		// new because of closing failure 2016-08-24
		//self.sendCommand("s2T")
		//self.sendCommand("V300000L1400h0m35j64R")

		self.print("gripper initialized")
	}

	void gripper_rev2(object self) 
	{
		// constructor, looks up state for first time and sets some parameters
		gripperPersistance = alloc(statePersistance)
		gripperPersistance.init("gripper")
		self.restoreState()
		
		address = 1 // change back, is 1 on Manchester system
		timeout = 10

	}

	void open_once(object self)
	{
		// *** public ***
		// opens gripper if closed
		//if (state == "closed")
		{
			// run until home sensor (back) gets triggered
			self.sendCommand("T")
			self.sendCommand("Z1000000000R")
			number i = 0
			self.print("opening")
			while (state != "open")
			{
				i++
				//result("i: "+i+"\n")
				self.lookupState(0)
				sleep(0.5)
				if (i>timeout)
				{
					// send hard terminate
					self.sendCommand("T")
					self.sendCommand("T")
					self.log(4,"gripper did not open")	
					throw("gripper did not open")
					break
				}
			}

			self.setManualState("open")
			
			// send hard terminate
			self.sendCommand("T")
			self.sendCommand("T")

			sleep(0.1)
			return
		}
		
	}

	void close_once(object self)
	{
		// *** public ***
		// closes gripper if open
		//if (state == "open")
		{
			// run until sensor 2 (front) is triggered in 10000 step increments, then go to string 2
			self.sendCommand("T")
			self.sendCommand("gP10000S04e2G10000R")
			number i = 0
			self.print("closing")
			while (state != "closed")
			{
				i++
				//result("i: "+i+"\n")
				self.lookupState(0)
				sleep(0.5)
				
				//disable timeout, thijs 05/28
				if (i>timeout)
				{
					// send hard terminate
					self.sendCommand("T")
					self.sendCommand("T")	
					self.log(4,"gripper did not close")				
					throw("gripper did not close")
					break
				}
			}
			
			// worked until 2016-06-22 in vacuum
			//self.sendCommand("gP70000R")
			//self.sendCommand("gP20000R")

			// 2016-06-23
			//self.sendCommand("gP70000R")

			// 2016-06-23 -2
			//self.sendCommand("gP60000R")

			// 2016-06-23 -3
			//self.sendCommand("gP65000R")
			//self.sendCommand("gP10000R")

			// 2016-06-29
			//self.sendCommand("gP75000R")
			//self.sendCommand("gD10000R")

			// 2016-08-12
			self.sendCommand("gP75000R")
			self.sendCommand("gD30000R")

			self.setManualState("closed")
			self.print("gripper closed succesfully")

			// send hard terminate
			self.sendCommand("T")
			self.sendCommand("T")			

			sleep(0.1)
			return
		}
		
	}

	void open(object self)
	{
		try
			self.open_once()
		catch
		{
			self.print("Gripper failed to open first time, closing and trying one more time.\n")
			self.close_once()
			self.open_once()
			break
		}

		// check if state is really what it is supposed to be; if not, try again, if it fails again, throw exception
		sleep(2)
		if (self.lookupStateNTimes(5) != "open")
		{
			self.print("opening failed first time, trying again")
			self.open_once()
			self.lookupState(0)
			if (state != "open")
				throw("gripper does not reflect open state after 2 tries")
			else
				self.print("now opening succeeded")	
		}

	}


	void close(object self)
	{
		try
			self.close_once()
		catch
		{
			self.print("Gripper failed to close first time, opening and trying one more time.\n")
			self.open_once()
			self.close_once()
			break
		}
		// check if state is really what it is supposed to be; if not, try again, if it fails again, throw exception
		
		if (self.lookupStateNTimes(5) != "closed")
		{
			self.print("closing failed first time, trying again after 10 seconds")
			sleep(10)
			self.open_once()
			self.close_once()
			self.lookupState(0)
			if (state != "closed")
				throw("gripper does not reflect closed state after 2 tries")
			else
				self.print("now closing succeeded")
		}
	}


	string getState(object self)
	{
		// *** public ***
		// returns state
		return state
	}

	string getGripperState(object self)
	{
		// for Mediator
		return self.getState()
	}


	~gripper_rev2 (object self)
	{
		// store last known state as tag
		self.setManualState(state)
	}

}

// *** testing the class ***

//object aGripper = alloc(gripper)
//aGripper.init()
//aGripper.setManualState("open")
//result("Gripper state is: "+aGripper.getState()+"\n")
//aGripper.openHalfway()
//aGripper.open()
//result("Gripper state is: "+aGripper.getState()+"\n")
//aGripper.close()
//result("Gripper state is: "+aGripper.getState()+"\n")

//result("bitstr start:"+aGripper.sensorToBitStr()+"\n")


//open
//aGripper.sendCommand("Z1000000000R")
//sleep(10)
//result("bitstr opened: "+aGripper.sensorToBitStr()+"\n")

//close
//aGripper.sendCommand("gP10000S04e2G10000R")
//sleep(10)
//result("bitstr closed: "+aGripper.sensorToBitStr()+"\n")

//result("sensor input: "+aGripper.sensorToBitStr()+"\n")
//result("sensor input: "+aGripper.getStateFromSensor()+"\n")
//result("Gripper state is: "+aGripper.getState()+"\n")



