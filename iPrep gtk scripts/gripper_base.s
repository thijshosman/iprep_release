// gripper abstract base class
class gripper_base:object
{

	string state
	number address, timeout
	string cmd,reply
	object gripperPersistance


	void log(object self, number level, string text)
	{
		
	}

	void print(object self, string text)
	{
		
	}
	
	void restoreState(object self)
	{
		// *** private ***
		
	}

	void setManualState(object self,string newstate)
	{
		// *** private ***
		
	}

	string sendCommand(object self, string command)
	{
		// *** private ***
		return ""
	}

	number readSensor(object self)
	{
		// *** private ***
		
		return 0
	}

	string sensorToBitStr(object self)
	{
		// *** private ***
		// read the sensor and get bits back

		return ""
		
	}

	void lookupState(object self, number view)
	{
		// *** private ***
		
	}

	void init(object self)
	{
		// *** public ***
		
	}

	void gripper(object self) 
	{
		// constructor, looks up state for first time and sets some parameters
		
	}

	void open_once(object self)
	{
		// *** public ***
		
	}

	void close_once(object self)
	{
		// *** public ***
		
	}

	void open(object self)
	{
		
	}


	void close(object self)
	{
		
	}


	string getState(object self)
	{
		// *** public ***
		
	}

	~gripper (object self)
	{
		// store last known state as tag
		
	}

}

