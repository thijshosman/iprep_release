// $BACKGROUND$

class EBSD_simulator: object
{
	// give control to the EBSD system and hand it back over to the workflow when done

	void init(object self)
	{
		//
	}

	number EBSD_start(object self)
	{
		result("EBSD simulator acquiring...\n")
		sleep(4)
		result("EBSD simulator acquisition done \n")
		return 1
	}

/*
	number EBSD_finished(object self)
	{
		return 1
	}
*/
}







