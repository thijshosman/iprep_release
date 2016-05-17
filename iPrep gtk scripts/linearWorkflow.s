// $BACKGROUND$
number XYZZY = 0
class workflow: object
{

	// timer numbers
	number tick, tock
	object aTimer

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

		// timer for individual steps
		aTimer = alloc(timer)
		aTimer.init(1)

		self.print(mode+"\n")

		if (mode == "planar")
		{
			// planar mode selected
			if (sim_dock == 1)
				mySEMdock = createDock(1)
			else 
				mySEMdock = createDock(2)

		} 
		else if (mode == "ebsd")
		{
			// ebsd mode selected
			if (sim_dock == 1)
				mySEMdock = createDock(1)
			else 
				mySEMdock = createDock(3)

		}	
		else
		{
			throw("system mode (planar or ebsd) not set!")
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



	// position calibrations as part of workflow

	void setDefaultPositionsPlanar(object self)
	{
		// save default positions in global tags
		self.print("setDefaultPositions: setting default positions for use with Planar dock ")
		self.print("setDefaultPositions: using calibrations from 20150903 ")

		myTransfer.setPositionTag("outofway",0) // home position, without going through homing sequence
		myTransfer.setPositionTag("prehome",15) // location where we can move to close to home from where we home
		myTransfer.setPositionTag("open_pecs",27) // location where arms can open in PECS  // #20150819: was 29, #20150903: was 28
		myTransfer.setPositionTag("pickup_pecs",48) // location where open arms can be used to pickup sample // #20150827: was 48.5, #20150903: was 49.5
		myTransfer.setPositionTag("beforeGV",100) // location where open arms can be used to pickup sample
		myTransfer.setPositionTag("dropoff_sem",545) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
		myTransfer.setPositionTag("pickup_sem",545) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
		myTransfer.setPositionTag("backoff_sem",430) // location where gripper arms can safely open/close in SEM chamber
		myTransfer.setPositionTag("dropoff_pecs",46.50) // location where sample gets dropped off in PECS // #20150827: was 45.5
		myTransfer.setPositionTag("dropoff_pecs_backoff",47.50) // location where sample gets dropped off in PECS // #20150827: was 46.5
	}

	void setDefaultPositionsEBSD(object self)
	{
		// save default positions in global tags
		self.print("setDefaultPositions: setting positions for use with EBSD dock ")

		myTransfer.setPositionTag("outofway",0) // home position, without going through homing sequence
		myTransfer.setPositionTag("prehome",15) // location where we can move to close to home from where we home
		myTransfer.setPositionTag("open_pecs",27) // location where arms can open in PECS  // #20150819: was 29, #20150903: was 28
		myTransfer.setPositionTag("pickup_pecs",48) // location where open arms can be used to pickup sample // #20150827: was 48.5, #20150903: was 49.5
		myTransfer.setPositionTag("beforeGV",100) // location where open arms can be used to pickup sample
		myTransfer.setPositionTag("dropoff_sem",513) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
		myTransfer.setPositionTag("pickup_sem",513) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
		myTransfer.setPositionTag("backoff_sem",430) // location where gripper arms can safely open/close in SEM chamber
		myTransfer.setPositionTag("dropoff_pecs",46.50) // location where sample gets dropped off in PECS // #20150827: was 45.5
		myTransfer.setPositionTag("dropoff_pecs_backoff",47.50) // location where sample gets dropped off in PECS // #20150827: was 46.5
	}

	void setDefaultPositions(object self)
	{

		// save calibrated positions for transfer for correct dock
		if (mode == "planar")
			self.setDefaultPositionsPlanar()
		else if (mode == "ebsd")
			self.setDefaultPositionsEBSD()
		else
			throw("system mode not set!")
	}	

	void calibrateForMode(object self)
	{
		// calibrate SEMdock and parker for this particular mode
		self.print("calibrating sem postions and parker positions for mode")

		// parker transfer		
		self.setDefaultPositions() // queries mode and sets parker positions correctly
		myTransfer.init()

		mode = getSystemMode()
		self.print("mode = "+mode)
		
		number sim_dock_simulate =  GetTagValue("IPrep:simulation:dock")

		if (mode == "planar")
		{
			if (sim_dock_simulate)
				mySEMdock = createDock(1)
			else 
				mySEMdock = createDock(2)
		} 
		else if (mode == "ebsd")
		{
			if (sim_dock_simulate)
				mySEMdock = createDock(1)
			else 
				mySEMdock = createDock(3)


		}
		
		// init SEM Dock
		mySEMdock.init()

		// now calibrate SEM dock, which sets reference
		mySEMdock.calibrateCoords()

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

	void fastSemToPecs(object self)
	{
		// this method is part of speed improvements in the workflow. we try to get the sample as fast
		// between the two points as a synchronous workflow allows. 

		// lockout PECS UI
		aTimer.tick("pecs lock")
		myPecs.lockout()
		aTimer.tock()

		// move pecs stage down
		aTimer.tick("pecs stage down")
		myPecs.moveStageDown()
		aTimer.tock()

		// home pecs stage
		aTimer.tick("home pecs stage")
		myPecs.stagehome()
		aTimer.tock()

		// move SEM stage to clear point
		aTimer.tick("sem to clear")
		mySEM.goToClear()
		aTimer.tock()

		// move SEM dock clamp up to release sample
		aTimer.tick("dock unclamp")
		mySEMdock.unclamp()
		aTimer.tock()

		// move SEM stage to pickup point
		aTimer.tick("sem to pickup_dropoff")
		mySEM.goToPickup_Dropoff()
		aTimer.tock()

		// open GV
		aTimer.tick("open gv")
		myPecs.openGVandCheck()
		aTimer.tock()

		// move transfer system to location where arms can safely open
		aTimer.tick("transfer to backoff_sem")
		myTransfer.move("backoff_sem")
		aTimer.tock()

		// gripper open
		aTimer.tick("gripper open")
		myGripper.open()
		aTimer.tock()

		// move transfer system to pickup point
		aTimer.tick("transfer to pickup_sem")
		myTransfer.move("pickup_sem")
		aTimer.tock()

		continueCheck()

		// gripper close, sample is picked up
		aTimer.tick("gripper close")
		myGripper.close()
		aTimer.tock()
		
		// move SEM stage to clear point so that dock is out of the way
		aTimer.tick("sem to clear")
		mySEM.goToClear()
		aTimer.tock()

		if (GetTagValue("IPrep:simulation:samplechecker") == 1)
		{
			// check that sample is no longer present in dock, if simulation of dock is off
			returnMediator().compareSamplePresent(0)

		}

		// slide sample into dovetail
		aTimer.tick("transfer to dropoff_pecs")
		myTransfer.move("dropoff_pecs")
		aTimer.tock()

		// back off 1 mm to relax tension on springs
		aTimer.tick("transfer to pecs_backoff")
		myTransfer.move("dropoff_pecs_backoff")
		aTimer.tock()

		// open gripper arms
		aTimer.tick("gripper open")
		myGripper.open()
		aTimer.tock()
	
		// move gripper back so that arms can close
		aTimer.tick("transfer to open_pecs")
		myTransfer.move("open_pecs")
		aTimer.tock()
		
		// close gripper arms
		aTimer.tick("gripper close")
		myGripper.close()
		aTimer.tock()
		
		// go to prehome
		myTransfer.move("prehome")
		aTimer.tock()

		// move gripper out of the way by homing
		aTimer.tick("transfer home")
		myTransfer.home()
		aTimer.tock()

		// close GV
		aTimer.tick("close gate valve")
		myPecs.closeGVandCheck()
		aTimer.tock()

		// move SEM dock clamp down to safely move it around inside SEM
		aTimer.tick("dock clamp")
		mySEMdock.clamp()
		aTimer.tock()

		// turn transfer system off
		aTimer.tick("transfer turnoff")
		myTransfer.turnOff()
		aTimer.tock()

		// unlock
		aTimer.tick("pecs unlock")
		myPecs.unlock()
		aTimer.tock()

	}

	void fastPecsToSem(object self)
	{
		// this method is part of speed improvements in the workflow. we try to get the sample as fast
		// between the two points as a synchronous workflow allows. 

		// lockout PECS UI
		aTimer.tick("pecs lock")
		myPecs.lockout()
		aTimer.tock()

		// lower pecs stage
		aTimer.tick("pecs lower")
		myPecs.moveStageDown()
		aTimer.tock()

		// home pecs stage
		aTimer.tick("pecs home")
		myPecs.stageHome()
		aTimer.tock()

		// go to where gripper arms can safely open
		aTimer.tick("transfer to open_pecs")
		myTransfer.move("open_pecs")
		aTimer.tock()

		// open gripper arms
		aTimer.tick("gripper open")
		myGripper.open()
		aTimer.tock()

		// move forward to where sample can be picked up
		aTimer.tick("transfer to pickup_pecs")
		myTransfer.move("pickup_pecs")
		aTimer.tock()

		continueCheck()

		// close gripper arms
		aTimer.tick("gripper close")
		myGripper.close()
		aTimer.tock()

		continueCheck()

		// open GV
		aTimer.tick("gate valve open")
		myPecs.openGVandCheck()
		aTimer.tock()

		// move sem stage to clear point
		aTimer.tick("sem to clear")
		mySEM.goToClear()
		aTimer.tock()
	
		// move SEM dock up to allow sample to go in
		aTimer.tick("dock unclamp")
		mySEMdock.unclamp()
		aTimer.tock()

		// move into chamber
		aTimer.tick("transfer to dropoff_sem")
		myTransfer.move("dropoff_sem")
		aTimer.tock()

		continueCheck()

		// SEM Stage to dropoff position
		aTimer.tick("sem to pickup_dropoff")
		mySEM.goToPickup_Dropoff()
		aTimer.tock()

		continueCheck()

		// gripper open to release sample
		aTimer.tick("gripper open")
		myGripper.open()
		aTimer.tock()

		// parker back off to where arms can open/close
		aTimer.tick("transfer to backoff_sem")
		myTransfer.move("backoff_sem")
		aTimer.tock()

		// gripper close
		aTimer.tick("gripper close")
		myGripper.close()
		aTimer.tock()

		// parker move back to prehome
		aTimer.tick("transfer to prehome")
		myTransfer.move("prehome")
		aTimer.tock()

		// parker home and turn off to prevent singing
		aTimer.tick("transfer home")
		myTransfer.home()
		aTimer.tock()

		// close gate valve
		aTimer.tick("gate valve close")
		myPecs.closeGVandCheck()
		aTimer.tock()

		// SEM stage move to clear position
		aTimer.tick("sem to clear")
		mySEM.goToClear()
		aTimer.tock()

		// move SEM dock down to clamp
		aTimer.tick("dock clamp")
		mySEMdock.clamp()
		aTimer.tock()

		if (GetTagValue("IPrep:simulation:samplechecker") == 1)
		{
			// check that sample is present
			returnMediator().compareSamplePresent(1)
		}

		// move SEM stage to nominal imaging plane
		aTimer.tick("sem to imaging")
		mySEM.goToNominalImaging()
		aTimer.tock()

		// turn transfer system off
		aTimer.tick("transfer off")
		myTransfer.turnOff()
		aTimer.tock()

		// unlock
		aTimer.tick("pecs unlock")
		myPecs.unlock()
		aTimer.tock()

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
		myTransfer.turnOff()

		// unlock
		myPecs.unlock()
	}



	void executeMillingStep(object self, number simulation, number timeout)
	{
		self.print("milling started...")

		myPecs.unlock()

		// raise stage
		myPecs.moveStageUp()

		// start milling. milling state is checked by state machine 
		if (simulation == 0)
			myPecs.startMilling()
		else
			myPecs.stageHome()

		self.print("hold Option + Shift to skip remainder of milling milling")

		tick = GetOSTickCount()		
		
		// #todo: get timeout for EBSD from tag
		
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

	void preImaging(object self)
	{
		// prepares system for taking of image, like setting HV and WD settings and unblanking beam

		//mySEM.blankOff()

		self.print("preimaging done")
	}
	
	void postImaging(object self)
	{
		//mySEM.blankOn()
		
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
	//the specifics of a transfer is in the workflow class

	object workflowStatePersistance
	object lastCompletedStep
	number percentage
	string workflowState	
	object myWorkflow

	number Tick
	number Tock

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
			myWorkflow.reseat()
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
