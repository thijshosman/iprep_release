// $BACKGROUND$
number XYZZY = 0
class workflow: object
{
	// the workflow object is responsible for initializing all hardware and interacting with it. 
	// it initializes simulators where needed depending on tags and keeps a reference to these individual objects. 
	// it sets position values (for transfer system and SEM) based on modes selected. 

	// timer numbers
	number tick, tock

	// hardware classes
	object myGripper
	object mySEMdock
	object myTransfer
	object myPecs
	object mySEM
	object myPecsCamera
	object myDigiscan
	object myEBSD

	// haltflag used to interrupt workflow elements if set
	object haltFlag

	// mode, ebsd or planar
	string mode
	
	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("WORKFLOW", level, text)
	}

	void print(object self, string str1)
	{
		result("Workflow: "+str1+"\n")
		self.log(2,str1)
	}


	// *** initializations ***

	void init(object self)
	{
		// initialize hardware. use factory. 1 = simulation
		// in general: simulion = 1, normal hardware = 2

		self.print("--- start init ---")

		// get all simulation numbers
		TagGroup tg = GetPersistentTagGroup() 
		number sim_pecs, sim_digiscan, sim_sem, sim_transfer, sim_gripper, sim_pecscamera, sim_dock, sim_ebsd

		TagGroupGetTagAsNumber(tg,"IPrep:simulation:dock", sim_dock )
		TagGroupGetTagAsNumber(tg,"IPrep:simulation:pecs", sim_pecs )
		TagGroupGetTagAsNumber(tg,"IPrep:simulation:digiscan", sim_digiscan )
		TagGroupGetTagAsNumber(tg,"IPrep:simulation:sem", sim_sem )
		TagGroupGetTagAsNumber(tg,"IPrep:simulation:transfer", sim_transfer )
		TagGroupGetTagAsNumber(tg,"IPrep:simulation:gripper", sim_gripper )
		TagGroupGetTagAsNumber(tg,"IPrep:simulation:pecscamera", sim_pecscamera )
		TagGroupGetTagAsNumber(tg,"IPrep:simulation:ebsd", sim_ebsd )
		
		// check tag to see if we use EBSD or planar Dock
		// "planar" or "ebsd" string in tag
		mode = getSystemMode()



		self.print(mode+"\n")

		if (mode == "planar")
		{
			// planar mode selected
			if (sim_dock == 1)
				mySEMdock = createDock(1) // simulator
			else 
				mySEMdock = createDock(2)

		} 
		else if (mode == "ebsd")
		{
			// ebsd mode selected
			if (sim_dock == 1)
				mySEMdock = createDock(1) // simulator
			else 
				mySEMdock = createDock(3)

		}	
		else
		{
			throw("system mode (planar or ebsd) not detected! Don't know which dock to initialize")
		}

		// init SEM Dock
		mySEMdock.init()

		// init parker
		myTransfer = createTransfer(sim_transfer)
		myTransfer.init()

		// update pickup_dropoff point for dock used
		// #todo

		// init gripper
		myGripper = createGripper(sim_gripper)
		myGripper.init()

		// init PECS 
		myPecs = createPecs(sim_pecs)
		myPecs.init()

		// init SEM
		mySEM = createSem(sim_sem)
		mySEM.init()

		
		// init PECS camera
		myPecsCamera = createPecsCamera(sim_pecscamera)
		myPecsCamera.init()

		// init Digiscan
		myDigiscan = createDigiscan(sim_digiscan)

		// init EBSD camera
		myEBSD = createEBSDHandshake(sim_ebsd)
		myEBSD.init()
		// type 1 is simulator, 2 is manual, 3 is OI interface



		// print start states
		self.print("parker current state: "+myTransfer.getCurrentState())
		self.print("parker current position is: "+myTransfer.getCurrentPosition())
		self.print("gripper current state: "+myGripper.getState())
		self.print("SEM dock current state: "+mySEMdock.getState())
		self.print("PECS GVstate: "+myPecs.getGVstate())
		self.print("--- hardware initialization complete---\n")

	}


	// *** methods for returning subclasses (used for testing)
	
	object returnSEMDock(object self)
	{
		return mySEMdock
	}
	object returnTransfer(object self)
	{
		return myTransfer
	}
	object returnSEM(object self)
	{
		return mySEM
	}
	object returnPECS(object self)
	{
		return myPecs
	}
	object returnGripper(object self)
	{
		return myGripper
	}
	object returnPECSCamera(object self)
	{
		return myPecsCamera
	}
	object returnDigiscan(object self)
	{
		return myDigiscan
	}
	object returnEBSD(object self)
	{
		return myEBSD
	}

	// *** testing ***




	// *** workflow items (old style) ***

	void pickupFromPecsAndMoveToGV(object self)
	{
	
		// 1st step in PECS-SEM

		// lower pecs stage
		myPecs.moveStageDown()
		
		// home pecs stage
		myPecs.stageHome()
	
		// parker go to zero
		myTransfer.move("outofway")
	
		// go to where gripper arms can safely open
		myTransfer.move("open_pecs")

		// open gripper arms
		myGripper.open()

		// move forward to where sample can be picked up
		myTransfer.move("pickup_pecs")

		continueCheck()

		// close gripper arms
		myGripper.close()

		continueCheck()

		// slide sample out and move towards gate valve
		myTransfer.move("beforeGV")

		//result("error in 1st PECS->SEM step: "+ GetExceptionString() + "\n" )

	
	}
	
	
	
	void insertIntoSEM(object self)
	{
		// SEM Stage assumed to be in clear position, but move there just in case

		// 2nd step in PECS->SEM

		// open GV
		myPecs.openGVandCheck()

		// move sem stage to clear point
		mySEM.goToClear()
	
		// move SEM dock up to allow sample to go in
		mySEMdock.unclamp()

		// move into chamber
		myTransfer.move("dropoff_sem")

		continueCheck()

		// SEM Stage to dropoff position
		mySEM.goToPickup_Dropoff()

		continueCheck()

		// gripper open to release sample
		myGripper.open()

		// parker back off to where arms can open/close
		myTransfer.move("backoff_sem")

		// gripper close
		myGripper.close()
	
		// SEM stage move to clear position
		mySEM.goToClear()

		// move SEM dock down to clamp
		mySEMdock.clamp()

		// move SEM stage to nominal imaging plane
		mySEM.goToNominalImaging()

		//result("error in 2nd PECS->SEM step: "+ GetExceptionString() + "\n" )

	}

	void retractArmAfterDropoff(object self)
	{
		// 3rd step in PECS->SEM

		// parker move back to "open_pecs"
		myTransfer.move("open_pecs")

		// parker home and turn off to prevent singing
		myTransfer.home()

		// close gate valve
		myPecs.closeGVandCheck()

		//result("error in 3nd PECS->SEM step: "+ GetExceptionString() + "\n" )

	}


	void removeSampleFromSEM(object self)
	{
		// 1st step in SEM->PECS
		
		// move pecs stage down
		myPecs.moveStageDown()

		// home pecs stage
		myPecs.stagehome()

		// move into PECS before GV
		myTransfer.move("beforeGV")
			
		// move SEM stage to clear point
		mySEM.goToClear()

		// move SEM dock clamp up to release sample
		mySEMdock.unclamp()

		// move SEM stage to pickup point
		mySEM.goToPickup_Dropoff()

		// open GV
		myPecs.openGVandCheck()

		// move transfer system to location where arms can safely open
		myTransfer.move("backoff_sem")

		// gripper open
		myGripper.open()

		// move transfer system to pickup point
		myTransfer.move("pickup_sem")

		continueCheck()

		// gripper close, sample is picked up
		myGripper.close()
		
		// move SEM stage to clear point so that dock is out of the way
		mySEM.goToClear()

		// transfer sample to PECS before GV
		myTransfer.move("beforeGV")

		// close GV
		myPecs.closeGVandCheck()

		// move SEM dock clamp down to safely move it around inside SEM
		mySEMdock.clamp()


	}

	void insertSampleIntoPecsAndRetract(object self)
	{
		// 2nd step in SEM->PECS

		// slide sample into dovetail
		myTransfer.move("dropoff_pecs")

		// back off 1 mm
		myTransfer.move("dropoff_pecs_backoff")

		// open gripper arms
		myGripper.open()
	
		// move gripper back so that arms can close
		myTransfer.move("open_pecs")
		
		// close gripper arms
		myGripper.close()
	
		// move gripper out of the way by homing
		myTransfer.home()

		sleep(20)

		//result("error in 2nd SEM->PECS step: "+ GetExceptionString() + "\n" )
	}

	void WFtestroutine(object self)
	{
		// test routine for error framework

		result("step 1")
		sleep(1)	

		// test 1, continue dialog
		continueCheck()

		result("step 2")
		sleep(1)

		// test 2, halt flag
		returnHaltFlag().haltCheck()
		result("step 3")
		sleep(1)

		// test 3, option+shift
		manualHaltOptionShift()
		result("step 4")
		sleep(1)

		result("step 5")
		sleep(1)

	}



	void PecsToSemAlign(object self)
	{

		// used for alignment of sem transfer position

		// lower pecs stage
		myPecs.moveStageDown()
		
		// home pecs stage
		myPecs.stageHome()
	
		// go to where gripper arms can safely open
		myTransfer.move("open_pecs")

		// open gripper arms
		myGripper.open()

		// move forward to where sample can be picked up
		myTransfer.move("pickup_pecs")

		continueCheck()

		// close gripper arms
		myGripper.close()

		continueCheck()

		// open GV
		myPecs.openGVandCheck()

		// move to before GV
		myTransfer.move("beforeGV")

	}

	void returnFromSEMAnywhereToPecs(object self)
	{
		// return a sample carrier from a point in the SEM to the PECS

		// slide sample into dovetail
		myTransfer.move("dropoff_pecs")

		// back off 1 mm to relax tension on springs
		myTransfer.move("dropoff_pecs_backoff")

		// open gripper arms
		myGripper.open()
	
		// move gripper back so that arms can close
		myTransfer.move("open_pecs")
		
		// close gripper arms
		myGripper.close()
		
		// go to prehome
		myTransfer.move("prehome")

		// move gripper out of the way by homing
		myTransfer.home()

		sleep(5)

		// turn transfer system off
		myTransfer.turnOff()


	}

	// *** actual methods used by workflow following ***

	void fastSemToPecs(object self)
	{
		// this method is part of speed improvements in the workflow. we try to get the sample as fast
		// between the two points as a synchronous workflow allows. 

		// lockout PECS UI
		myPecs.lockout()

		// turn off gas flow
		myPecs.shutoffArgonFlow()

		// move pecs stage down
		myPecs.moveStageDown()

		// home pecs stage
		myPecs.stagehome()

		// move SEM stage to clear point
		mySEM.goToClear()

		// hold dock in place to make sure it does not move down by itself as a result of spring force overcoming stepper drive
		mySEMdock.hold()

		// move SEM dock clamp up to release sample
		mySEMdock.unclamp()

		// move SEM stage to pickup point
		mySEM.goToPickup_Dropoff()

		// open GV
		myPecs.openGVandCheck()

		// move transfer system to location where arms can safely open
		myTransfer.move("backoff_sem")

		// gripper open
		myGripper.open()

		// move transfer system to pickup point
		myTransfer.move("pickup_sem")

		continueCheck()

		// gripper close, sample is picked up
		myGripper.close()
		
		// move SEM stage to clear point so that dock is out of the way
		mySEM.goToClear()

		if (GetTagValue("IPrep:simulation:samplechecker") == 1)
		{
			// check that sample is no longer present in dock, if simulation of dock is off
			if (mySEMdock.checkSamplePresent())
			{
				self.print("sample still detected in dock after pickup")
				throw("sample still detected in dock after pickup")
			}
		}

		// intermediate point as not to trigger the torque limit
		// #TODO: fix unneeded step
		myTransfer.move("beforeGV")

		// turn hold off again
		mySEMdock.unhold()

		// move SEM dock clamp down to safely move it around inside SEM
		mySEMdock.clamp()

		// slide sample into dovetail
		myTransfer.move("dropoff_pecs")

		// back off 1 mm to relax tension on springs
		myTransfer.move("dropoff_pecs_backoff")

		// open gripper arms
		myGripper.open()
	
		// move gripper back so that arms can close
		myTransfer.move("open_pecs")
		
		// close gripper arms
		myGripper.close()
		
		// go to prehome
		myTransfer.move("prehome")

		// move gripper out of the way by homing
		myTransfer.home()

		// close GV
		myPecs.closeGVandCheck()

		// turn gas flow back on
		myPecs.restoreArgonFlow()

		// turn transfer system off
		//myTransfer.turnOff()

		// unlock
		myPecs.unlock()

	}

	void fastPecsToSem(object self)
	{
		// this method is part of speed improvements in the workflow. we try to get the sample as fast
		// between the two points as a synchronous workflow allows. 

		// lockout PECS UI
		myPecs.lockout()

		// turn off gas flow
		myPecs.shutoffArgonFlow()

		// lower pecs stage
		myPecs.moveStageDown()
		
		// home pecs stage
		myPecs.stageHome()
	
		// go to where gripper arms can safely open
		myTransfer.move("open_pecs")

		// open gripper arms
		myGripper.open()

		// move forward to where sample can be picked up
		myTransfer.move("pickup_pecs")

		continueCheck()

		// close gripper arms
		myGripper.close()

		continueCheck()

		// open GV
		myPecs.openGVandCheck()

		// move sem stage to clear point
		mySEM.goToClear()
	
		// hold dock in place to make sure it does not move down by itself as a result of spring force overcoming stepper drive
		mySEMdock.hold()

		// move SEM dock up to allow sample to go in
		mySEMdock.unclamp()

		continueCheck()

		// move into chamber
		myTransfer.move("dropoff_sem")

		continueCheck()

		// SEM Stage to dropoff position
		mySEM.goToPickup_Dropoff()

		continueCheck()

		// gripper open to release sample
		myGripper.open()

		// parker back off to where arms can open/close
		myTransfer.move("backoff_sem")

		// gripper close
		myGripper.close()
	
		// intermediate point as not to trigger the torque limit
		// #TODO: fix unneeded step
		myTransfer.move("beforeGV")

		// SEM stage move to clear position
		mySEM.goToClear()

		// turn hold off again
		mySEMdock.unhold()

		// move SEM dock down to clamp
		mySEMdock.clamp()

		// parker move back to prehome
		myTransfer.move("prehome")

		// parker home and turn off to prevent singing
		myTransfer.home()

		// close gate valve
		myPecs.closeGVandCheck()

		// turn gas flow back on
		myPecs.restoreArgonFlow()

		if (GetTagValue("IPrep:simulation:samplechecker") == 1)
		{
			// check that sample is present
			if (!mySEMdock.checkSamplePresent())
			{
				self.print("sample not detected in dock after dropoff")
				throw("sample not detected in dock after dropoff")
			}
		}

		// move SEM stage to nominal imaging plane
		mySEM.goToNominalImaging()

		// turn transfer system off
		//myTransfer.turnOff()

		// unlock
		myPecs.unlock()

	}

	void reseat(object self)
	{
		// move sample out and into dovetail 
		// use after sample transfer so that it will be in the same position as during transfer

		// lockout PECS UI
		myPecs.lockout()

		// lower pecs stage
		myPecs.moveStageDown()
		
		// home pecs stage
		myPecs.stageHome()
	
		// go to where gripper arms can safely open
		myTransfer.move("open_pecs")

		// open gripper arms
		myGripper.open()

		// move forward to where sample can be picked up
		myTransfer.move("pickup_pecs")

		continueCheck()

		// close gripper arms
		myGripper.close()

		// move to before gv
		myTransfer.move("beforeGV")

		continueCheck()

		// TEMP TESTING: home pecs stage
		// home pecs stage
		myPecs.stageHome()

		// slide sample into dovetail
		myTransfer.move("dropoff_pecs")

		// back off 1 mm to relax tension on springs
		myTransfer.move("dropoff_pecs_backoff")

		continueCheck()

		// open gripper arms
		myGripper.open()
	
		continueCheck()

		// move gripper back so that arms can close
		myTransfer.move("open_pecs")
		
		// close gripper arms
		myGripper.close()
		
		// go to prehome
		myTransfer.move("prehome")

		// move gripper out of the way by homing
		myTransfer.home()

		// turn transfer system off
		//myTransfer.turnOff()

		// unlock
		myPecs.unlock()
	}



	void executeMillingStep(object self, number simulation, number timeout)
	{
		self.print("milling started...")

		myPecs.unlock()

		// raise stage
		// #TODO: bug that messes up etching mode and milling when system is lowered when started
		myPecs.moveStageUp()

		// go to etch mode
		myPecs.goToEtchMode()



		// start milling. milling state is checked by state machine 
		if (simulation == 0)
			myPecs.startMilling()
		else
			myPecs.stageHome()

		self.print("hold Option + Shift to skip remainder of milling")

		sleep(2)

		tick = GetOSTickCount()		
		
		while (myPecs.getMillingStatus()!=0)
		{
			tock = GetOSTickCount()
			if ((tock-tick)/1000 > timeout)
			{
				self.print("timeout passed")
				myPecs.stopMilling()

				// home stage since picture should still be at home
				myPecs.stageHome()
				break	
			}
			
			if ((optiondown() && shiftdown()))
			{
				self.print("aborted")
				myPecs.stopMilling()

				// home stage since picture should still be at home
				myPecs.stageHome()
				break
			}

			self.print("milling time remaining: "+myPecs.millingTimeRemaining())

			sleep(1)
			
		}
		self.print("elapsed time in milling: "+(tock-tick)/1000+" s")		
		myPecs.lockout()
		
	}	

	void executeCoatingStep(object self, number timeout)
	{
		self.print("coating started...")
		// TODO: add timeout
		myPecs.goToCoatMode()

		myPecs.startCoating()
		self.print("hold Option + Shift to skip remainder of step")

		tick = GetOSTickCount()		
		
		while (myPecs.getMillingStatus()!=0)
		{
			tock = GetOSTickCount()
			if ((tock-tick)/1000 > timeout)
			{
				self.print("timeout passed")
				myPecs.stopMilling()

				// home stage since picture should still be at home
				myPecs.stageHome()
				break	
			}
			
			if ((optiondown() && shiftdown()))
			{
				self.print("aborted")
				myPecs.stopMilling()

				// home stage since picture should still be at home
				myPecs.stageHome()
				break
			}

			self.print("coating time remaining: "+myPecs.millingTimeRemaining())

			sleep(1)
			
		}
		self.print("elapsed time in coating: "+(tock-tick)/1000+" s")	

	}

	void preImaging(object self)
	{
		// prepares system for taking of image, like setting HV and WD settings and unblanking beam

		mySEM.blankOff()

		self.print("preimaging done")
	}
	
	void postImaging(object self)
	{
		mySEM.blankOn()
		
		// does some cleaning up after imaging, like blanking beam 
		self.print("postimaging done")
	}

	void executeEBSD(object self, number timeout)
	{
		// send to SEM whatever needs to be sent to start EBSD acquisition
		// then tell ebsd handshaker to start
		//mySEM.blankOff()

		tick = GetOSTickCount()		

		myEBSD.EBSD_start()

		// #todo: get timeout for EBSD from tag

		self.print("hold Option + Shift to skip EBSD acquisition")
		
		
		while (myEBSD.isBusy()!=0)
		{
			tock = GetOSTickCount()
			if ((tock-tick)/1000 > timeout)
			{
				self.print("EBSD timeout passed")
				
				break	
			}
			
			if ((optiondown() && shiftdown()))
			{
				self.print("aborted")

				break
			}

			sleep(1)
			
		}
		self.print("elapsed time in EBSD: "+(tock-tick)/1000+" s")	

		self.print("EBSD done")
		
	}

	void postEBSD(object self)
	{
		//mySEM.blankOn()
		// decouple FWD (in case oxford instruments coupled it)
		mySEM.uncoupleFWD()

		self.print("postEBSD done")
	}

	// *** additional testing methods ***

	void insertAndRetractNTimes(object self, number numberOfTimes)
	{
		number index
		for (index=0; index<numberOfTimes; index++)
		{
			self.pickupFromPecsAndMoveToGV()
			self.insertSampleIntoPecsAndRetract()
			result("index: "+index+"\n")
		}
	}

	void openAndCloseNTimes(object self, number numberOfTimes)
	{
		number index
		for (index=0; index<numberOfTimes; index++)
		{
			//self.gripperOpenAndClose()
			result("index: "+index+"\n")
		}
	}

}

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






// create workflow object, important that no exceptions occur in constructor
object myWorkflow = alloc(workflow)

object returnWorkflow()
{
	// returns the workflow object
	return myWorkflow
}

// create statemachine object, which acts as an interface to the workflow to allow only valied changes
object myStateMachine = alloc(workflowStateMachine)

object returnStateMachine()
{
	// returns the statemachine object
	return myStateMachine	
}
