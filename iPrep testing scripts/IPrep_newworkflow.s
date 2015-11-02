// proposed workflow routine




class stopVar:object
{
	// used to access stop tag
	number i

	void stopVar(object self)
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



class pauseVar:object
{
	// used to access pausevar tag
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

object myStopVar = alloc(stopVar)

object returnStopVar()
{
	return myStopVar
}








class IPrep_mainloop:object
{
	// main iprep loop

	number loop_running
	
	number p // number of steps per cycle

	object iPersist

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("mainloop", level, text)
	}

	void print(object self, string text)
	{
		result("mainloop: "+text+"\n")
		self.log(2,text)
	}

	void IPrep_mainloop(object self)
	{
		// constructor
		loop_running = 0
		iPersist = alloc(statePersistanceNumeric)
	}

	void init(object self, number p1)
	{
		p = p1 // set number of steps per cycle
		
		iPersist.init("step")
		self.print("initialized, number of steps per cycle = "+p1+", current step = "+iPersist.getNumber())
	}

	void incrementi(object self)
	{
		// increment i by 1 modulo p
		number newi = (iPersist.getNumber()+1)%p
		iPersist.setNumber(newi)
	}

	void seti(object self, number newi)
	{
		// update i
		iPersist.setNumber(newi)
	}

	number geti(object self)
	{
		return iPersist.getNumber()
	}

	number process_response(object self, number returnval, number repeat)
	{
		// look at the response value and determine what the i value needs to do
		// check for pause and stop flags

		if (returnval==1)
		{	
			// success
			self.incrementi() // increment i if function succeeds
		}
		else if (returnval == -1)
		{
			// failure, repeat step next iteration, i remains the same
			//#todo: count number of repeats for a step and throw something if it is more than 2
			if (repeat == 0) 
			{
				// treat returning -1 as error
				returnval = 0
			}
			// else leave i as is

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

	void startLoop(object self)
	{

		while (1)
		{
			loop_running = 1
		
			// get i and start loop at this step
			number i = self.geti()
			self.print("current step: "+i)

			if (i==0) // imaging, repeat if function returns 0
			{
				self.print("loop: i = 0, imaging")
				number returnval = 1//IPrep_image()
				if (!self.process_response(returnval, 0)) // dont repeat for now
					break


			} 
			else if (i==1) // ebsd imaging, repeat if function returns 0
			{
				self.print("loop: i = 1, ebsd imaging")
				number returnval = 1//IPrep_acquire_ebsd()
				// #todo

				if (!self.process_response(returnval, 0)) // dont repeat for now
					break

			}		
			else if (i==2) // increment the slice number
			{
				self.print("loop: i = 2, incrementing slice number")
				number returnval = IPrep_IncrementSliceNumber()

				if (!self.process_response(returnval, 0)) // dont repeat for now
					break

			}
			else if (i==3) // move to pecs, do not repeat
			{
				self.print("loop: i = 3, move to pecs")
				number returnval = 1//IPrep_MoveToPECS()
				if (!self.process_response(returnval, 0)) // dont repeat for now
					break

			}
			else if (i==4) // image in pecs before milling, repeat if function returns 0
			{
				self.print("loop: i = 4, imaging before milling")
				number returnval = 1//IPrep_Pecs_Image_beforemilling()
				if (!self.process_response(returnval, 0)) // dont repeat for now
					break

			}
			else if (i==5) // mill, do not repeat
			{
				self.print("loop: i = 5, milling")
				number returnval = 1//IPrep_mill()
				if (!self.process_response(returnval, 0)) // dont repeat for now
					break

			}
			else if (i==6) // image in pecs after milling, repeat if function returns 0
			{
				self.print("loop: i = 6, imaging after milling")
				number returnval = 1//IPrep_Pecs_Image_aftermilling()
				if (!self.process_response(returnval, 0)) // dont repeat for now
					break

			}
			else if (i==7) // move to sem
			{
				self.print("loop: i = 7, move to sem")
				number returnval = 1//IPrep_MoveToSEM()
				if (!self.process_response(returnval, 0)) // dont repeat for now
					break


			}
			else if (i==8) 
			{
				//
				self.print("end of loop")
				number returnval
				if (okcanceldialog("continue looping?"))
					returnval = 1
				else
					returnval = 0
					
				if (!self.process_response(returnval, 0)) // dont repeat for now
					break				
			}

			// check
			if (optiondown() + shiftdown())
				break
				
			sleep(1)
		}

		loop_running = 0
		self.print("done")

	}




}








	object myLoop = alloc(IPrep_mainloop)
	number p, i
	p=9
	i=0

	myLoop.init(p)

myLoop.startLoop()
/*
number r
for (r=0;r<10;r++)
{

	myloop.incrementi()
	result(myloop.geti()+"\n")
	
}
*/
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



}









