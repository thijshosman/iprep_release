// $BACKGROUND$

class EBSD_simulator: object
{
	string sitename
	string data_prefix
	number type // (1 is electron, 2 is eds, 4 is ebsd (which may also have eds enabled))

	number err
	number progress

	// simulator specific
	number max_iterations
	number i

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
		return i/max_iterations
	}

	number returnError(object self)
	{
		return err
	}

	void init(object self)
	{
		max_iterations = 5
		i=0
		self.print("simulator initialized")
		self.print("running simulator for "+max_iterations+" iterations")
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
		// start EBSD acquisition
		self.print("Acquisition started")
	}

	void EBSD_stop(object self)
	{
		self.print("Acquisition stopped")
	}

	number isBusy(object self)
	{
		i = i + 1
		if (i>max_iterations)
			return 0 // still 'busy'
		else
			return 1 // done
	}






}







