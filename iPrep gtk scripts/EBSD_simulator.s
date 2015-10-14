// $BACKGROUND$

class EBSD_simulator: object
{
	// give control to the EBSD system and hand it back over to the workflow when done

	number EBSD_start(object self)
	{
		result("EBSD acquiring...\n")
		sleep(4)
		result("EBSD acquisition done \n")
		return 1
	}

/*
	number EBSD_finished(object self)
	{
		return 1
	}
*/
}







