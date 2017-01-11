// $BACKGROUND$
number XYZZY = 0



class SEM_simulator: object
{
	object SEMStagePersistance // stores position where stage is in tag
	
	// phase out
	object SEMkVPersistance // stores voltage used
	object SEMWDPersistance // stores working distance

	// are SEM coords in manager calibrated? #todo: implement
	number coords_calibrated // 0 = no, 1 = yes

	object myMediator

	number X, Y, Z // sem coordinates
	// numbers are in mm

	// the threshold that determines if coord positions are close enough for the state 
	// to be considered consistent
	number consistencyThreshold

	string state
	// unknown
	// clear
	// pickup_dropoff
	// imaging

	//object mySEMCoordManager

	// simualtion coordinate object
	object myLocation


	// coordinate objects
	// TODO: store these in tags
	//object reference
	//object scribe_pos
	//object fwdGrid
	//object pickup_dropoff
	//object clear
	//object nominal_imaging
	//object StoredImaging
	//object highGridFront
	//object highGridBack
	//object lowerGrid

	string currentImagingPosition

	number blankState
	number HVState

	// working distance used for imaging with digiscan
	number imagingWD

	// voltage to be use for imaging (in kv)
	number kV

	void WorkaroundQuantaMagBug(object self)
	{
		result("skipping quanta mag bug workaround\n")
	}

	// *** basics ***

	
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

	string getCurrentImagingPosition(object self)
	{
		return currentImagingPosition
	}

	void setCurrentImagingPosition(object self, string name1)
	{
		currentImagingPosition = name1
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

	number setCoordsCalibrated(object self, number cal)
	{
		coords_calibrated = 1
		self.print("sem coordinates are now calibrated")
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
		//X = EMGetStagex()/1000
		//Y = EMGetStagey()/1000
		//Z = EMGetStagez()/1000
		//result("debug\n")
		//self.print("updating xyz to mylocations position: ")
		//myLocation.print()
		//result("/debug\n")
		//X=myLocation.getX()
		//Y=myLocation.getY()
		//Z=myLocation.getZ()

	}

	void UpdateSimulator(object self)
	{
		returnSEMCoordManager().addCoord(myLocation)

	}

	void printCoords(object self)
	{
		// print function, consistent with other iprep classes
		self.print("X: "+self.getX()+", Y: "+self.getY()+", Z: "+self.getZ())
	}

	number getX(object self)
	{
		return myLocation.getX()
	}

	number getY(object self)
	{
		return myLocation.getY()
	}

	number getZ(object self)
	{
		return myLocation.getZ()
	}

	void setMag(object self, number mag)
	{
		//EMSetMagnification(mag)
		//EMUpdateCalibrationState()
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
		//EMSetBeamEnergy(kV1*1000)
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

		//EMSetFocus(workingdistance*1000)
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
		//return EMGetFocus()/1000
		return imagingWD
	}

	void setDesiredWDToCurrent(object self)
	{
		// *** public ***
		// measures the working distance and sets the desired value to that
		number cur = self.measureWD()
		self.setDesiredWD(cur)

	}


	// *** SEM move commands ***

	void moveXRel(object self, number dist, number wait)
	{
		self.Update()
		//EMSetStageX((X+dist)*1000)
		myLocation.setX((self.getX()+dist))
		//if(wait)
			//EMWaitUntilReady()
		//self.UpdateSimulator()
	}
	
	void moveYRel(object self, number dist, number wait)
	{
		self.Update()
		//EMSetStageY((Y+dist)*1000)
		myLocation.setY((self.getY()+dist))
		//if(wait)
			//EMWaitUntilReady()
		//self.UpdateSimulator()
	}
	
	void moveZRel(object self, number dist, number wait)
	{
		self.Update()
		//EMSetStageZ((Z+dist)*1000)
		myLocation.setZ((self.getZ()+dist))
		//if(wait)
			//EMWaitUntilReady()
		//self.UpdateSimulator()

	}

	void moveXAbs(object self, number dist, number wait)
	{
		self.Update()
		//EMSetStageX((dist)*1000)
		myLocation.setX((dist))
		//if(wait)
			//EMWaitUntilReady()
		//self.UpdateSimulator()
	}
	
	void moveYAbs(object self, number dist, number wait)
	{
		self.Update()
		//EMSetStageY((dist)*1000)
		myLocation.setY((dist))
		//if(wait)
			//EMWaitUntilReady()
		//self.UpdateSimulator()
	}
	
	void moveZAbs(object self, number dist, number wait)
	{
		self.Update()
		//EMSetStageZ((dist)*1000)
		myLocation.setZ(dist)
		//if(wait)
			//EMWaitUntilReady()
		//self.UpdateSimulator()

	}

	void moveXYabs(object self, number xdist, number ydist, number wait)
	{
		self.Update()
		//EMSetStageXY(xdist*1000,ydist*1000)
		myLocation.setX(xdist)
		myLocation.setY(ydist)
		//if(wait)
			//EMWaitUntilReady()
		//self.UpdateSimulator()

	}

	// *** high level SEM move commands ***

	void goToCoordsZFirst(object self, number Xnew, number Ynew, number Znew)
	{
		// first update Z, most critical coordinate



		
		self.moveZAbs(Znew,1)	

		self.moveXYabs(Xnew,Ynew, 1)
		
		self.UpdateSimulator()
		
	}

	void goToCoordsZLast(object self, number Xnew, number Ynew, number Znew)
	{
		// first update x,y, then update z, most critical coordinate


		self.moveXYabs(Xnew,Ynew, 1)

		self.moveZAbs(Znew,1)
		
		self.UpdateSimulator()

	}



	// *** state transfers ***

	number checkPositionConsistency(object self, string coordName)
	{
		// check to see if the sem position defined in coordName corresponds to current position
		// (within consistencyThreshold)

		self.update()

		object aCoord = returnSEMCoordManager().getCoordAsCoord(coordName)

		if( abs(aCoord.getX() - self.getX())<consistencyThreshold && abs(aCoord.getY() - self.getY())<consistencyThreshold && abs(aCoord.getZ() - self.getZ())<consistencyThreshold  )
		{
			// success
			return 1
		}
		else
		{
			//print("not in right position: X = "+X+", should be "+aCoord.getX())
			//print("Y = "+Y+", should be "+aCoord.getY())
			//print("Z = "+Z+", should be "+aCoord.getZ())
			return 0
		}


	}

	number checkStateConsistency(object self)
	{ 
		// amount in mm you can be off in x, y and z when checking actual position
		// against state
		number stateThresold = 1
		// check to see that current stage coordinates are consistent with the current state

		string currentstate = state

		if (state == "clear")
		{
			return self.checkPositionConsistency("clear")
		}
		else if (state == "pickup_dropoff")
		{
			return self.checkPositionConsistency("pickup_dropoff")
		}
		else
		{
			// #TODO: imaging is a state that belongs to a lot of coordinates, so we cannot check that
			// #easily. assuming it is right
			return 1
		}

	}


	void goToPickup_Dropoff(object self)
	{
		self.print("going to pickup_dropoff. current state: "+state)

		if (!self.checkStateConsistency())
		{
			self.print("state inconsistent, SEM stage is not where state machine thinks it is")
			throw("state inconsistent, SEM stage is not where state machine thinks it is")
		}

		object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")

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

	void homeToClear(object self)
	{
		// intended to be used to go to the clear position as a 'homing' point manually
		// disabling consistency checks. intended to be installed as menu command

		object clear = returnSEMCoordManager().getCoordAsCoord("clear")
		clear.print()

		// check that dock is clamped
		if (myMediator.getDockState() != "clamped")
		{
			self.print("safetycheck: dock not clamped")
			if (!okcanceldialog("trying to move SEM with dock unclamped. clamp dock and continue? "))
			{
				throw("safetycheck: trying to move dock to clear position with dock unclamped. user canceled option to clamp")
			}
			else
			{
				// try again
				self.homeToClear()
			}
		}

		self.print("going to clear with checks disabled")
		self.goToCoordsZFirst(clear.getX(),clear.getY(),clear.getZ())
		self.printCoords()
		self.setManualState("clear")

	}



	void goToClear(object self)
	{
		self.print("going to clear. current state: "+state)

		if (!self.checkStateConsistency())
		{
			self.print("state inconsistent, SEM stage is not where state machine thinks it is")
			if (okcanceldialog("SEM is not where state machien thinks it is. home to clear anway?"))
			{
				self.homeToClear()
			}
			else
				throw("state inconsistent, SEM stage is not where state machine thinks it is")
		}

		object clear = returnSEMCoordManager().getCoordAsCoord("clear")

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
		
		if (!self.checkStateConsistency())
		{
			self.print("state inconsistent, SEM stage is not where state machine thinks it is")
			throw("state inconsistent, SEM stage is not where state machine thinks it is")
		}

		object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}

		// check that dock is clamped
		if (myMediator.getDockState() != "clamped")
		{
			self.print("safetycheck: dock not clamped")
			if (!okcanceldialog("trying to move SEM with dock unclamped. clamp dock and continue? "))
			{
				throw("safetycheck: trying to move dock to nominal imaging with dock unclamped. user canceled option to clamp")
			}
			else
			{
				// try again
				self.goToNominalImaging()
			}
		}


		if (state == "clear")
		{
			self.goToCoordsZFirst(nominal_imaging.getX(),nominal_imaging.getY(),nominal_imaging.getZ())
			self.setCurrentImagingPosition("nominal_imaging")
		}
		else if (state == "imaging")
		{
			self.goToCoordsZFirst(nominal_imaging.getX(),nominal_imaging.getY(),nominal_imaging.getZ())
			self.setCurrentImagingPosition("nominal_imaging")
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
	
		// update settings since they get reset after move
if (XYZZY)		self.setkVForImaging()
if (XYZZY)		self.setWDForImaging()
/*		
		object local = nominal_imaging
		if ( local.getdfvalid() )
			self.setWDFromDFandScribePos( local.getdf() )	
*/
		self.printCoords()
		self.setManualState("imaging")

	}

	void goToHighGridFront(object self)
	{
		self.print("going to highGridFront. current state: "+state)

		object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}
		
		if (state == "imaging")
		{
			self.goToCoordsZFirst(highGridFront.getX(),highGridFront.getY(),highGridFront.getZ())

		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
if (XYZZY)		self.setkVForImaging()
if (XYZZY)		self.setWDForImaging()

		//object local = highGridFront
		//if ( local.getdfvalid() )
		//	self.setWDFromDFandScribePos( local.getdf() )	

		
		self.printCoords()
		self.setManualState("imaging")

	}

	void goToHighGridBack(object self)
	{
		self.print("going to highGridBack. current state: "+state)

		object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}
		
		if (state == "imaging")
		{
			self.goToCoordsZFirst(highGridBack.getX(),highGridBack.getY(),highGridBack.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()
		
		//object local = highGridBack
		//if ( local.getdfvalid() )
		//	self.setWDFromDFandScribePos( local.getdf() )	

		self.printCoords()
		self.setManualState("imaging")

	}

	void goToScribeMark(object self)
	{
		self.print("going to scribe mark. current state: "+state)

		object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos")

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}

		
		if (state == "imaging")
		{
			self.goToCoordsZFirst(scribe_pos.getX(),scribe_pos.getY(),scribe_pos.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()
		
		//object local = scribe_pos
		//if ( local.getdfvalid() )
		//	self.setWDFromDFandScribePos( local.getdf() )	

		self.printCoords()
		self.setManualState("imaging")

	}

	void goToLowerGrid(object self)
	{
		self.print("going to lowerGrid. current state: "+state)
		
		object lowerGrid = returnSEMCoordManager().getCoordAsCoord("lowerGrid")

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}

		if (state == "imaging")
		{
			self.goToCoordsZFirst(lowerGrid.getX(),lowerGrid.getY(),lowerGrid.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()

		//object local = lowerGrid
		//if ( local.getdfvalid() )
		//	self.setWDFromDFandScribePos( local.getdf() )	

	
		self.printCoords()
		self.setManualState("imaging")

	}

	void goToFWDGrid(object self)
	{
		self.print("going to FWD grid. current state: "+state)

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}

		object fwdGrid = returnSEMCoordManager().getCoordAsCoord("fwdGrid")

		if (state == "imaging")
		{
			self.goToCoordsZFirst(fwdGrid.getX(),fwdGrid.getY(),fwdGrid.getZ())
		}
		else
			throw("not allowed to go to imaging point. current state: " +state)
		
		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()

		//object local = fwdGrid
		//if ( local.getdfvalid() )
		//	self.setWDFromDFandScribePos( local.getdf() )	

	
		self.printCoords()
		self.setManualState("imaging")

	}

	void goToStoredImaging(object self)
	{
		self.print("going to StoredImaging. current state: "+state)

		object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}

		// it is assumed that this is so close to the imaging state that we will never 
		//have to treat this as a different state from the nominal imaging 
		//position in the state machine

		if (state == "imaging")
		{
			self.goToCoordsZFirst(StoredImaging.getX(),StoredImaging.getY(),StoredImaging.getZ()) 
			self.setCurrentImagingPosition("StoredImaging")
			self.print("at stored imaging point")
		}
		else if (state = "clear")
		{
			self.goToNominalImaging()
			self.goToStoredImaging()
		}
		else 
			throw("not allowed to go to stored imaging state coming from state: " +state)

		// update settings since they get reset after move
		if (XYZZY)		self.setkVForImaging()
		if (XYZZY)		self.setWDForImaging()

		//object local = StoredImaging
		//if ( local.getdfvalid() )
		//	self.setWDFromDFandScribePos( local.getdf() )	


		self.printCoords()
	}


	// *** variable position that is in SEMCoordManager ***

	void goToImagingPosition(object self, string name1)
	{
		// go to this coordinate, that assumes the SEM stage is in the imaging state
		

		// make sure we have a coord with this name
		if (returnSEMCoordManager().checkCoordExistence(name1) == 0)
		{
			self.print("cannot go to "+name1+", coord does not exist!")
			throw("cannot go to "+name1+", coord does not exist!")
		}

		object imagingCoord = returnSEMCoordManager().getCoordAsCoord(name1)

		// check that parker is out of the way
		if (myMediator.getCurrentPosition() > 400)
		{
			self.print("safetycheck: trying to move SEM with parker position > 400")
			throw("safetycheck: trying to move SEM with parker position > 400")
		}

		// make sure we are in the imaging state
		if (state == "imaging")
		{
			self.goToCoordsZFirst(imagingCoord.getX(),imagingCoord.getY(),imagingCoord.getZ()) 
			self.print("at "+imagingCoord.getName())

			self.setCurrentImagingPosition(imagingCoord.getName())
		}
		else if (state = "clear")
		{
			self.print("at clear, first going to nominal imaging")
			self.goToNominalImaging()
			self.goToImagingPosition(name1)
		}
		else 
			throw("not allowed to go to stored imaging state coming from state: " +state)




	}



	// *** calibration ***

	// DEPRECATED: now implemented in SEMCoordManager directly

	void saveCurrentAsStoredImaging(object self)
	{
		// *** public ***
		// save current position as the StoredImaging point
		
		self.Update()
		
		object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")

		StoredImaging.set(self.getX(),self.getY(),self.getZ())
		self.print("new StoredImaging: ")
		StoredImaging.print()

		returnSEMCoordManager().addCoord(StoredImaging)

		

	}

	void saveCustomAsStoredImaging(object self, number x, number y, number z)
	{
		// *** public ***
		// save custom given position as the StoredImaging point
		
		object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")

		self.Update()
		StoredImaging.set(x, y, z)
		self.print("new StoredImaging: ")
		StoredImaging.print()

		returnSEMCoordManager().addCoord(StoredImaging)

	}

	object returnStoredImaging(object self)
	{
		// returns the coord object that defines StoredImaging from the SEMCoordManager
		// method is here for legacy reasons

		return returnSEMCoordManager().getCoordAsCoord("StoredImaging")

	}


	number getShiftX(object self)
	{
		number a,b
		//EMGetBeamShift(a,b)
		return a/1000
	}

	number getShiftY(object self)
	{
		number a,b
		//EMGetBeamShift(a,b)
		return b/1000
	}

	void setShiftX(object self, number a1)
	{
		// relative shift
		//EMChangeBeamShift(a1*1000,0)
		self.print("shifted beam in x by: "+a1)
	}

	void setShiftY(object self, number b1)
	{
		// relative shift
		//EMChangeBeamShift(0,b1*1000)
		self.print("shifted beam in y by: "+b1)
	}

	void zeroShift(object self)
	{
		number a,b
		//EMGetBeamShift(a,b)
		//EMChangeBeamShift(-a,-b)
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
		// DEPRECATED: now coming from SEMCoordManager
		//scribe_pos = alloc(SEMCoord)
		//reference = alloc(SEMCoord)
		//pickup_dropoff = alloc(SEMCoord)
		//clear = alloc(SEMCoord)
		//nominal_imaging = alloc(SEMCoord)
		//StoredImaging = alloc(SEMCoord)
		//highGridFront = alloc(SEMCoord)
		//highGridBack = alloc(SEMCoord)
		//lowerGrid = alloc(SEMCoord)
		//fwdGrid = alloc(SEMCoord)
		imagingWD = 0
		kV = 0
		self.print("constructor called")

	}

	void init(object self)
	{
		// *** public ***
		// sets state 

		// simulator specific: add a coordinate that represents the active coordinate
		// active coord
		myLocation = alloc(SEMCoord)
		myLocation.set(0,0,0)

		coords_calibrated = 0

		// register with mediator
		myMediator = returnMediator()
		myMediator.registerSem(self)

		consistencyThreshold = 1 // 1 mm

		SEMStagePersistance.init("SEMstage")
		SEMkVPersistance.init("SEM:kV") // deprecate
		SEMWDPersistance.init("SEM:WD") // deprecate
		imagingWD = SEMWDPersistance.getNumber() // deprecate

		//self.zeroShift()
		self.Update()
		//self.calibrateCoordsFromPickup() moved to dock object
		self.print("initialized")
		

		state = SEMStagePersistance.getState()
		kV = SEMkVPersistance.getNumber()

		// since this is a simulator, set the myLocation coordinates to saved position

		myLocation = returnSEMCoordManager().getCoordAsCoord("simcoord")

		//myLocation.setX(simcoord.getX())
		//myLocation.setY(simcoord.getY())
		//myLocation.setZ(simcoord.getZ())

		
		
		// check that the state we think SEM is in is indeed correct
		if (!self.checkStateConsistency())
		{
			self.print("state inconsistent, SEM stage is not where state machine thinks it is")
			throw("state inconsistent, SEM stage is not where state machine thinks it is")
		}



		self.print("init sem voltage: " +kV)
		self.print("init sem working distance: " +imagingWD)
		self.print("init sem stage. starting state: " +state)

		

	}


	void blankOn(object self)
	{
		//FEIQuanta_SetBeamBlankState(1)
		blankState = 1
		self.print("beam blanked")
	}

	void blankOff(object self)
	{
		//FEIQuanta_SetBeamBlankState(0)
		blankState = 0
		self.print("beam unblanked")
	}

	void HVOn(object self)
	{
		//FEIQuanta_SetHighTensionOnOff(1)
		HVState = 1
		self.print("HV on")
	}

	void HVOff(object self)
	{
		//FEIQuanta_SetHighTensionOnOff(0)
		HVState = 0
		self.print("HV off")
	}	

	~SEM_simulator(object self)
	{
		// save last known stage position to tag
		self.setManualState(state)

		// make sure these values are saved as numeric
		SEMkVPersistance.setNumber(kV)
		SEMWDPersistance.setNumber(imagingWD)
	}

	string getSEMState(object self)
	{
		// different name for mediator
		self.checkStateConsistency()
		return state
	}

	number uncoupleFWD(object self)
	{
		// set Z to use uncoupled coordinates
	}

	number coupleFWD(object self)
	{
		// set Z to use coupled coordinates
	}


	number checkFWDCoupling(object self, number active)
	{
		// check if FWD is coupled correctly
		// -active check moves stage down to lowest point and verifies that 
		// that number is within a threshold
		// -passive check just 

		number tol, z_limit, pos
		z_limit = GetTagValue("IPrep:limits:sem_z_limit")
		tol = GetTagValue("IPrep:limits:sem_z_tolerance")
		pos = self.getZ()
		
		return 1



	}


}



//object aSEM = alloc(SEM_IPrep)



