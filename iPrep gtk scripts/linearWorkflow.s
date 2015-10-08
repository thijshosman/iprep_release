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

	// haltflag used to interrupt workflow elements if set
	object haltFlag

	
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
		// TODO: make abstract factory, use tags to define which class
		// TODO: EBSD dock option

		self.print("--- start init ---")

		// init gripper
		myGripper = createGripper(1)
		myGripper.init()
		
		// init SEM Dock
		mySEMdock = createDock(2)
		mySEMdock.init()

		// init parker
		myTransfer = createTransfer(1)
		myTransfer.init()

		// init PECS 
		myPecs = createPecs(1)
		myPecs.init()

		// init SEM
		mySEM = createSem(1)
		mySEM.init()

		// init PECS camera
		myPecsCamera = createPecsCamera(1)
		myPecsCamera.init()

		// init Digiscan
		myDigiscan = creatDigiscan(1)
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

	void setDefaultSEMPositions(object self)
	{
		// set the default SEM coord tags and populate them with default values
		// will later be overwritten by calibration routines in sem_iprep class
		// this method is not intended to be used other than during setup
		// and the only reason it exists is because it is a lot of work to manually
		// type all these tags

		object tempCoord = alloc(SEMCoord)
		
		//tempCoord.set(object self, string name1, number Xn, number Yn, number Zn, number dfn)

		// each dock has two calibrated points
		//	-reference, which is the manually calibrated pickup_dropoff point
		//	-scribe_pos, which is the position of the scribe mark on the dock

		// for each dock, all the imaging positions have a known vector from the scribe_pos
		// similarly, the clear positions has a known vector from the reference point

		// transfer between clear and nominal imaging is considered safe as long as it is known
		// in which direction we move first

		// EBSD dock points

		tempCoord.set("reference_ebsd", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		tempCoord.set("scribe_pos_ebsd", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		// planar dock points

		tempCoord.set("reference_planar", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		tempCoord.set("scribe_pos_planar", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)		

		// inferred points + used points

		// manually calibrated "pickup_dropoff" point. used to infer "clear"
		tempCoord.set("reference", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		// scribe, used to infer all imaging positions
		tempCoord.set("scribe_pos", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		// positions defined on dock inferred from 

		tempCoord.set("highGridFront", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		tempCoord.set("highGridBack", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		tempCoord.set("lowergrid", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)	

		tempCoord.set("fwdGrid", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)
		
		// positions defined on dock

		tempCoord.set("pickup_dropoff", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		tempCoord.set("clear", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		tempCoord.set("nominal_imaging", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

		tempCoord.set("stored_imaging", 0, 0, 0, 0)
		returnSEMCoordManager.addCoord(tempCoord)

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

		// check that sample is no longer present in dock
/*		if (mySEMdock.checkSamplePresent())
		{
			self.print("sample still detected in dock after pickup")
			throw("sample still detected in dock after pickup")
		}
*/
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

		// move SEM dock clamp down to safely move it around inside SEM
		mySEMdock.clamp()

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

		continueCheck()

		// close gripper arms
		myGripper.close()

		continueCheck()

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
	
		// parker move back to prehome
		myTransfer.move("prehome")

		// parker home and turn off to prevent singing
		myTransfer.home()

		// close gate valve
		myPecs.closeGVandCheck()

		// SEM stage move to clear position
		mySEM.goToClear()

		// move SEM dock down to clamp
		mySEMdock.clamp()

		// check that sample is present
/*		if (!mySEMdock.checkSamplePresent())
		{
			self.print("sample not detected in dock after dropoff")
			throw("sample not detected in dock after dropoff")
		}
*/
		// move SEM stage to nominal imaging plane
		mySEM.goToNominalImaging()

		// turn transfer system off
		myTransfer.turnOff()

	}

	void reseat(object self)
	{
		// move sample out and into dovetail 
		// use after sample transfer so that it will be in the same position as during transfer

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

		// move SEM dock clamp down to safely move it around inside SEM
		mySEMdock.clamp()

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
	object lastCompletedStep
	number percentage
	string workflowState	
	object myWorkflow

	number imageTick
	number imageTock

	// flag set when system is in weird state
	object deadFlag

	void print(object self, string str1)
	{
		result("StateMachine: "+str1+"\n")
	}

	void workflowStateMachine(object self)
	{
		workflowState = "UNKNOWN" // init value, undefined
		workflowStatePersistance = alloc(statePersistance)
		workflowStatePersistance.init("workflowState")
		lastCompletedStep = alloc(statePersistance)
		lastCompletedStep.init("lastCompletedStep")

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

		// reset imageTock 
		imageTock=0

	}

	void reseat(object self)
	{
		// *** public ***
		// uses workflow methods to reseat sample 
		if (workflowState == "PECS")
		{
			self.changeWorkflowState("reseating")
			myWorkflow.reseat()
		}
		else
			throw("not allowed to reseat when not in PECS")
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
			lastCompletedStep.setState("SEM")
			

		}
		else
			throw("not allowed to transfer from PECS to SEM. current state is: "+workflowState)
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
			lastCompletedStep.setState("PECS")


		}
		else
			throw("not allowed to transfer from SEM to PECS. current state is: "+workflowState)

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
				


		}
		else
			throw("commanded to perform milling step when sample is not in PECS")

	}

	void stop_mill(object self)
	{
		// *** public ***
		// stop imaging	

		if (workflowState == "PECS")
		{	
			lastCompletedStep.setState("MILL")
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
			lastCompletedStep.setState("IMAGE")
			imageTock = GetOSTickCount()
			if(imageTock > 0)
				self.print("elapsed time in imaging: "+(imageTock-imageTick)/1000+" s")
		}
		else
			throw("commanded to perform imaging step when sample is not in SEM")
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
