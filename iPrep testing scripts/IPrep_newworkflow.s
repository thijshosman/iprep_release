// proposed workflow routine

class iprep_loop_i: object
{
	number i // iterator
	number p // number of steps in one cycle

	void iprep_loop_i(object self)
	{
		i = 0
		p = 0
	}

	void init(object self)
	{
		// read tags to set i and p to cached values
		i = 0
		p = 0
	}

	number get(object self)
	{
		return i
	}

	void increment(object self)
	{
		// increment i by 1 modulo p
		number newi = i + 1
		i = newi%p
	}

	void set(object self, number newi)
	{
		// updated i (not normally needed)
		i = newi
	}

}

object myi = alloc(iprep_loop_i)

object returni()
{
	return myi
}

class pauseVar:object
{
	number i

	void pauseVar(object self)
	{
		i = 0
	}

	void set(object self, number ii)
	{
		i = ii
	}

	number get(object self)
	{	
		return i
	}

}

object myPauseVar = alloc(pauseVar)

object returnPauseVar()
{
	return myPauseVar
}

number IPrep_loop()
{


	


	while (1)
	{
	
	// get i	
	number i = returni().get()// start loop at this step

		if (i==0) // imaging
		{
			
			number returnval = IPrep_image()

			if (returnval==1)
			{	
				// success
				returni().increment() // increment i if function succeeds
			}
			else if (returnval == -1)
			{
				// failure, repeat step next time

			}	

			// if pause button is pressed, stop loop and wait for resume or stop
			if (returnPauseVar().get())
			{
				returnPauseVar().set(0) // set pausevar back to 0
				break 
			}

			// if stop button is pressed or irrecoverable error ocuured, stop loop
			if (returnStopVar().get() || returnval == 0)
			{
				returnstopVar().set(0) // set stopvar back to 0
				IPrep_abortrun() // send UI stop command
				break 
			}



		} 
		else if (i==1) // move to pecs
		{
			//IPrep_MoveToPECS()
		}
		else if (i==2) // image in pecs before milling
		{
			//IPrep_Pecs_Image_beforemilling()
		}
		else if (i==3) // mill
		{
			//IPrep_mill()
		}
		else if (i==4) // image in pecs after milling
		{
			//IPrep_Pecs_Image_aftermilling()
		}
		else if (i==5) // increment the slice number
		{
			//IPrep_IncrementSliceNumber()
		}
		else if (i==6) // move to sem
		{
			//IPrep_MoveToSEM()
		}
		else if (i==7) 
		{
			//
		}
		else if (i==8) 






	}






}

number iprep_infer()
{
	// returns next step to run in iprep_loop()
}




number IPrep_startRun()
{
	// called by start button in UI

	print("UI: IPrep_StartRun")

	if(!IPrep_consistency_check())
	{
		print("consistency check failed, cannot start run")
		okdialog("consistency check failed, cannot start run")

		return 1
	}

	if(!IPrep_check())
	{
		print("argon or turbopump speed check failed, cannot start run")
		okdialog("argon or turbopump speed check failed, cannot start run")

		return 1
	}

	// infer the previous state

	number i // 
	i = iprep_infer()

	IPrep_loop()

}









