// $BACKGROUND$
class gripper_simulator:object
{

	string state
	number address, timeout
	string cmd,reply
	object gripperPersistance


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







	void init(object self)
	{
		// *** public ***
		// sends some strings to controller to initialize


		self.print("initialized")
	}

	void gripper_simulator(object self) 
	{
		// constructor, looks up state for first time and sets some parameters
		gripperPersistance = alloc(statePersistance)
		gripperPersistance.init("gripper")
		self.restoreState()
		
		address = 1
		timeout = 30

	}

	void open_once(object self)
	{
		// *** public ***
		// opens gripper if closed
		if (state == "closed")
		{
			self.setManualState("open")
			return
		}
		
	}

	void close_once(object self)
	{
		// *** public ***
		// closes gripper if open
		if (state == "open")
		{
			self.setManualState("closed")
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
	}


	string getState(object self)
	{
		// *** public ***
		// returns state
		return state
	}
/*
	~gripper (object self)
	{
		// store last known state as tag
		self.setManualState(state)
	}
*/
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



