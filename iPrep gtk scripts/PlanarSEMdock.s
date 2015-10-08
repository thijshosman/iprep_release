// $BACKGROUND$
class planarSEMdock : object 
{
	string state // unclamped (for transfer etc) or clamped (imaging, moving) or inbetween
	number sampleStatus // 1 means sample present
	number address // 2 by default
	number timeout // time allowed to take to get to intended position
	string cmd,reply
	object SEMdockPersistance
	

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("DOCK", level, text)
	}

	void print(object self, string text)
	{
		// print to console output. also log as info
		result("SEMdock: "+text+"\n")
		self.log(2,text)
	}

	string sendCommand(object self, string command)
	{
		// *** private ***
		// send generic command and get reply

		cmd = command
		if (cmd == "")
			{
				throw("allmotion command string empty")
			}
		reply = ""
		Allmotion_SendCommand(address, cmd, reply)
		//result("\nALLMOTION DOCK: Reply to command \""+cmd+"\" is "+reply+"\n")
		return reply
	}

	number readSensor(object self)
	{
		// *** private ***
		// read sensor and get number back
		number sensorStateInt
		sensorStateInt = val(self.sendCommand("?4"))
		return sensorStateInt
	}

	string sensorToBitStr(object self)
	{
		// *** private ***
		// read the sensor and get bits back

		number sensorStateInt
		sensorStateInt = self.readSensor()
		string errStr = binary(sensorStateInt,4) // 4 is the length of the string
		return errStr
		//result("\n"+errStr)
	}


	void lookupState(object self, number view)
	{
		// *** private ***
		// check state from sensor input
		string bitStr
		bitStr = self.sensorToBitStr()

		number pogo 
		pogo = val(chr(bitStr[2]))

		if (pogo == 0)
			sampleStatus = 1
		else
			sampleStatus = 0

		number upsw 
		upsw = val(chr(bitStr[3]))

		number downsw
		downsw = val(chr(bitStr[1]))

		if (downsw == 0 && upsw == 1)
			state = "clamped"
		else if (downsw == 1 && upsw == 0)
			state = "unclamped"
		else 
			state = "inbetween"

		if (view == 1)
			self.print("current state is "+state+", individual sensors: up: "+upsw+", down: "+downsw+", pogo: "+pogo)
		
	}
	
	void init(object self)
	{
		// *** public ***
		// set string 2 in controller, executed after close
		self.sendCommand("s2TR")
		// set current (2x), speed (2x), holding current, acc

		// changed to m27, I27 instead of 16 in order to overcome some stickyness
		//self.sendCommand("m30h0I27L24V10000v2500R")
		
		// thijs update 10/02/2015 when testing ebsd dock
		self.sendCommand("m30h0l27L10000V5000R")
		self.print("dock initialized")
	}
	
	void PLANARsemDOCK(object self) 
	{
		// contructor
		SEMdockPersistance = alloc(statePersistance)
		SEMdockPersistance.init("SEMdock")
		address = 1 // 1 is gripper, 2 is dock on iprep. 
		timeout = 30
		self.lookupState(1)

	}


	void setManualState(object self,string newstate)
	{
		// *** private ***
		state = newstate
		self.print("state manually set. state is: "+state)
	}


	void unclamp_once(object self)
	{
		// *** public ***
		// moves dock up (unclamped position)

		self.print("going up, unclamping, current state is: "+state)	
		if (state == "clamped" || state == "inbetween")
		{
			SEMdockPersistance.setState("inbetween")
			// run until sensor gets triggered
			self.sendCommand("gD800S11e2G10000R")
			sleep(0.5)
			number i = 0
			while(state != "unclamped")
			{
				i++
				self.lookupState(0)
				sleep(0.1)
				if (i>10*timeout)
				{
					self.sendCommand("T")
					self.log(5,"dock does unclamp")
					throw("dock does unclamp")
					break
				}

			}
			self.sendCommand("T")
			self.lookupState(1)
			return
		}
	}

	void clamp_once(object self)
	{
		// *** public ***
		// moves dock down (clamped position)

		self.print("going down, clamping, current state is: "+state)	
		if (state == "unclamped" || state == "inbetween")
		{
			SEMdockPersistance.setState("inbetween")
			// run until sensor is triggered 
			self.sendCommand("gP800S13e2G10000R")
			sleep(0.5)
			number i = 0
			while(state != "clamped")
			{
				i++
				self.lookupState(0)
				sleep(0.1)
				if (i>10*timeout)
				{
					self.sendCommand("T")
					self.log(4,"dock does clamp")
					throw("dock does not clamp")
					break
				}
			}
			self.sendCommand("T")
			self.lookupState(1)
			return
		}
	}

	void Unclamp(object self)
	{
		try
			self.unclamp_once()
		catch
		{
			self.print("Dock failed to unclamp first time, will clamp and trying to unclamp one more time.\n")
			self.clamp_once()
			self.unclamp_once()
			break
		}
		SEMdockPersistance.setState("unclamped")
	}


	void Clamp(object self)
	{
		try
			self.clamp_once()
		catch
		{
			self.print("Dock failed to clamp first time, will unclamp and trying to clamp one more time.\n")
			self.unclamp_once()
			self.clamp_once()
			break
		}
		SEMdockPersistance.setState("clamped")
	}



	string getState(object self)
	{
		// *** public ***
		// returns current state

		self.lookupState(0)
		return state
	}

	number checkSamplePresent(object self)
	{
		// *** public ***
		// checks if sample is present

		self.lookupState(1)
		return sampleStatus

	}

	void calibrateCoords(object self)
	{
		// calibrate SEM points:
		// -set coords for "reference" and "scribe_pos" from "reference_ebsd" and "scripe_pos_ebsd"
		// -infers all the coordinates for SEM use from "reference" and "scribe_pos" for this particular dock
		//	and sets coord tags

		// first, set "reference" and "scribe_pos" to planar coord values
		object reference = returnSEMCoordManager().getCoordAsCoord("reference_planar")
		reference.setName("reference")
		returnSEMCoordManager.addCoord(reference)

		object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos_planar")
		reference.setName("scribe_pos")
		returnSEMCoordManager.addCoord(scribe_pos)

		// retrieve all coords we are going to set

		object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
		object clear = returnSEMCoordManager().getCoordAsCoord("clear")
		object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
		object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
		object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
		object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")
		object fwdGrid = returnSEMCoordManager().getCoordAsCoord("fwdGrid")
		object lowerGrid = returnSEMCoordManager().getCoordAsCoord("lowerGrid")





		//when the stage is at the calibrated pickup/dropoff position and calibrated there for transfer, 
		//calculate the other 3 positions (clear, nominal_imaging and StoredImaging 
		//and save them as absolute coordinates in private data)
		
		self.print("calibrateCoords: using calibrations from 20150903 ")

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

		// now update the coords in tags to their updated values
		returnSEMCoordManager.addCoord(pickup_dropoff)
		returnSEMCoordManager.addCoord(clear)
		returnSEMCoordManager.addCoord(nominal_imaging)
		returnSEMCoordManager.addCoord(StoredImaging)
		returnSEMCoordManager.addCoord(highGridFront)
		returnSEMCoordManager.addCoord(highGridBack)
		returnSEMCoordManager.addCoord(fwdGrid)
		returnSEMCoordManager.addCoord(lowerGrid)

		self.print("all coordinates calculated from scribe position")


	}



}



//object aplanarSEMdock = alloc(planarSEMdock)

//aplanarSEMdock.init()

//aplanarSEMdock.setManualState("up")

//aplanarSEMdock.goUp()
//result("sensor input: "+aplanarSEMdock.sensorToBitStr()+"\n")
//result("current state: "+aplanarSEMdock.getState()+"\n")
//sleep(5)
//aplanarSEMdock.goDown()
//result("current state: "+aplanarSEMdock.getState()+"\n")

//result("sample present: "+aplanarSEMdock.checkSamplePresent()+"\n")




