class workflowStateMachine: object
{
	// manages state transfers in the workflow. only manages when state transfers can happen, 
	// the specifics of a transfer is in the workflow class

	//  tranfer return options: 
	// 1: step succeeded
	// -1: irrecoverable error 
	// 0: preconditions not met/not in right state/something went wrong but sucesfully undone

	object workflowStatePersistance
	object lastCompletedStep
	number percentage
	string workflowState	
	object myWorkflow

	number Tick
	number Tock

	// default sequences in workflow for transfering
	object PecsToSem_seq
	object SemToPecs_seq
	object reseat_seq

	// default sequences in workflow for imaging and milling
	object image_seq
	object ebsd_seq // temporary
	object mill_seq
	object coat_seq
	object PECSImage_before_seq
	object PECSImage_after_seq

	void print(object self, string str1)
	{
		result("StateMachine: "+str1+"\n")
	}
	
	void initSequences(object self)
	{
		// public
		// create sequence objects
		// these can be dynamically updated

		// reseat sequence, create and init with transfer devices
		reseat_seq = createSequence("reseat_default")
		reseat_seq.init("reseat",myWorkflow)

		// pecs to sem sequence, create and init with transfer devices
		PecsToSem_seq = createSequence("pecsToSem_default")
		PecsToSem_seq.init("pecsToSem",myWorkflow)

		// Sem to pecs sequence, create and init with transfer devices
		SemToPecs_seq = createSequence("semToPecs_default")
		SemToPecs_seq.init("semToPecs",myWorkflow)

		// image sequence, create and init
		image_seq = createSequence("image_single")
		image_seq.init("image",myWorkflow)

		// PECS image sequence before milling, create and init
		PECSImage_before_seq = createSequence("PECSImageDefault")
		PECSImage_before_seq.init("pecs_camera_beforemilling",myWorkflow)

		// PECS image sequence after milling, create and init
		PECSImage_after_seq = createSequence("PECSImageDefault")
		PECSImage_after_seq.init("pecs_camera_aftermilling",myWorkflow)

		// have another image sequence for EBSD for backward compatibility
		ebsd_seq = createSequence("EBSD_default")
		ebsd_seq.init("ebsd",myWorkflow)

		// milling sequence, create and init
		mill_seq = createSequence("mill_default")
		mill_seq.init("mill",myWorkflow)

		// coating sequence, create and init
		coat_seq = createSequence("coat_default")
		coat_seq.init("coat",myWorkflow)

	}
	


	void workflowStateMachine(object self)
	{
		workflowState = "UNKNOWN" // init value, undefined
		workflowStatePersistance = alloc(statePersistance)
		workflowStatePersistance.init("workflowState")
		lastCompletedStep = alloc(statePersistance)
		lastCompletedStep.init("lastCompletedStep")

		// register default 

		percentage = 0
		// "SEM" = sample in dock
		// "PECS" = sample in PECS
	}

	string getLastCompletedStep(object self)
	{
		//return the last succesfully completed step 

		return lastCompletedStep.getState()

	}

	number checkFlags(object self)
	{
		// check for flags
		if (returnDeadFlag().checkAliveAndSafe())
		return 1 // to indicate ok state 
	}

	void changeWorkflowState(object self, string newstate)
	{
		// *** private ***

		// method for changing the current state. can add logic to see if state is allowed
		string oldState = workflowState

		// logic to check new state goes here

		self.print("going from state "+oldState+" to "+newstate)
		workflowState = newstate
		workflowStatePersistance.setState(newstate)

	}



	void initManual(object self, object workflow, string startState)
	{
		// set the current state manually

		// get reference to the workflow of which the state will be managed
		myWorkflow = workflow

		// set state manually to what is used as input
		workflowState = startState
	}


	void init(object self, object workflow)
	{
		// get reference to the workflow of which the state will be managed
		myWorkflow = workflow

		// set state from tag
		workflowState = workflowStatePersistance.getState()

		// init sequences
		self.initSequences()

		// reset Tock 
		Tock=0

	}

	number reseat1(object self)
	{
		// *** public ***
		// uses workflow methods to reseat sample 
				
		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot reseat, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "PECS")
		{
			self.changeWorkflowState("reseating")


			// old style
			//myWorkflow.reseat() 
			
			// new style

			if(!reseat_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("exception during reseating, trying undo")
				if (reseat_seq.undo()) // undo succesful, return to previous state
				{
					self.print("succesfully recovered")
					self.changeWorkflowState("PECS")

					returnval = 0
				}
				else // undo failed
				{
					//throw("exception in reseat. cannot undo. read log")
					// #TODO SET DEAD/UNSAFE
					returnval = -1
				}
			}
			else
			{
				returnval = 1
			}

			
			
			self.changeWorkflowState("PECS")
			lastCompletedStep.setState("RESEAT")
		}
		else
		{
			self.print("not allowed to reseat when not in PECS, remaining idle")
			returnval = 0
		}
		return returnval
	}

	number PECS_to_SEM(object self)
	{
		// *** public ***
		// uses workflow methods to move sample from SEM to PECS and remembers state

		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot move to SEM, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "PECS")
		{
			self.changeWorkflowState("onTheWayToSEM")
			// pick up from PECS stage, drop off in SEM, retract transfer device

			number tick = GetOSTickCount()
			// old style
			//myWorkflow.fastPecsToSem()

			// new style
			if(!PecsToSem_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("exception during pecs->sem, trying undo")
				if (PecsToSem_seq.undo()) // undo succesful, return to previous state
				{
					self.print("succesfully recovered")
					self.changeWorkflowState("PECS")
					returnval = 0
				}
				else // undo failed
				{
					//throw("exception in transfer pecs -> sem. cannot undo. read log")
					// #TODO SET DEAD/UNSAFE
					returnval = -1
				}
			}
			else
			{
				returnval = 1
			}

			
			number tock = GetOSTickCount()
			self.print("elapsed time PECS->SEM: "+(tock-tick)/1000+" s")

			self.changeWorkflowState("SEM")
			lastCompletedStep.setState("SEM")
			

		}
		else
		{	
			self.print("not allowed to transfer from PECS to SEM. current state is: "+workflowState+". remaining idle")
			returnval = 1
		}
		return returnval
	}

	number SEM_to_PECS(object self)
	{
		// *** public ***
		// uses workflow methods to move sample from PECS to SEM and remembers state

		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot move to pecs, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "SEM")
		{
			self.changeWorkflowState("onTheWayToPECS")
			// bring arm out, pick up from SEM stage, slide into dovetail mount on PECS stage, retract
			
			number tick = GetOSTickCount()
			// old style
			//myWorkflow.fastSemToPecs()
				
			// new style
			if(!SemToPecs_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("exception during sem->pecs, trying undo")
				if (SemToPecs_seq.undo()) // undo succesful, return to previous state
				{
					self.print("succesfully recovered")
					self.changeWorkflowState("SEM")
					returnval = 0
				}
				else // undo failed
				{
					//throw("exception in transfersem -> pecs. cannot undo. read log")
					// #TODO SET DEAD/UNSAFE
					returnval = -1
				}
			}
			else
			{
				returnval = 1
			}
				
			number tock = GetOSTickCount()
			self.print("elapsed time SEM->PECS: "+(tock-tick)/1000+" s")

			self.changeWorkflowState("PECS")
			lastCompletedStep.setState("PECS")
		}
		else
		{
			self.print("not allowed to transfer from SEM to PECS. current state is: "+workflowState+". remaining idle")
			returnval = 0
		}
		return returnval
	}


	number image(object self)
	{
		// *** public ***
		// start imaging and/or acquiring data in SEM in other ways (EBSD/EDS)
		
		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot image, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "SEM")
		{

			number tick = GetOSTickCount()
				
			// new style
			if(!image_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("imaging failed")		

				// #TODO if something fails, lets not set dead/unsafe. it's most likely not that serious when just imaging
				returnval = 0
				
			}
			else
			{
				returnval = 1
			}
				
			number tock = GetOSTickCount()
			self.print("elapsed time imaging: "+(tock-tick)/1000+" s")

			lastCompletedStep.setState("IMAGE")
		}
		else
		{
			self.print("not allowed to image. current state is: "+workflowState+". remaining idle")
			returnval = 0
		}
		return returnval

	}

	number PECSImageAfter(object self)
	{
		// *** public ***
		// image in PECS after milling
		
		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot pecs image, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "PECS")
		{

			number tick = GetOSTickCount()
				
			// new style
			if(!PECSImage_after_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("pecs imaging failed")		

				// #TODO if something fails, lets not set dead/unsafe. it's most likely not that serious when just imaging
				returnval = 0
				
			}
			else
			{
				returnval = 1
			}
				
			number tock = GetOSTickCount()
			self.print("elapsed time pecs imaging: "+(tock-tick)/1000+" s")

			
		}
		else
		{
			self.print("not allowed to image in pecs. current state is: "+workflowState+". remaining idle")
			returnval = 0
		}
		return returnval

	}

	number PECSImageBefore(object self)
	{
		// *** public ***
		// image in PECS before milling
		
		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot pecs image, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "PECS")
		{

			number tick = GetOSTickCount()
				
			// new style
			if(!PECSImage_before_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("pecs imaging failed")		

				// #TODO if something fails, lets not set dead/unsafe. it's most likely not that serious when just imaging
				returnval = 0
				
			}
			else
			{
				returnval = 1
			}
				
			number tock = GetOSTickCount()
			self.print("elapsed time pecs imaging: "+(tock-tick)/1000+" s")

			
		}
		else
		{
			self.print("not allowed to image in pecs. current state is: "+workflowState+". remaining idle")
			returnval = 0
		}
		return returnval

	}

	number ebsd(object self)
	{
		// *** public ***
		// start imaging and/or acquiring data in SEM in other ways (EBSD/EDS)
		
		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot acquire EBSD, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "SEM")
		{

			number tick = GetOSTickCount()
				
			// new style
			if(!ebsd_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("ebsd failed")		

				// #TODO if something fails, lets not set dead/unsafe. it's most likely not that serious when just imaging
				returnval = 0
			}
			else
			{
				returnval = 1
			}
				
			number tock = GetOSTickCount()
			self.print("elapsed time in EBSD: "+(tock-tick)/1000+" s")

			lastCompletedStep.setState("EBSD")
		}
		else
		{
			self.print("not allowed to acquire EBSD. current state is: "+workflowState+". remaining idle")
			returnval = 0
		}
		return returnval

	}

	number mill(object self)
	{
		// *** public ***
		// start milling

		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot mill, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "PECS")
		{

			number tick = GetOSTickCount()
				
			// new style
			if(!mill_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("milling failed")		

				// #TODO if something fails, lets not set dead/unsafe. it's most likely not that serious when just milling
				returnval = 0
			}
			else
			{
				returnval = 1
			}
				
			number tock = GetOSTickCount()
			self.print("elapsed time milling: "+(tock-tick)/1000+" s")

			lastCompletedStep.setState("MILL")
		}
		else
		{
			self.print("not allowed mill. current state is: "+workflowState+". remaining idle")
			returnval = 0
		}
		return returnval
	}

	number coat(object self)
	{
		// *** public ***
		// start coating
		
		number returnval = 0

		if (!self.checkFlags())
		{
			self.print("cannot coat, dead and/or unsafe flag set")
			return returnval
		}

		if (workflowState == "PECS")
		{

			number tick = GetOSTickCount()
				
			// new style
			if(!coat_seq.do()) // check if it fails
			{
				// exception in transfer, see if we can undo

				self.print("coating failed")		

				// #TODO if something fails, lets not set dead/unsafe. it's most likely not that serious when just milling
				returnval = 0
			}
			else
			{
				returnval = 1
			}
				
			number tock = GetOSTickCount()
			self.print("elapsed time coating: "+(tock-tick)/1000+" s")

			lastCompletedStep.setState("COAT")
		}
		else
		{
			self.print("not allowed mill. current state is: "+workflowState+". remaining idle")
			returnval = 0
		}
		return returnval
	}

	void start_mill(object self, number simulation, number timeout)
	{
		// *** public ***
		// start milling until manually canceled or timeout (in seconds) is passed

		if (workflowState == "PECS")
		{	

				myWorkflow.executeMillingStep(simulation, timeout)

		}
		else
			self.print("commanded to perform milling step when sample is not in PECS, remaining idle")
	}

	void stop_mill(object self)
	{
		// *** public ***
		// stop milling	

		if (workflowState == "PECS")
		{	
			lastCompletedStep.setState("MILL")
		}
		else
			throw("commanded to perform stop milling step when sample is not in PECS")
	}

	void start_image(object self)
	{
		// *** public ***
		// start imaging
		
		Tick = GetOSTickCount()

		if (workflowState == "SEM")
		{	

			myWorkflow.preimaging()

			// imaging itself is done one level up, in iprep_main

		}
		else
			throw("wrong state: commanded to perform imaging step when sample is not in SEM")
	}

	void stop_image(object self)
	{
		// *** public ***
		// stop imaging	

		if (workflowState == "SEM")
		{	
			myWorkflow.postimaging()
			lastCompletedStep.setState("IMAGE")
			Tock = GetOSTickCount()
			if(Tock > 0)
				self.print("elapsed time in imaging: "+(Tock-Tick)/1000+" s")
		}
		else
			throw("wrong state: commanded to stop imaging step when sample is not in SEM")
	}

	void start_ebsd(object self, number timeout)
	{
		// *** public ***
		// start acquiring EBSD data
		

		if (workflowState == "SEM")
		{	

			myWorkflow.executeEBSD(timeout)

		}
		else
			throw("wrong state: commanded to perform EBSD step when sample is not in SEM")
	}

	void stop_ebsd(object self)
	{
		// *** public ***
		// stop acquiring EBSD data	

		if (workflowState == "SEM")
		{	
			myWorkflow.postEBSD()

			lastCompletedStep.setState("EBSD")
		}
		else
			throw("wrong state: commanded to stop EBSD acquisition step when sample is not in SEM")
	}

	void SMtestroutine(object self)
	{
		self.print("SM test routine started")

		myWorkflow.WFtestroutine()

		self.print("SM test routine ended")

	}


	number getPercentage(object self)
	{
		// deprecated
		return percentage
	}


	string getCurrentWorkflowState(object self)
	{
		// queried by DM
		return workflowState
	}

}

// create statemachine object, which acts as an interface to the workflow to allow only valied changes
object myStateMachine = alloc(workflowStateMachine)

object returnStateMachine()
{
	// returns the statemachine object
	return myStateMachine	
}


