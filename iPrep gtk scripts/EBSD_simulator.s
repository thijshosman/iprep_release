// $BACKGROUND$

class EBSD_simulator: object
{
	// give control to the EBSD system and hand it back over to the workflow when done
	number busy

	void init(object self)
	{
		result("EBSD: simulator initialized\n")
	}

	void EBSD_start(object self)
	{
		result("EBSD simulator acquiring...\n")
		busy = 1
		sleep(4)
		result("EBSD simulator acquisition done \n")
		busy = 0
		return
	}

	number isBusy(object self)
	{
		return busy

	}

}







