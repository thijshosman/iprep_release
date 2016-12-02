// $BACKGROUND$
class statusCheck : thread
{ 
	// this class launches itself as a thread to check the PECS for problems

	number i
	number halt

	object init(object self)   
	{     
		i=0
		halt=0	
		return self   
	}   

	void stop(object self)
	{
		result("stop signal sent\n")
		i=1
	}

	void RunThread(object self)   
	{     

		while(i == 0)
		{
			if(!IPrep_continous_check())
			{	
				result("check: level 1 check triggered\n")
				// if this triggers, wait and check again to make sure this is no false positive due to valve actuation
				sleep(2)
				if (!IPrep_continous_check())
				{
					result("check: level 2 check triggered\n")
					sleep(3)
					if(!IPrep_continous_check())
					{	
						halt=1
						result("check: level 3 check triggered, halting\n")
					}
				}
				
			} 

			if(halt==1)
			{
				// TODO: this should turn HV off now that we are not turning it off between slices

				result("check: failed\n")
				IPrep_Abort()
				self.stop()
				//throw("check failed") // throwing does not work
			}
			sleep(5)
		}
		result("thread stopped\n")
	}   
}

// testing statusCheck

//	thread1 = alloc(statusCheck)
//	thread1.init().StartThread()