// $BACKGROUND$
number XYZZY = 0
class workflow: object
{

	// hardware classes
	object myGripper
	object mySEMdock
	object myTransfer
	object myPecs
	object mySEM
	object myPecsCamera
	object myDigiscan
	
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
		self.print("--- start init ---")
		
		// init gripper
		myGripper = alloc(gripper)
		myGripper.init()
		
		// init SEM Dock
		mySEMdock = alloc(PlanarSEMdock)
		mySEMdock.init()

		// init parker
		myTransfer = alloc(ParkerTransfer)
		myTransfer.init()

		// init PECS 
		myPecs = alloc(pecs_iprep)

		// init SEM
		mySEM = alloc(SEM_IPrep)
		mySEM.init()

		// init PECS camera
		myPecsCamera = alloc(pecsCamera_iprep)
		myPecsCamera.init()

		// init Digiscan
		myDigiscan = alloc(digiscan_iprep)
		myDigiscan.init()

		// print start states
		self.print("parker current state: "+myTransfer.getCurrentState())
		self.print("parker current position is: "+myTransfer.getCurrentPosition())
		self.print("gripper current state: "+myGripper.getState())
		self.print("SEM dock current state: "+mySEMdock.getState())
		self.print("PECS GVstate: "+myPecs.getGVstate())

		self.print("--- initializing hardware complete---\n")

	}

	void setDefaultPositions(object self)
	{
		// save default positions in global tags
		self.print("setDefaultPositions: using calibrations from 20150903 ")

		myTransfer.setPositionTag("outofway",0) // home position, without going through homing sequence
		myTransfer.setPositionTag("prehome",15) // location where we can move to close to home from where we home
		myTransfer.setPositionTag("open_pecs",27) // location where arms can open in PECS  // #20150819: was 29, #20150903: was 28
		myTransfer.setPositionTag("pickup_pecs",48) // location where open arms can be used to pickup sample // #20150827: was 48.5, #20150903: was 49.5
		myTransfer.setPositionTag("beforeGV",100) // location where open arms can be used to pickup sample
		myTransfer.setPositionTag("dropoff_sem",486.5) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
		myTransfer.setPositionTag("pickup_sem",486.5) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
		myTransfer.setPositionTag("backoff_sem",430) // location where gripper arms can safely open/close in SEM chamber
		myTransfer.setPositionTag("dropoff_pecs",46.50) // location where sample gets dropped off in PECS // #20150827: was 45.5
		myTransfer.setPositionTag("dropoff_pecs_backoff",47.50) // location where sample gets dropped off in PECS // #20150827: was 46.5
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

	// *** testing ***




	// *** workflow items ***

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

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// close gripper arms
		myGripper.close()

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

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
		mySEMdock.goUp()

		// move into chamber
		myTransfer.move("dropoff_sem")

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// SEM Stage to dropoff position
		mySEM.goToPickup_Dropoff()

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// gripper open to release sample
		myGripper.open()

		// parker back off to where arms can open/close
		myTransfer.move("backoff_sem")

		// gripper close
		myGripper.close()
	
		// SEM stage move to clear position
		mySEM.goToClear()

		// move SEM dock down to clamp
		mySEMdock.goDown()

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

	void preImaging(object self)
	{
		// prepares system for taking of image, like setting HV and WD settings and unblanking beam
		
		// we want to keep HV on during the whole experiment, but we have enabled/disabled it during transfers for testing
		//mySEM.HVOn()
		//sleep(1)
		mySEM.blankOff()
if (XYZZY)
{

		// set WD and kV to correct value, as determined by configuration
		// NB: needs to be in this order, otherwise setting kV will reset WD
		mySEM.setkVForImaging()
		mySEM.setWDForImaging()
}
		self.print("preimaging done")
	}
	
	void postImaging(object self)
	{
		mySEM.blankOn()

		// for testing purposes only, we want to leave HV on
		// mySEM.HVOff()
		
		// does some cleaning up after imaging, like blanking beam 
		self.print("postimaging done")
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
		mySEMdock.goUp()

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

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// gripper close, sample is picked up
		myGripper.close()
		
		// move SEM stage to clear point so that dock is out of the way
		mySEM.goToClear()

		// transfer sample to PECS before GV
		myTransfer.move("beforeGV")

		// close GV
		myPecs.closeGVandCheck()

		// move SEM dock clamp down to safely move it around inside SEM
		mySEMdock.goDown()


	}

	void insertSampleIntoPecsAndRetract(object self)
	{
		// 2nd step in SEM->PECS

		// slide sample into dovetail
		myTransfer.move("dropoff_pecs")

		// back off 1 mm
		myTransfer.move("dropoff_pecs_backoff")

		/*
		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}
		*/

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

	void fastSemToPecs(object self)
	{
		// this method is part of speed improvements in the workflow. we try to get the sample as fast
		// between the two points as a synchronous workflow allows. 

		// move pecs stage down
		myPecs.moveStageDown()

		// home pecs stage
		myPecs.stagehome()

		// move SEM stage to clear point
		mySEM.goToClear()

		// move SEM dock clamp up to release sample
		mySEMdock.goUp()

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

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// gripper close, sample is picked up
		myGripper.close()
		
		// move SEM stage to clear point so that dock is out of the way
		mySEM.goToClear()

		// slide sample into dovetail
		myTransfer.move("dropoff_pecs")

		// back off 1 mm to relax tension on springs
		myTransfer.move("dropoff_pecs_backoff")

		/*
		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}
		*/

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

		// move SEM dock clamp down to safely move it around inside SEM
		mySEMdock.goDown()

		// turn transfer system off
		myTransfer.turnOff()

	}

	void fastPecsToSem(object self)
	{
		// this method is part of speed improvements in the workflow. we try to get the sample as fast
		// between the two points as a synchronous workflow allows. 

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

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// close gripper arms
		myGripper.close()

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// open GV
		myPecs.openGVandCheck()

		// move sem stage to clear point
		mySEM.goToClear()
	
		// move SEM dock up to allow sample to go in
		mySEMdock.goUp()

		// move into chamber
		myTransfer.move("dropoff_sem")

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// SEM Stage to dropoff position
		mySEM.goToPickup_Dropoff()

		if(getProtectedModeFlag())
		{
			if(!ContinueCancelDialog( "continue?" ))
			{
			throw("mijn error")
			}
		}

		// gripper open to release sample
		myGripper.open()

		// parker back off to where arms can open/close
		myTransfer.move("backoff_sem")

		// gripper close
		myGripper.close()
	
		// parker move back to prehome
		myTransfer.move("prehome")

		// parker home and turn off to prevent singing
		myTransfer.home()

		// close gate valve
		myPecs.closeGVandCheck()

		// SEM stage move to clear position
		mySEM.goToClear()

		// move SEM dock down to clamp
		mySEMdock.goDown()

		// move SEM stage to nominal imaging plane
		mySEM.goToNominalImaging()

		// turn transfer system off
		myTransfer.turnOff()

	}

	void executeMillingStep(object self, number simulation)
	{

		// raise stage
		myPecs.moveStageUp()

		// start milling. milling state is checked by state machine 
		if (simulation == 0)
			myPecs.startMilling()
		else
			myPecs.stageHome()
		
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
	//the specifics of a transfer is in the workflow class

	object workflowStatePersistance
	number percentage
	string workflowState	
	object myWorkflow

	number imageTick
	number imageTock


	void print(object self, string str1)
	{
		result("StateMachine: "+str1+"\n")
	}

	void workflowStateMachine(object self)
	{
		workflowState = "UNKNOWN" // init value, undefined
		workflowStatePersistance = alloc(statePersistance)
		workflowStatePersistance.init("workflowState")
		percentage = 0
		// "SEM" = sample in dock
		// "PECS" = sample in PECS
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

		// reset imageTock 
		imageTock=0

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
				// fast, as fast as can be done synchronously
				myWorkflow.fastPecsToSem()

				// old, slow
				//myWorkflow.pickupFromPecsAndMoveToGV()
				//myWorkflow.insertIntoSEM()
				//myWorkflow.retractArmAfterDropoff()
				
				number tock = GetOSTickCount()
				self.print("elapsed time PECS->SEM: "+(tock-tick)/1000+" s")

			self.changeWorkflowState("SEM")
			
			// save tags to disk
			ApplicationSavePreferences()

		}
		else
			throw("not allowed to transfer from SEM to PECS. current state is: "+workflowState)
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
				// fast, as fast as can be done synchronously
				myWorkflow.fastSemToPecs()
				
				// old, slow
				//myWorkflow.removeSampleFromSEM()
				//myWorkflow.insertSampleIntoPecsAndRetract()
				
				number tock = GetOSTickCount()
				self.print("elapsed time SEM->PECS: "+(tock-tick)/1000+" s")

			self.changeWorkflowState("PECS")

			// save tags to disk
			ApplicationSavePreferences()

		}
		else
			throw("not allowed to transfer from PECS to SEM. current state is: "+workflowState)

	}

	void start_mill(object self, number simulation, number timeout)
	{
		// *** public ***
		// start milling until manually canceled or timeout (in seconds) is passed

		if (workflowState == "PECS")
		{	

				number tick = GetOSTickCount()
				number tock
				myWorkflow.executeMillingStep(simulation)
				self.print("hold Option + Shift to skip remainder of milling milling")
				
				// if simulating, return immediately
				while (myWorkflow.returnPECS().getMillingStatus()!=0)
				{
					tock = GetOSTickCount()
					if ((tock-tick)/1000 > timeout)
					{
						self.print("timeout passed")
						myWorkflow.returnPECS().stopMilling()

						// home stage since picture should still be at home
						myWorkflow.returnPECS().stageHome()
						break	
					}
					
					if ((optiondown() && shiftdown()))
					{
						self.print("aborted")
						myWorkflow.returnPECS().stopMilling()

						// home stage since picture should still be at home
						myWorkflow.returnPECS().stageHome()
						break
					}

					self.print("milling time remaining: "+myWorkflow.returnPECS().millingTimeRemaining())

					sleep(1)
					
				}
					
				if (simulation == 1)
				{
					self.print("simulation, homing stage")
					myWorkflow.returnPECS().stageHome()
				}

				tock = GetOSTickCount()
				self.print("elapsed time in milling: "+(tock-tick)/1000+" s")
				self.print("milling completed, now taking image")	


		}
		else
			throw("commanded to perform milling step when sample is not in PECS")

	}

	void start_image(object self)
	{
		// *** public ***
		// start imaging
		
		imageTick = GetOSTickCount()

		if (workflowState == "SEM")
		{	
		
			
				
			myWorkflow.preimaging()

			// imaging itself is now done one level up, in iprep_main

		}
		else
			throw("commanded to perform imaging step when sample is not in SEM")
	}

	void stop_image(object self)
	{
		// *** public ***
		// stop imaging	

		if (workflowState == "SEM")
		{	
			myWorkflow.postimaging()
			imageTock = GetOSTickCount()
			if(imageTock > 0)
				self.print("elapsed time in imaging: "+(imageTock-imageTick)/1000+" s")
		}
		else
			throw("commanded to perform imaging step when sample is not in SEM")
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

	//TODO: gives error for some reason, comment out destructor for now
	//~workflow(object self)
	//{
	//	// save all tags
	//	ApplicationSavePreferences()
	//}


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
