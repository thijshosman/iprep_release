// $BACKGROUND$

class EBSD_manual: object
{
	// give control to the EBSD system and hand it back over to the workflow when done

	number busy

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

	void init(object self)
	{
		self.print("Manual EBSD Acquisition initialized")
	}

	void EBSD_start(object self)
	{
		busy = 1
		okdialog("start the EBSD acquisition. press OK when done")
		busy = 0
		return // success, give control back to workflow

	}

	number isBusy(object self)
	{
		return busy

	}

}







