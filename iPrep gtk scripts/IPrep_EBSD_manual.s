// $BACKGROUND$

class EBSD_manual: object
{
	// give control to the EBSD system and hand it back over to the workflow when done
	string sitename
	string data_prefix
	number type // (1 is electron, 2 is eds, 4 is ebsd (which may also have eds enabled))

	number err
	number progress

	// manual specific
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


	number returnProgress(object self)
	{
		return 1
	}

	number returnError(object self)
	{
		return err
	}

	void init(object self)
	{
		self.print("Manual EBSD Acquisition initialized")
	}


	void init(object self, string sitename1, string prefix1, number type1)
	{
		sitename = sitename1
		data_prefix = prefix1
		type = type1
		self.print("site name: "+sitename+", filename prefix: "+data_prefix+", type: "+type)
		self.init()
	}

	void EBSD_start(object self)
	{
		busy = 1
		okdialog("start the EBSD acquisition. press OK when done")
		busy = 0
	}

	void EBSD_stop(object self)
	{
		self.print("Acquisition stopped")
	}

	number isBusy(object self)
	{
		return busy
	}

}







