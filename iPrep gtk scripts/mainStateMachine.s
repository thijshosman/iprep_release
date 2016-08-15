class workflowStateMachine: object
{
	// manages state transfers in the workflow. only manages when state transfers can happen, 
	// the specifics of a transfer is in the workflow class

	object workflowStatePersistance
	object lastCompletedStep
	number percentage
	string workflowState	
	object myWorkflow

	number Tick
	number Tock

	// default sequences in workflow
	object PecsToSem_seq
	object SemToPecs_seq
	object reseat_seq




	// flag set when system is in weird state
	object deadFlag

	void print(object self, string str1)
	{
		result("StateMachine: "+str1+"\n")
	}
	
	
	void initSequences(object self)
	{
		// public
		// create sequence objects
		
		// reseat sequence, create and init with transfer devices
		reseat_seq = createSequence("reseat_default")
		reseat_seq.init("reseat",myWorkflow)

		// pecs to sem sequence, create and init with transfer devices
		PecsToSem_seq = createSequence("pecsToSem_default")
		PecsToSem_seq.init("pecsToSem",myWorkflow)

		// Sem to pecs sequence, create and init with transfer devices
		SemToPecs_seq = createSequence("semToPecs_default")
		SemToPecs_seq.init("semToPecs",myWorkflow)

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

	void reseat(object self)
	{
		// *** public ***
		// uses workflow methods to reseat sample 
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

					return
				}
				else // undo failed, throw original exception
				{
					throw("exception in reseat. cannot undo. read log")
				}
			}

			
			
			self.changeWorkflowState("PECS")
			lastCompletedStep.setState("RESEAT")
		}
		else
			self.print("not allowed to reseat when not in PECS, remaining idle")
	}

	void PECS_to_SEM(object self)
	{
		// *** public ***
		// uses workflow methods to move sample from SEM to PECS and remembers state

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

				self.print("exception during reseating, trying undo")
				if (PecsToSem_seq.undo()) // undo succesful, return to previous state
				{
					self.print("succesfully recovered")
					self.changeWorkflowState("PECS")
					return
				}
				else // undo failed, throw original exception
				{
					throw("exception in transfer pecs -> sem. cannot undo. read log")
				}
			}

			
			number tock = GetOSTickCount()
			self.print("elapsed time PECS->SEM: "+(tock-tick)/1000+" s")

			self.changeWorkflowState("SEM")
			lastCompletedStep.setState("SEM")
			

		}
		else
			self.print("not allowed to transfer from PECS to SEM. current state is: "+workflowState+". remaining idle")
	}

	void SEM_to_PECS(object self)
	{
		// *** public ***
		// uses workflow methods to move sample from PECS to SEM and remembers state

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

				self.print("exception during reseating, trying undo")
				if (SemToPecs_seq.undo()) // undo succesful, return to previous state
				{
					self.print("succesfully recovered")
					self.changeWorkflowState("SEM")
					return
				}
				else // undo failed, throw original exception
				{
					throw("exception in transfersem -> pecs. cannot undo. read log")
				}
			}
				
			number tock = GetOSTickCount()
			self.print("elapsed time SEM->PECS: "+(tock-tick)/1000+" s")

			self.changeWorkflowState("PECS")
			lastCompletedStep.setState("PECS")


		}
		else
			self.print("not allowed to transfer from SEM to PECS. current state is: "+workflowState+". remaining idle")

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


