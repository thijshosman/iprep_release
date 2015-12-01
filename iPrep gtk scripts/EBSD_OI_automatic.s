// $BACKGROUND$

class EBSD_OI_automatic: object
{

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("EBSD", level, text)
	}

	void print(object self, string str1)
	{
		result("EBSD: "+str1+"\n")
		self.log(2,str1)
	}



	// give control to the EBSD system and hand it back over to the workflow when done
	number timeout
	
	void init(object self)
	{
		self.print("Oxford Instruments EBSD Handshake initialized")

	}

	void EBSD_start(object self)
	{
		// start EBSD acquisition
		EBSD_StartAcquisition()
		self.print("EBSD Acquisition started")
	}

	number isBusy(object self)
	{
		return EBSD_IsAcquisitionBusy()

	}



}







