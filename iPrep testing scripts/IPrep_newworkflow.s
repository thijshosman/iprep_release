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

number IPrep_process_response(number returnval)
{
	if (i==0) // imaging, repeat if function returns 0
	{
		
		number returnval = IPrep_image()

		if (returnval==1)
		{	
			// success
			returni().increment() // increment i if function succeeds
		}
		else if (returnval == -1)
		{
			// failure, repeat step next iteration, i remains the same
			//#todo: count number of repeats for a step and throw something if it is more than 2
		} 

		// if stop button is pressed or irrecoverable error ocuured, stop loop
		if (returnStopVar().get() || returnval == 0)
		{
			returnstopVar().set(0) // set stopvar back to 0
			//IPrep_abortrun() // send UI stop command, may not be needed #todo
			returnPauseVar().set(0) // set pausevar back to 0, just in case in was pressed
			return 0 
		}

		// if pause button is pressed, stop loop and wait for resume or stop
		if (returnPauseVar().get())
		{
			returnPauseVar().set(0) // set pausevar back to 0
			return 0 
		}

		return 1
}


number IPrep_loop()
{

	while (1)
	{
	
	// get i	
	number i = returni().get()// start loop at this step

		if (i==0) // imaging, repeat if function returns 0
		{
			
			number returnval = IPrep_image()

			if (returnval==1)
			{	
				// success
				returni().increment() // increment i if function succeeds
			}
			else if (returnval == -1)
			{
				// failure, repeat step next iteration
			} 

			// if stop button is pressed or irrecoverable error ocuured, stop loop
			if (returnStopVar().get() || returnval == 0)
			{
				returnstopVar().set(0) // set stopvar back to 0
				//IPrep_abortrun() // send UI stop command, may not be needed #todo
				returnPauseVar().set(0) // set pausevar back to 0, just in case in was pressed
				break 
			}

			// if pause button is pressed, stop loop and wait for resume or stop
			if (returnPauseVar().get())
			{
				returnPauseVar().set(0) // set pausevar back to 0
				break 
			}

		} 
		else if (i==1) // ebsd imaging, repeat if function returns 0
		{
			number returnval = IPrep_acquire_ebsd()
			// #todo

			if (!IPrep_process_response(returnval))
				break

		}		
		else if (i==2) // increment the slice number
		{
			number returnval = IPrep_IncrementSliceNumber()
		}
		else if (i==3) // move to pecs, do not repeat
		{
			number returnval = IPrep_MoveToPECS()
		}
		else if (i==4) // image in pecs before milling, repeat if function returns 0
		{
			number returnval = IPrep_Pecs_Image_beforemilling()
		}
		else if (i==5) // mill, do not repeat
		{
			number returnval = IPrep_mill()
		}
		else if (i==6) // image in pecs after milling, repeat if function returns 0
		{
			number returnval = IPrep_Pecs_Image_aftermilling()
		}
		else if (i==7) // move to sem
		{
			number returnval = IPrep_MoveToSEM()
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









