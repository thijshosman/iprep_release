// $BACKGROUND$
number XYZZY = 0




class SEM_simulator: object
{
	object SEMStagePersistance // stores position where stage is in tag
	object SEMkVPersistance // stores voltage used
	object SEMWDPersistance // stores working distance
	
	object myMediator

	number X, Y, Z // sem coordinates
	// numbers are in mm

	string state
	// unknown
	// clear
	// pickup_dropoff
	// imaging

	// coordinate objects
	// TODO: store these in tags
	object reference
	object scribe_pos
	object fwdGrid
	object pickup_dropoff
	object clear
	object nominal_imaging
	object StoredImaging
	object highGridFront
	object highGridBack
	object lowerGrid

	number blankState
	number HVState

	// working distance used for imaging with digiscan
	number imagingWD

	// voltage to be use for imaging (in kv)
	number kV

	// *** basics ***

	object returnReference(object self)
	{
		return reference
	}

	object returnClear(object self)
	{
		return clear
	}

	object returnPickup_dropoff(object self)
	{
		return pickup_dropoff
	}

	object returnNominal_imaging(object self)
	{
		return nominal_imaging
	}

	object returnStoredImaging(object self)
	{
		return StoredImaging
	}

	object returnHighGridFront(object self)
	{
		return highGridFront
	}

	object returnHighGridBack(object self)
	{
		return highGridBack
	}
	
	object returnLowerGrid(object self)
	{
		return lowerGrid
	}


	
	number returnHVState(object self)
	{
		return HVState
	}

	number returnBlankState(object self)
	{
		return blankState
	}

	string getState(object self)
	{
		return state
	}

	string getSEMState(object self)
	{
		return state
	}

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("SEM", level, text)
	}

	void print(object self, string printstr)
	{
		result("SEM: "+printstr+"\n")
		self.log(2,printstr)
	}

	void setManualState(object self,string newstate)
	{
		SEMStagePersistance.SetState(newstate)
		state = newstate
		self.print("now in state: "+state)
	}

	void Update(object self)
	{
		// divide by 1000 to get milimeters
		X = EMGetStagex()/1000
		Y = EMGetStagey()/1000
		Z = EMGetStagez()/1000
	}

	void printCoords(object self)
	{
		// print function, consistent with other iprep classes
		self.print("X: "+X+", Y: "+Y+", Z: "+Z)
	}

	number getX(object self)
	{
		self.Update()
		return X
	}

	number getY(object self)
	{
		self.Update()
		return Y
	}

	number getZ(object self)
	{
		self.Update()
		return Z
	}

	void setMag(object self, number mag)
	{
		EMSetMagnification(mag)
		EMUpdateCalibrationState()
		self.print("mag set to: "+mag)
	}

	number measureMag(object self)
	{
		return EMGetMagnification()
	}


	void setDesiredkV(object self, number kV1)
	{
		// *** public ***
		// sets the voltage that is desired to do imaging and stores it in tag
		// TODO: synchronize this somehow with the SEM stuff on the microscope menu in DM

		kV = kV1
		SEMkVPersistance.setNumber(kV1)
		self.print("new desired beam energy: "+kV1)

	}

	number getHV(object self)
	{
		// returns voltage (in kV)
		// TODO read hv from microscope
		return kV
	}

	void setkV(object self, number kV1)
	{
		// *** private ***
		// set voltage (in kV)
		EMSetBeamEnergy(kV1*1000)
		self.print("voltage set to: "+kV1)
	}

	void setkVForImaging(object self)
	{
		// *** public ***
		// set the voltage of the microscope to previously determined version

		if (kV == 0)
			throw("voltage not setup")
		else
			self.setkV(kV)

	}

	void setWD(object self, number workingDistance)
	{
		// *** private ***
		// set workingdistance (in mm)

		EMSetFocus(workingdistance*1000)
		imagingWD = workingDistance
		SEMWDPersistance.setNumber(imagingWD)
		self.print("working distance set to: "+workingDistance)

	}

	void setWDForImaging(object self)
	{
		// set workingdistance to previously determined value
		
		if (imagingWD == 0)
			throw("imaging working distance not setup")
		else
			self.setWD(imagingWD)
	}

	void setWDFromDFandScribePos(object self, number dF)
	{
		// set workingdistance to previously determined value
		number actual_scribe_pos_focus = imagingWD
		number new_focus_in_mm = actual_scribe_pos_focus + dF

		if (new_focus_in_mm < 1)
			throw("setWDFromDFandScribePos: invalid focus value (mm): "+new_focus_in_mm )
		else
			EMSetFocus(new_focus_in_mm*1000)
	}

	void setDesiredWD(object self, number WD1)
	{
		// *** public ***
		// sets the working distance that is desired to do imaging and stores it in tag
		// then sets it

		imagingWD = WD1
		SEMWDPersistance.setNumber(WD1)
		self.setWDForImaging()
		self.print("new desired working distance: "+WD1)

	}

	number measureWD(object self)
	{
		// *** public ***
		// measures the working distance currently setup, run after manual setup of imaging
		return EMGetFocus()/1000
	}

	number getWD(object self)
	{
		// returns working distance in mm as stored in tag
		return imagingWD
	}


	// *** SEM move commands ***

	void moveXRel(object self, number dist, number wait)
	{
		self.Update()
		EMSetStageX((X+dist)*1000)
		if(wait)
			EMWaitUntilReady()
	}
	
	void moveYRel(object self, number dist, number wait)
	{
		self.Update()
		EMSetStageY((Y+dist)*1000)
		if(wait)
			EMWaitUntilReady()
	}
	
	void moveZRel(object self, number dist, number wait)
	{
		self.Update()
		EMSetStageZ((Z+dist)*1000)
		if(wait)
			EMWaitUntilReady()

	}

	void moveXAbs(object self, number dist, number wait)
	{
		self.Update()
		EMSetStageX((dist)*1000)
		if(wait)
			EMWaitUntilReady()
	}
	
	void moveYAbs(object self, number dist, number wait)
	{
		self.Update()
		EMSetStageY((dist)*1000)
		if(wait)
			EMWaitUntilReady()
	}
	
	void moveZAbs(object self, number dist, number wait)
	{
		self.Update()
		EMSetStageZ((dist)*1000)
		if(wait)
			EMWaitUntilReady()


	}

	void moveXYabs(object self, number xdist, number ydist, number wait)
	{
		self.Update()
		EMSetStageXY(xdist*1000,ydist*1000)
		if(wait)
			EMWaitUntilReady()

	}

	// *** high level SEM move commands ***

	void goToCoordsZFirst(object self, number Xnew, number Ynew, number Znew)
	{
		// first update Z, most critical coordinate

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}

		
		self.moveZAbs(Znew,1)	

		self.moveXYabs(Xnew,Ynew, 1)
		

		
	}

	void goToCoordsZLast(object self, number Xnew, number Ynew, number Znew)
	{
		// first update x,y, then update z, most critical coordinate
		
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}
		
		self.moveXYabs(Xnew,Ynew, 1)

		self.moveZAbs(Znew,1)
		
		

	}

	// *** state transfers ***

	number checkStateConsistency(object self)
	{ 
		// amount in mm you can be off in x, y and z when checking actual position
		// against state
		number stateThresold = 1
		// check to see that current stage coordinates are consistent with the current state

		//string currentstate = self.state




	}


	void goToPickup_Dropoff(object self)
	{
		self.print("going to pickup_dropoff. current state: "+state)
		
		if (state == "clear")
		{
			self.goToCoordsZFirst(pickup_dropoff.getX(),pickup_dropoff.getY(),pickup_dropoff.getZ())
		}
		else if (state == "pickup_dropoff")
		{
			self.print("already at dropoff/pickup point")
		}
		else
			throw("not allowed to go to pickup position. current state: "+state)
			
		
		self.printCoords()
		self.setManualState("pickup_dropoff")

	}

	void goToClear(object self)
	{
		self.print("going to clear. current state: "+state)
		
		if (state == "pickup_dropoff")
		{
			self.goToCoordsZFirst(clear.getX(),clear.getY(),clear.getZ())
		}
		else if (state == "clear")
		{
			self.print("already at clear point")
		}
		else if (state == "imaging")
		{
			self.goToCoordsZLast(clear.getX(),clear.getY(),clear.getZ())
		}
		else
			throw("not allowed to go to clear. current state is: " +state)

		self.printCoords()
		self.setManualState("clear")
		
	}

	void goToNominalImaging(object self)
	{
		self.print("going to nominal_imaging. current state: "+state)
		
		if (state == "clear")
		{
			self.goToCoordsZFirst(nominal_imaging.getX(),nominal_imaging.getY(),nominal_imaging.getZ())
		}
		else if (state == "imaging")
		{
			self.goToCoordsZFirst(nominal_imaging.getX(),nominal_imaging.getY(),nominal_imaging.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
	
		// update settings since they get reset after move
if (XYZZY)		self.setkVForImaging()
if (XYZZY)		self.setWDForImaging()
		
		object local = nominal_imaging
		if ( local.getdfvalid() )
			self.setWDFromDFandScribePos( local.getdf() )	

		self.printCoords()
		self.setManualState("imaging")

	}

	void goToHighGridFront(object self)
	{
		self.print("going to highGridFront. current state: "+state)
		
		if (state == "imaging")
		{
			self.goToCoordsZFirst(highGridFront.getX(),highGridFront.getY(),highGridFront.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
if (XYZZY)		self.setkVForImaging()
if (XYZZY)		self.setWDForImaging()

		object local = highGridFront
		if ( local.getdfvalid() )
			self.setWDFromDFandScribePos( local.getdf() )	

		
		self.printCoords()
		self.setManualState("imaging")

	}

	void goToHighGridBack(object self)
	{
		self.print("going to highGridBack. current state: "+state)
		
		if (state == "imaging")
		{
			self.goToCoordsZFirst(highGridBack.getX(),highGridBack.getY(),highGridBack.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()
		
		object local = highGridBack
		if ( local.getdfvalid() )
			self.setWDFromDFandScribePos( local.getdf() )	

		self.printCoords()
		self.setManualState("imaging")

	}

	void goToScribeMark(object self)
	{
		self.print("going to scribe mark. current state: "+state)
		
		if (state == "imaging")
		{
			self.goToCoordsZFirst(scribe_pos.getX(),scribe_pos.getY(),scribe_pos.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()
		
		object local = scribe_pos
		if ( local.getdfvalid() )
			self.setWDFromDFandScribePos( local.getdf() )	

		self.printCoords()
		self.setManualState("imaging")

	}

	void goToLowerGrid(object self)
	{
		self.print("going to lowerGrid. current state: "+state)
		
		if (state == "imaging")
		{
			self.goToCoordsZFirst(lowerGrid.getX(),lowerGrid.getY(),lowerGrid.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()

		object local = lowerGrid
		if ( local.getdfvalid() )
			self.setWDFromDFandScribePos( local.getdf() )	

	
		self.printCoords()
		self.setManualState("imaging")

	}

	void goToFWDGrid(object self)
	{
		self.print("going to FWD grid. current state: "+state)
		
		if (state == "imaging")
		{
			self.goToCoordsZFirst(fwdGrid.getX(),fwdGrid.getY(),fwdGrid.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()

		object local = fwdGrid
		if ( local.getdfvalid() )
			self.setWDFromDFandScribePos( local.getdf() )	

	
		self.printCoords()
		self.setManualState("imaging")

	}

	void goToStoredImaging(object self)
	{
		self.print("going to StoredImaging. current state: "+state)

		// it is assumed that this is so close to the imaging state that we will never 
		//have to treat this as a different state from the nominal imaging 
		//position in the state machine

		if (state == "imaging")
		{
			self.goToCoordsZFirst(StoredImaging.getX(),StoredImaging.getY(),StoredImaging.getZ()) // #TODO: change to real coordinates that can be set
			self.print("at stored imaging point")
		}
		else 
			throw("not allowed to go to stored imaging state coming from state: " +state)

		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()

		object local = StoredImaging
		if ( local.getdfvalid() )
			self.setWDFromDFandScribePos( local.getdf() )	


		self.printCoords()
	}

	void calibrateCoordsFromPickup(object self)
	{
		// *** public ***
		//when the stage is at the calibrated pickup/dropoff position and calibrated there for transfer, 
		//calculate the other 3 positions (clear, nominal_imaging and StoredImaging 
		//and save them as absolute coordinates in private data)
		
		self.print("calibrateCoordsFromPickup: using calibrations from 20150903 ")

		// reference point is the point from which other coordinates are inferred
		// the reference point for all coordinates is the pickup/dropoff point now
		// TODO: change from hardcoded value to setting in global tags
		

		// reference.set(7.5,66.5,28.755)
		// reference.set(8,66.5,29.255)		// Pre-8/15 value

//		scribe_pos.set( 31.117, 32.599, 30, 0 )		// 20150815 value; Assumes SEM FWD is coupled to FWD_grid, which is (29.6-7.41)=22.2 mm below the scribe mark
		scribe_pos.set( 30.829, 32.829, 30, 0 )		// 20150827 value; Assumes SEM FWD is coupled to FWD_grid, which is (29.6-7.41)=22.2 mm below the scribe mark
		self.print("scribe position set: ")
		scribe_pos.print()

//		reference.set( scribe_pos.getX()-31.117+9.155, scribe_pos.getY()-32.599+71.133, scribe_pos.getZ()-30+12.25 ) // 20150815 value
//		reference.set( 9.155, 71.133 , 12.25 )		// 20150815 value = > Use the pickup/dropoff point
//		reference.set( scribe_pos.getX()-30.886+9.424, scribe_pos.getY()-32.862+71.396, scribe_pos.getZ()-30+12.753 ) // 20150828 value
		reference.set( 11.174, 71.396 , 12.756 )		// 20150903 value = > Use the pickup/dropoff point
		self.print("reference set: ")
		reference.print()

		// pickup_dropoff is reference point, so simply set them there
		pickup_dropoff.set(reference.getX(), reference.getY(), reference.getZ())
		self.print("pickup_dropoff set: ")
		pickup_dropoff.print()

		// for clear only move in Z from reference point
		clear.set(reference.getX(), reference.getY(), reference.getZ()+2.5)
		self.print("clear set: ")
		clear.print()

		// nominal imaging is approximate middle of sample
		nominal_imaging.set( scribe_pos.getX()-31.117+7.785, scribe_pos.getY()-32.599-13.226, scribe_pos.getZ()-30+30, 2.29 )
		self.print("nominal_imaging set: ")
		nominal_imaging.print()

		// stored imaging starts at the same point as the nominal imaging point
		StoredImaging.set( nominal_imaging.getX(), nominal_imaging.getY(), nominal_imaging.getZ(), nominal_imaging.getdf() )
		self.print("StoredImaging set: ")
		StoredImaging.print()

		// grid on post at back position (serves as sanity check)
		highGridBack.set( scribe_pos.getX()+(-4.831), scribe_pos.getY()+(-4.858), scribe_pos.getZ()-30+30, -0.12 )
		self.print("highGridBack set: ")
		highGridBack.print()

		// grid on post in front position (serves as sanity check)
		highGridFront.set( scribe_pos.getX()+(-39.755), scribe_pos.getY()+(-4.778), scribe_pos.getZ()-30+30, -0.11 )
		self.print("highGridFront set: ")
		highGridFront.print()

		// grid on post for FWD Z-height calibration
		fwdGrid.set( scribe_pos.getX()+22.761, scribe_pos.getY()+(-3.593), scribe_pos.getZ()-30+30, 22.19 )
		self.print("highGridFront set: ")
		highGridFront.print()

		// grid on base plate, formerly used for FWD Z-height cal, now not used // Save to remove all references to lowerGrid
		lowerGrid.set(scribe_pos.getX()+4.747, scribe_pos.getY()+17.652, scribe_pos.getZ()-0.5+16.987, 44.29)
		self.print("lowerGrid set: ")
		lowerGrid.print()

		if ( imagingWD < 1 || imagingWD > 20 )
			imagingWD = 7.41	// #TODO: Hack to ensure approx calibration on Quanta & planar dock

		self.print("all coordinates calculated from scribe position")


	}

	void saveCurrentAsStoredImaging(object self)
	{
		// *** public ***
		// save current position as the StoredImaging point
		
		self.Update()
		StoredImaging.set(self.getX(),self.getY(),self.getZ())
		self.print("new StoredImaging: ")
		StoredImaging.print()

		// TODO: should be saved in tag as part of saved tags

	}

	void saveCustomAsStoredImaging(object self, number x, number y, number z)
	{
		// *** public ***
		// save custom given position as the StoredImaging point
		
		self.Update()
		StoredImaging.set(x, y, z)
		self.print("new StoredImaging: ")
		StoredImaging.print()

		// TODO: should be saved in tag as part of saved tags

	}

	number getShiftX(object self)
	{
		number a,b
		EMGetBeamShift(a,b)
		return a/1000
	}

	number getShiftY(object self)
	{
		number a,b
		EMGetBeamShift(a,b)
		return b/1000
	}

	void setShiftX(object self, number a1)
	{
		// relative shift
		EMChangeBeamShift(a1*1000,0)
		self.print("shifted beam in x by: "+a1)
	}

	void setShiftY(object self, number b1)
	{
		// relative shift
		EMChangeBeamShift(0,b1*1000)
		self.print("shifted beam in y by: "+b1)
	}

	void zeroShift(object self)
	{
		number a,b
		EMGetBeamShift(a,b)
		EMChangeBeamShift(-a,-b)
		self.print("zeroed shift, x: "+-a/1000+", y: "+-b/1000)
	}

	void SEM_simulator(object self)
	{
		// constructor

		SEMStagePersistance = alloc(statePersistance)
		SEMWDPersistance = alloc(statePersistanceNumeric)
		SEMkVPersistance = alloc(statePersistanceNumeric)

		X = 0
		Y = 0
		Z = 0
		state = "unknown"
		
		// allocate SEM coordinates
		scribe_pos = alloc(SEMCoord)
		reference = alloc(SEMCoord)
		pickup_dropoff = alloc(SEMCoord)
		clear = alloc(SEMCoord)
		nominal_imaging = alloc(SEMCoord)
		StoredImaging = alloc(SEMCoord)
		highGridFront = alloc(SEMCoord)
		highGridBack = alloc(SEMCoord)
		lowerGrid = alloc(SEMCoord)
		fwdGrid = alloc(SEMCoord)
		imagingWD = 0
		kV = 0
		self.print("constructor called")

	}

	void init(object self)
	{
		// *** public ***
		// sets state and synchronizes private coord variables

		// register with mediator
		myMediator = returnMediator()
		myMediator.registerSem(self)

		SEMStagePersistance.init("SEMstage")
		SEMkVPersistance.init("SEM:kV")
		SEMWDPersistance.init("SEM:WD")
		imagingWD = SEMWDPersistance.getNumber()

		// zeroing shift does not work on simulator
		//self.zeroShift()
		self.Update()
		self.calibrateCoordsFromPickup()
		self.print("initialized")
		//self.printCoords()
		
		// TODO: add logic to verify that the stage location is indeed what the tag says it was left at last
		// compare the SEM position to the stored position to verify. 

		state = SEMStagePersistance.getState()
		kV = SEMkVPersistance.getNumber()
		

		self.print("init sem voltage: " +kV)
		self.print("init sem working distance: " +imagingWD)
		self.print("init sem stage. starting state: " +state)

	}




	


	void blankOn(object self)
	{
		FEIQuanta_SetBeamBlankState(1)
		blankState = 1
		self.print("beam blanked")
	}

	void blankOff(object self)
	{
		FEIQuanta_SetBeamBlankState(0)
		blankState = 0
		self.print("beam unblanked")
	}

	void HVOn(object self)
	{
		FEIQuanta_SetHighTensionOnOff(1)
		HVState = 1
		self.print("HV on")
	}

	void HVOff(object self)
	{
		FEIQuanta_SetHighTensionOnOff(0)
		HVState = 0
		self.print("HV off")
	}	

/*
	~SEM_IPrep(object self)
	{
		// save last known stage position to tag
		self.setManualState(state)

		// make sure these values are saved as numeric
		SEMkVPersistance.setNumber(kV)
		SEMWDPersistance.setNumber(imagingWD)
	}
*/


}



//object aSEM = alloc(SEM_IPrep)



