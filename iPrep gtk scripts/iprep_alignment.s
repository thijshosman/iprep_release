// $BACKGROUND$
// functions needed to align the docks and transfer system
// alignment in IPrep: 
// 3 types of values: 
// (1)-	store alignment calibration values for SEM (scribe_pos_ebsd, scribe_pos_planar, reference_ebsd, reference_planar) and parker (pickup_dropoff_ebsd, pickup_dropoff_planar) in (sem position and numeric) tags. 
// 		these do NOT change except when alignment changes. 
// (2)-	store vectors for SEM coordinates (ie where is highgridfront with respect to scribe_pos? where is clear with respect to reference?) in (sem position)tags. 
//		these get applied when calibratecoords. there is a different set of vectors for EBSD as for Planar. these vector sets both have default values based on the mechanical layout of the dock, 
//		but need to be adjusted upon install/alignment (and some axes may need to be swapped). 
// (3)-	store cal values used by workflow routines in tags. the workflow uses these and does not know of ebsd/planar. these tags do not get changed except by IPrep calibration routines. 

// calibrateCoords(EBSD/planar): calibrate sem positions for use in (EBSD/planar) dock (using alignment values and vectors). also set SEM transfer coordinate based on dock. 
//		 sets (3) by using (1) as 'references' and applying (2)

// restoreDefaultVectors(Planar/EBSD): sets (2) to default (hardcoded) values based on dock
// restoreDefaultAlignment(Planar/EBSD): sets (1) to default (hardcoded) values based on dock

/*

class alignment: object
{
	// initial alignment
	// manages iprep alignment. that includes:
	// reinsertion dock (minor adjustments)
	// swapping dock from EBSD to planar and vice versa

	// setSystemMode(mode) // sets mode
	// getSystemMode() // gets mode 

	// overview of calibration coordinates: 
	// EBSD
	// reference_ebsd: calibrated pickup_dropoff position at which gripper arms will close.
	// scribe_pos_ebsd
	// Planar
	// reference_planar
	// scribe_pos_planar

	// overview of workflow coordinates: 
	// clear: safe position of dock where arms can open and close. inferred from reference_ebsd or reference_planar (by moving stage down)
	// pickup_dropoff: inferred from reference_ebsd or reference_planar (ie the same)
	// scribe_pos: inferred from scribe_pos_ebsd or scribe_pos_planar (ie the same)
	// nominal_imaging: inferred from scribe_pos_ebsd or scribe_pos_planar
	// StoredImaging: inferred from scribe_pos_ebsd or scribe_pos_planar
	// highGridFront: inferred from scribe_pos_ebsd or scribe_pos_planar
	// highGridBack: inferred from scribe_pos_ebsd or scribe_pos_planar

	// mode vectors for EBSD mode
	// mode_vector_EBSD_scribe_pos
	// mode_vector_EBSD_pickup_dropoff 
	// mode_vector_EBSD_clear
	// mode_vector_EBSD_nominal_imaging
	// mode_vector_EBSD_highGridFront
	// mode_vector_EBSD_highGridBack

	// mode vectors for Planar mode
	// mode_vector_Planar_scribe_pos
	// mode_vector_Planar_pickup_dropoff 
	// mode_vector_Planar_clear
	// mode_vector_Planar_nominal_imaging
	// mode_vector_Planar_highGridFront
	// mode_vector_Planar_highGridBack


	// *** helper functions

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("ALIGNMENT", level, text)
	}

	void print(object self, string text)
	{
		// *** public ***
		result("Alignment: "+text+"\n")
		self.log(2,text)
	}

	object adjustCoordByVector(object self, string coordname, string vectorname, string newname)
	{
		// *** private ***
		// retrieve a coord called coordname and update its position with the name of second coord (vector)
		// set the new coord name as newname and return it
		self.print("adjusting "+coordname+" with "+vectorname+". new coordname = "+newname)
		object aVector = returnSEMCoordManager().getCoordAsCoord(vectorname)
		object aCoord = returnSEMCoordManager().getCoordAsCoord(coordname)
		aCoord.adjust_plus(aVector)
		aCoord.setName(newname)
		return aCoord
	}

	// *** manual alignment
	
	void init_parker_defaults(object self)
	{
		// populate the parker positions with default values for EBSD and Planar dock
		// get the object that manages the parker positions
		object tr = returnWorkflow().returnTransfer().returnParkerPositions()

		// generic positions
		tr.savePosition("outofway",0) // home position, without going through homing sequence
		tr.savePosition("prehome",5) // location where we can move to close to home from where we home
		tr.savePosition("open_pecs",23.5) // location where arms can open in PECS  // #20150819: was 29, #20150903: was 28
		tr.savePosition("pickup_pecs",42) // location where open arms can be used to pickup sample // #20150827: was 48.5, #20150903: was 49.5
		tr.savePosition("beforeGV",100) // location where open arms can be used to pickup sample
		tr.savePosition("dropoff_pecs",40) // location where sample gets dropped off in PECS // #20150827: was 45.5
		tr.savePosition("dropoff_pecs_backoff",41) // location where sample gets dropped off in PECS // #20150827: was 46.5
		tr.savePosition("backoff_sem_ebsd",420) // location where gripper arms can safely open/close in SEM chamber
		tr.savePosition("dropoff_sem_planar",470.25) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
		tr.savePosition("pickup_sem_ebsd",470.25) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
		tr.savePosition("backoff_sem_planar",420) // location where gripper arms can safely open/close in SEM chamber
		tr.savePosition("dropoff_sem_ebsd",470.25) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
		tr.savePosition("pickup_sem_planar",470.25) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
		tr.savePosition("backoff_sem",420) // location where gripper arms can safely open/close in SEM chamber
		tr.savePosition("dropoff_sem",470.25) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
		tr.savePosition("pickup_sem",470.25) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
	}

	void init_mode_vectors(object self)
	{
		// populate mode vectors with default values. only intended to be used once. 

		// mode vectors for EBSD mode
		object mode_vector_EBSD_scribe_pos = SEMCoordFactor("mode_vector_EBSD_scribe_pos")
		object mode_vector_EBSD_pickup_dropoff = SEMCoordFactor("mode_vector_EBSD_pickup_dropoff")
		object mode_vector_EBSD_clear = SEMCoordFactor("mode_vector_EBSD_clear")
		object mode_vector_EBSD_nominal_imaging = SEMCoordFactor("mode_vector_EBSD_nominal_imaging")
		object mode_vector_EBSD_highGridFront = SEMCoordFactor("mode_vector_EBSD_highGridFront")
		object mode_vector_EBSD_highGridBack = SEMCoordFactor("mode_vector_EBSD_highGridBack")

		// mode vectors for Planar mode
		object mode_vector_Planar_scribe_pos = SEMCoordFactor("mode_vector_Planar_scribe_pos")
		object mode_vector_Planar_pickup_dropoff = SEMCoordFactor("mode_vector_Planar_pickup_dropoff")
		object mode_vector_Planar_clear = SEMCoordFactor("mode_vector_Planar_clear")
		object mode_vector_Planar_nominal_imaging = SEMCoordFactor("mode_vector_Planar_nominal_imaging")
		object mode_vector_Planar_highGridFront = SEMCoordFactor("mode_vector_Planar_highGridFront")
		object mode_vector_Planar_highGridBack = SEMCoordFactor("mode_vector_Planar_highGridBack")

		// upload all these coords
		returnSEMCoordManager().addCoord(mode_vector_EBSD_scribe_pos)
		returnSEMCoordManager().addCoord(mode_vector_EBSD_pickup_dropoff)
		returnSEMCoordManager().addCoord(mode_vector_EBSD_clear)
		returnSEMCoordManager().addCoord(mode_vector_EBSD_nominal_imaging)
		returnSEMCoordManager().addCoord(mode_vector_EBSD_highGridFront)
		returnSEMCoordManager().addCoord(mode_vector_EBSD_highGridBack)
		returnSEMCoordManager().addCoord(mode_vector_Planar_scribe_pos)
		returnSEMCoordManager().addCoord(mode_vector_Planar_pickup_dropoff)
		returnSEMCoordManager().addCoord(mode_vector_Planar_clear)
		returnSEMCoordManager().addCoord(mode_vector_Planar_nominal_imaging)
		returnSEMCoordManager().addCoord(mode_vector_Planar_highGridFront)
		returnSEMCoordManager().addCoord(mode_vector_Planar_highGridBack)
	}

	void calibrate_point(object self, string name)
	{
		// calibrate the calibration coordinates and workflow coordinates
		// intention is to first use these for reference and scribe marks upon initial dock calibration
		// after that, workflow coordinates can be found
		// only for initializiation
		// ie, call this one with "highGridFront" when stage is at highGridFront to store it
		
		// create a coord of the current SEM position
		object a = SEMCoordFactory(name,returnWorkflow().returnSEM().getX(),returnWorkflow().returnSEM().getY(),returnWorkflow().returnSEM().getZ())
		
		// now add it or overwrite it
		returnSEMCoordManager().addCoord(a)

		self.print("coordinate just calibrated: ")
		a.print()
	}

	void infer_vectors_from_coords()
	{
		// figures out all vectors after dock is installed
		// use this when, after initial dock install, all coordinates on the dock are calibrated. 
	




	}


	// *** methods to be used for calibration after dock swaps

	void set_transfer_to_EBSD(object self)
	{
		// *** private ***
		// set parker workflow positions to EBSD mode positions

		self.print("calibrating for EBSD mode")

		// adjust parker coordinates

		// get the object that manages the parker positions
		object tr = returnWorkflow().returnTransfer().returnParkerPositions()

		// get the 3 positions we will use		
		number pos1 = tr.getPosition("backoff_sem_ebsd")
		number pos2 = tr.getPosition("dropoff_sem_ebsd")
		number pos3 = tr.getPosition("pickup_sem_ebsd")

		// set them
		tr.savePosition("backoff_sem",pos1) // location where gripper arms can safely open/close in SEM chamber
		tr.savePosition("dropoff_sem",pos2) // location where sample gets dropped off (arms will open)  
		tr.savePosition("pickup_sem",pos3) // location in where sample gets picked up  

		self.print("set parker backoff to "+pos1)
		self.print("set parker dropoff_sem to "+pos2)
		self.print("set parker pickup_sem to "+pos3)
	}

	void set_transfer_to_Planar(object self)
	{
		// *** private ***
		// set parker workflow positions to Planar mode positions

		self.print("calibrating for Planar mode")

		// adjust parker coordinates

		// get the object that manages the parker positions
		object tr = returnWorkflow().returnTransfer().returnParkerPositions()

		// get the 3 positions we will use		
		number pos1 = tr.getPosition("backoff_sem_planar")
		number pos2 = tr.getPosition("dropoff_sem_planar")
		number pos3 = tr.getPosition("pickup_sem_planar")

		// set them
		tr.savePosition("backoff_sem",pos1) // location where gripper arms can safely open/close in SEM chamber
		tr.savePosition("dropoff_sem",pos2) // location where sample gets dropped off (arms will open)  
		tr.savePosition("pickup_sem",pos3) // location in where sample gets picked up  

		self.print("set parker backoff to "+pos1)
		self.print("set parker dropoff_sem to "+pos2)
		self.print("set parker pickup_sem to "+pos3)
	}

	void apply_mode_vectors_Planar(object self)
	{
		// *** public ***
		// adjust vectors such that the coords the workflow uses are in Planar mode
		// apply mode_vectors for Planar dock to calibration_coords (1). overwrites all workflow coordinates (3) and parker coordinates.
		// assumes you are sure of the curent mode and that any verification has already happened

		// now adjust SEM coordinates

		object scribe_pos = self.adjustCoordByVector("scribe_pos_planar","mode_vector_Planar_scribe_pos","scribe_pos")
		returnSEMCoordManager().addCoord(scribe_pos)

		object pickup_dropoff = self.adjustCoordByVector("reference_planar","mode_vector_Planar_pickup_dropoff","pickup_dropoff")
		returnSEMCoordManager().addCoord(pickup_dropoff)

		object clear  = self.adjustCoordByVector("reference_planar","mode_vector_Planar_clear","clear")
		returnSEMCoordManager().addCoord(clear)

		object nominal_imaging  = self.adjustCoordByVector("scribe_pos_planar","mode_vector_Planar_nominal_imaging","nominal_imaging")
		returnSEMCoordManager().addCoord(nominal_imaging)

		// #todo: update StoredImaging with nominal_imaging

		object highGridFront  = self.adjustCoordByVector("scribe_pos_planar","mode_vector_Planar_highGridFront","highGridFront")
		returnSEMCoordManager().addCoord(highGridFront)

		object highGridBack  = self.adjustCoordByVector("scribe_pos_planar","mode_vector_Planar_highGridBack","highGridBack")
		returnSEMCoordManager().addCoord(highGridBack)



		//object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos")
		//object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
		//object clear = returnSEMCoordManager().getCoordAsCoord("clear")
		//object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
		//object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
		//object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
		//object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")
	}

	void apply_mode_vectors_EBSD(object self)
	{
		// *** public ***
		// adjust vectors such that the coords the workflow uses are in EBSD mode
		// apply mode_vectors for EBSD dock to calibration_coords (1). overwrites all workflow coordinates (3) and parker coordinates.
		// assumes you are sure of the curent mode and that any verification has already happened

		// now adjust SEM coordinates

		object scribe_pos = self.adjustCoordByVector("scribe_pos_ebsd","mode_vector_EBSD_scribe_pos","scribe_pos")
		returnSEMCoordManager().addCoord(scribe_pos)

		object pickup_dropoff = self.adjustCoordByVector("reference_ebsd","mode_vector_EBSD_pickup_dropoff","pickup_dropoff")
		returnSEMCoordManager().addCoord(pickup_dropoff)

		object clear  = self.adjustCoordByVector("reference_ebsd","mode_vector_EBSD_clear","clear")
		returnSEMCoordManager().addCoord(clear)

		object nominal_imaging  = self.adjustCoordByVector("scribe_pos_ebsd","mode_vector_EBSD_nominal_imaging","nominal_imaging")
		returnSEMCoordManager().addCoord(nominal_imaging)

		// #todo: update StoredImaging with nominal_imaging

		object highGridFront  = self.adjustCoordByVector("scribe_pos_ebsd","mode_vector_EBSD_highGridFront","highGridFront")
		returnSEMCoordManager().addCoord(highGridFront)

		object highGridBack  = self.adjustCoordByVector("scribe_pos_ebsd","mode_vector_EBSD_highGridBack","highGridBack")
		returnSEMCoordManager().addCoord(highGridBack)
	}

	number apply_reinsertion_vector(object self, x_corr, y_corr)
	{
		// apply an x,y vector to all points. x,y are in mm

		if (abs(x_corr) > 2 || abs(y_corr) > 2)
		{
			self.print("correction vector too large: ("+x_corr+","+y_corr+")")
			return 0
		}
		else
		{
			self.print("applying correction vector ("+x_corr+","+y_corr+") to workflow coordinates")
		}

		object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos")
		object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
		object clear = returnSEMCoordManager().getCoordAsCoord("clear")
		object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
		object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
		object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
		object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")
	
		// do corrections on these points

		scribe_pos.corrX(x_corr)
		scribe_pos.corrY(y_corr)
		print("new corrected scribe_pos: ")
		scribe_pos.print()

		pickup_dropoff.corrX(x_corr)
		pickup_dropoff.corrY(y_corr)
		print("new corrected pickup_dropoff: ")
		pickup_dropoff.print()

		clear.corrX(x_corr)
		clear.corrY(y_corr)
		print("new corrected clear: ")
		clear.print()

		nominal_imaging.corrX(x_corr)
		nominal_imaging.corrY(y_corr)
		print("new corrected nominal_imaging: ")
		nominal_imaging.print()

		StoredImaging.corrX(x_corr)
		StoredImaging.corrY(y_corr)
		print("new corrected StoredImaging: ")
		StoredImaging.print()

		highGridFront.corrX(x_corr)
		highGridFront.corrY(y_corr)
		print("new corrected highGridFront: ")
		highGridFront.print()

		highGridBack.corrX(x_corr)
		highGridBack.corrY(y_corr)	
		print("new corrected highGridBack: ")
		highGridBack.print()

		// save the points with corrections added
		returnSEMCoordManager().addCoord(pickup_dropoff)
		returnSEMCoordManager().addCoord(clear)
		returnSEMCoordManager().addCoord(nominal_imaging)
		returnSEMCoordManager().addCoord(StoredImaging)
		returnSEMCoordManager().addCoord(highGridFront)
		returnSEMCoordManager().addCoord(highGridBack)
		returnSEMCoordManager().addCoord(scribe_pos)

		self.print("done applying reinsertion vector to workflow coordinates")

		return 1
	}

	// high level functions

	void change_to_ebsd(object self)
	{
		// *** public ***
		// intended to be used to swap mode from planar to ebsd

		// first, change the transfer system coords
		self.set_transfer_to_EBSD()

		// now, we apply the vectors to the calibration coordinates
		self.apply_mode_vectors_EBSD()

		// done, system in EBSD mode
		setSystemMode("ebsd")

		// since we switched mode, we are uncalibrated
		setDockCalibrationStatus(0)
	
	}

	void change_to_planar(object self)
	{
		// *** public ***
		// intended to be used to swap mode from ebsd to planar

		// first, change the transfer system coords
		self.set_transfer_to_Planar()

		// now, we apply the vectors to the calibration coordinates
		self.apply_mode_vectors_Planar()

		// done, system in Planar mode
		setSystemMode("planar")

		// since we switched mode, we are uncalibrated
		setDockCalibrationStatus(0)
	
	}





	number reinsert_dock(object self)
	{
		// call when dock reinserted
		// does the following things: 

		// measure mode of current
		string detectedMode =  returnMediator().detectMode()

		if (detectedMode == getSystemMode())
		{
			// system is configured to use currently installed dock
			// just apply reinsertion vectors
			if (getSystemMode() == "ebsd")
			{

			}
			else if (getSystemMode() == "planar")
			{

			}
		}


		// check if mode matches current_calibration_mode tag matches this mode
		// if it matches, continue
		// if not, change mode by applying correct vectors for this mode
		// go to scribe mark 
		// determine reinsertion vector
		// apply this vector to these modes workflow coords
		// verify scribe marks/grids
	}

	number 


}

*/



void restoreDefaultAlignmentPlanar()
{
// restore reference and scribe_pos for planar dock

}

void restoreDefaultAlignmentEBSD()
{
// restore reference and scribe_pos for ebsd dock

}

void restoreDefaultVectorsPlanar()
{



}

void restoreDefaultVectorsEBSD()
{



}


void setTransferPositionsPlanar()
{
	// save default positions in global tags
	print("setDefaultPositions: setting default positions for use with Planar dock ")
	// #todo: get this from global tag instead of hardcoded value
	// #TODO: intended to be replaced by the alignment class framework
	object tr = returnWorkflow().returnTransfer().returnParkerPositions()

	tr.savePosition("backoff_sem",430) // location where gripper arms can safely open/close in SEM chamber
	tr.savePosition("dropoff_sem",543) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
	tr.savePosition("pickup_sem",543) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
	tr.savePosition("dropoff_pecs",44.5) // location where sample gets dropped off in PECS
}

void setTransferPositionsEBSD()
{
	// save default positions in global tags
	print("setDefaultPositions: setting positions for use with EBSD dock ")
	// #todo: get this from global tag instead of hardcoded value
	// #TODO: intended to be replaced by the alignment class framework
	object tr = returnWorkflow().returnTransfer().returnParkerPositions()

	tr.savePosition("backoff_sem",430) // location where gripper arms can safely open/close in SEM chamber
	tr.savePosition("dropoff_sem",508) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
	tr.savePosition("pickup_sem",509) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
	tr.savePosition("dropoff_pecs",45.5) // location where sample gets dropped off in PECS
}

void setDefaultPositionsDovetail()
{
	// saves calibrated positions, both generic ones (ie dovetail and home) for both docks and dock specific ones
	// #TODO: these should come from tags themselves, not these harcoded values
	// #TODO: intended to be replaced by the alignment class framework
	print("setting generic positions (dovetail, home etc.)")

	object tr = returnWorkflow().returnTransfer().returnParkerPositions()

	// generic positions
	tr.savePosition("outofway",0) // home position, without going through homing sequence
	tr.savePosition("prehome",15) // location where we can move to close to home from where we home
	tr.savePosition("open_pecs",27) // location where arms can open in PECS  // #20150819: was 29, #20150903: was 28
	tr.savePosition("pickup_pecs",48) // location where open arms can be used to pickup sample // #20150827: was 48.5, #20150903: was 49.5
	tr.savePosition("beforeGV",100) // location where open arms can be used to pickup sample
	tr.savePosition("dropoff_pecs",45.5) // location where sample gets dropped off in PECS // #20150827: was 45.5
	tr.savePosition("dropoff_pecs_backoff",46.5) // location where sample gets dropped off in PECS // #20150827: was 46.5



}	

number calibrateCoordsEBSD()
{
	// #TODO: intended to be replaced by the alignment class framework
	// calibrate SEM points:
	// -set coords for "reference" and "scribe_pos" from "reference_ebsd" and "scripe_pos_ebsd"
	// -infers all the coordinates for SEM use from "reference" and "scribe_pos" for this particular dock
	//	and sets coord tags

	// first, set "reference" and "scribe_pos" to planar coord values
	object reference = returnSEMCoordManager().getCoordAsCoord("reference_ebsd")
	reference.setName("reference")
	returnSEMCoordManager().addCoord(reference)

	object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos_ebsd")
	scribe_pos.setName("scribe_pos")
	returnSEMCoordManager().addCoord(scribe_pos)

	// retrieve all coords we are going to set

	object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
	object clear = returnSEMCoordManager().getCoordAsCoord("clear")
	object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
	object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
	object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
	object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")
	//object fwdGrid = returnSEMCoordManager().getCoordAsCoord("fwdGrid")
	//object lowerGrid = returnSEMCoordManager().getCoordAsCoord("lowerGrid")





	//when the stage is at the calibrated pickup/dropoff position and calibrated there for transfer, 
	//calculate the other 3 positions (clear, nominal_imaging and StoredImaging 
	//and save them as absolute coordinates in private data)
	
	print("calibrateCoords: using calibrations from 20151201 (manchester nova ebsd dock) ")

	// reference point is the point from which other coordinates are inferred
	// the reference pointf or all coordinates is the pickup/dropoff point now
	// TODO: change from hardcoded value to setting in global tags
	
	print("scribe position set: ")
	scribe_pos.print()

	print("reference set: ")
	reference.print()

	// pickup_dropoff is reference point, so simply set them there
	pickup_dropoff.set(reference.getX(), reference.getY(), reference.getZ())
	print("pickup_dropoff set: ")
	pickup_dropoff.print()

	// for clear only move in Z from reference point
	clear.set(reference.getX(), reference.getY(), reference.getZ()-6.25)
	print("clear set: ")
	clear.print()

	// nominal imaging is approximate middle of sample #todo
	//nominal_imaging.set( scribe_pos.getX()-17.5526, scribe_pos.getY()-2.6368, scribe_pos.getZ(), 0 )
	// set by thijs after alignment, absolute for now 20151201
	nominal_imaging.set( -38.3352, -0.2050, 5.5, 0 )
	print("nominal_imaging set: ")
	nominal_imaging.print()

	// stored imaging starts at the same point as the nominal imaging point
	StoredImaging.set( nominal_imaging.getX(), nominal_imaging.getY(), nominal_imaging.getZ(), nominal_imaging.getdf() )
	print("StoredImaging set: ")
	StoredImaging.print()

	// grid on post at back position (serves as sanity check) #todo
	//highGridBack.set( scribe_pos.getX()-2.409, scribe_pos.getY()-0.2779, scribe_pos.getZ(), 0 )
	// set by thijs after alignment, absolute for now 20151201
	highGridBack.set( -23.5316, 1.1661, 5.5, 0 )
	print("highGridBack set: ")
	highGridBack.print()

	// grid on post in front position (serves as sanity check) #todo
	//highGridFront.set( scribe_pos.getX()-32.4044, scribe_pos.getY()+0.042, scribe_pos.getZ(), 0 )
	// set by thijs after alignment, absolute for now 20151201
	highGridFront.set( -53.5331, 1.1319, 5.5, 0 )
	print("highGridFront set: ")
	highGridFront.print()

	// grid on post for FWD Z-height calibration
	//fwdGrid.set( scribe_pos.getX()+22.761, scribe_pos.getY()+(-3.593), scribe_pos.getZ(), 22.19 )
	//print("fwdGrid set: ")
	//fwdGrid.print()

	// grid on base plate, formerly used for FWD Z-height cal, now not used // Save to remove all references to lowerGrid
	//lowerGrid.set(scribe_pos.getX()+4.747, scribe_pos.getY()+17.652, scribe_pos.getZ()-0.5+16.987, 44.29)
	//print("lowerGrid set: ")
	//lowerGrid.print()


	// now update the coords in tags to their updated values
	returnSEMCoordManager().addCoord(pickup_dropoff)
	returnSEMCoordManager().addCoord(clear)
	returnSEMCoordManager().addCoord(nominal_imaging)
	returnSEMCoordManager().addCoord(StoredImaging)
	returnSEMCoordManager().addCoord(highGridFront)
	returnSEMCoordManager().addCoord(highGridBack)
	//returnSEMCoordManager().addCoord(fwdGrid)
	//returnSEMCoordManager().addCoord(lowerGrid)

	print("all coordinates calculated from (nominal) scribe position")


}


void calibrateCoordsPlanar()
{
	// #TODO: intended to be replaced by the alignment class framework
	// calibrate SEM points:
	// -set coords for "reference" and "scribe_pos" from "reference_ebsd" and "scripe_pos_ebsd"
	// -infers all the coordinates for SEM use from "reference" and "scribe_pos" for this particular dock
	//	and sets coord tags

	// first, set "reference" and "scribe_pos" to planar coord values
	object reference = returnSEMCoordManager().getCoordAsCoord("reference_planar")
	reference.setName("reference")
	returnSEMCoordManager().addCoord(reference)

	object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos_planar")
	scribe_pos.setName("scribe_pos")
	returnSEMCoordManager().addCoord(scribe_pos)

	// retrieve all coords we are going to set

	object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
	object clear = returnSEMCoordManager().getCoordAsCoord("clear")
	object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
	object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
	object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
	object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")
	//object fwdGrid = returnSEMCoordManager().getCoordAsCoord("fwdGrid")
	//object lowerGrid = returnSEMCoordManager().getCoordAsCoord("lowerGrid")


	
	print("calibrateCoords: using calibrations from 20151024 (manchester nova planar dock) ")

	// reference point is the point from which other coordinates are inferred
	// the reference point for all coordinates is the pickup/dropoff point now

	print("scribe position set: ")
	scribe_pos.print()

	print("reference set: ")
	reference.print()

	// pickup_dropoff is reference point, so simply set them there
	pickup_dropoff.set(reference.getX(), reference.getY(), reference.getZ())
	print("pickup_dropoff set: ")
	pickup_dropoff.print()

	// for clear only move in Z from reference point
	clear.set(reference.getX(), reference.getY(), reference.getZ()-3)
	print("clear set: ")
	clear.print()

	// nominal imaging is approximate middle of sample
	nominal_imaging.set( scribe_pos.getX()-22.8104, scribe_pos.getY()-38.6801, scribe_pos.getZ(), 0 )
	print("nominal_imaging set: ")
	nominal_imaging.print()

	// stored imaging starts at the same point as the nominal imaging point
	StoredImaging.set( nominal_imaging.getX(), nominal_imaging.getY(), nominal_imaging.getZ(), nominal_imaging.getdf() )
	print("StoredImaging set: ")
	StoredImaging.print()

	// grid on post at back position (serves as sanity check)
	highGridBack.set( scribe_pos.getX()-5.0715, scribe_pos.getY()+3.6686, scribe_pos.getZ(),0)
	print("highGridBack set: ")
	highGridBack.print()

	// grid on post in front position (serves as sanity check)
	highGridFront.set( scribe_pos.getX()-40.1685, scribe_pos.getY()+3.3073, scribe_pos.getZ(), 0 )
	print("highGridFront set: ")
	highGridFront.print()

	// grid on post for FWD Z-height calibration, not used
	//fwdGrid.set( scribe_pos.getX()+22.761, scribe_pos.getY()+(-3.593), scribe_pos.getZ()-30+30, 22.19 )
	//print("fwdGrid set: ")
	//fwdGrid.print()

	// grid on base plate, formerly used for FWD Z-height cal, now not used // Save to remove all references to lowerGrid
	//lowerGrid.set(scribe_pos.getX()+4.747, scribe_pos.getY()+17.652, scribe_pos.getZ()-0.5+16.987, 44.29)
	//print("lowerGrid set: ")
	//lowerGrid.print()


	// now update the coords in tags to their updated values
	returnSEMCoordManager().addCoord(pickup_dropoff)
	returnSEMCoordManager().addCoord(clear)
	returnSEMCoordManager().addCoord(nominal_imaging)
	returnSEMCoordManager().addCoord(StoredImaging)
	returnSEMCoordManager().addCoord(highGridFront)
	returnSEMCoordManager().addCoord(highGridBack)
	//returnSEMCoordManager().addCoord(fwdGrid)
	//returnSEMCoordManager().addCoord(lowerGrid)

	print("all coordinates calculated from (nominal) scribe position")


}

void calibrateForMode()
{
	// #TODO: intended to be replaced by the alignment class framework
	// calibrate SEMdock and parker for this particular mode (as defined by mode tag)

	print("calibrating sem postions and parker positions for mode")

	string mode = getSystemMode()
	print("mode = "+mode)
	
	if (mode == "ebsd")
	{
		calibrateCoordsEBSD() // SEM coords
		setTransferPositionsEBSD() // transfer coords
	}
	else if (mode == "planar")
	{
		calibrateCoordsPlanar() // SEM coords
		setTransferPositionsPlanar() // transfer coords
	}
	else
	{
		print("mode not set")
	}



	//number sim_dock_simulate =  GetTagValue("IPrep:simulation:dock")
	
	// init SEM Dock hardware (since planar and ebsd have different drive parameters)
	returnWorkflow().returnSEMdock().init()



}




number IPrep_scribemarkVectorCorrection(number x_corr, number y_corr)
{

	// adjust nominal_imaging, stored_imaging, highGridFront, highGridBack, pickup_dropoff and clear by vector
	// called by UI on reinsertion of dock


	object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos")
	object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
	object clear = returnSEMCoordManager().getCoordAsCoord("clear")
	object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
	object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
	object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
	object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")

	
	// do corrections on these points

	scribe_pos.corrX(x_corr)
	scribe_pos.corrY(y_corr)
	print("new corrected scribe_pos: ")
	scribe_pos.print()

	pickup_dropoff.corrX(x_corr)
	pickup_dropoff.corrY(y_corr)
	print("new corrected pickup_dropoff: ")
	pickup_dropoff.print()

	clear.corrX(x_corr)
	clear.corrY(y_corr)
	print("new corrected clear: ")
	clear.print()

	nominal_imaging.corrX(x_corr)
	nominal_imaging.corrY(y_corr)
	print("new corrected nominal_imaging: ")
	nominal_imaging.print()

	StoredImaging.corrX(x_corr)
	StoredImaging.corrY(y_corr)
	print("new corrected StoredImaging: ")
	StoredImaging.print()

	highGridFront.corrX(x_corr)
	highGridFront.corrY(y_corr)
	print("new corrected highGridFront: ")
	highGridFront.print()

	highGridBack.corrX(x_corr)
	highGridBack.corrY(y_corr)	
	print("new corrected highGridBack: ")
	highGridBack.print()

	// save the points with corrections added
	returnSEMCoordManager().addCoord(pickup_dropoff)
	returnSEMCoordManager().addCoord(clear)
	returnSEMCoordManager().addCoord(nominal_imaging)
	returnSEMCoordManager().addCoord(StoredImaging)
	returnSEMCoordManager().addCoord(highGridFront)
	returnSEMCoordManager().addCoord(highGridBack)
	returnSEMCoordManager().addCoord(scribe_pos)

	return 1
}



number IPrep_align_planar_hack()
{
	// #TODO: intended to be replaced by the alignment class framework
	// hardcoded values as planar coordinates for Quanta demounit

	// calibrate SEM points:
		// -set coords for "reference" and "scribe_pos" from "reference_ebsd" and "scripe_pos_ebsd"
		// -infers all the coordinates for SEM use from "reference" and "scribe_pos" for this particular dock
		//	and sets coord tags

		// first, set "reference" and "scribe_pos" to planar coord values
		object reference = returnSEMCoordManager().getCoordAsCoord("reference_planar")
		reference.setName("reference")
		returnSEMCoordManager().addCoord(reference)

		object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos_planar")
		scribe_pos.setName("scribe_pos")
		returnSEMCoordManager().addCoord(scribe_pos)

		// retrieve all coords we are going to set

		object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
		object clear = returnSEMCoordManager().getCoordAsCoord("clear")
		object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
		object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
		object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
		object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")
		object lowerGrid = returnSEMCoordManager().getCoordAsCoord("lowerGrid")


		
		print("calibration used is manual Quanta cal with planar dock 2016-06-27")

		// reference point is the point from which other coordinates are inferred
		// the reference point for all coordinates is the pickup/dropoff point now

		print("scribe position set: ")
		scribe_pos.print()

		print("reference set: ")
		reference.print()

		// pickup_dropoff is reference point, so simply set them there
		pickup_dropoff.set(reference.getX(), reference.getY(), reference.getZ())
		print("pickup_dropoff set: ")
		pickup_dropoff.print()

		// for clear only move in Z from reference point
		clear.set(reference.getX(), reference.getY(), reference.getZ()+3.5)
		print("clear set: ")
		clear.print()

		// nominal imaging is approximate middle of sample
		nominal_imaging.set( scribe_pos.getX()-22.8104, scribe_pos.getY()-38.6801, scribe_pos.getZ(), 0 )
		print("nominal_imaging set: ")
		nominal_imaging.print()

		// stored imaging starts at the same point as the nominal imaging point
		StoredImaging.set( nominal_imaging.getX(), nominal_imaging.getY(), nominal_imaging.getZ(), nominal_imaging.getdf() )
		print("StoredImaging set: ")
		StoredImaging.print()

		// grid on post at back position (serves as sanity check)
		highGridBack.set( 25.215, 14.161, 48, 0)
		print("highGridBack set: ")
		highGridBack.print()

		// grid on post in front position (serves as sanity check)
		highGridFront.set( -8.271, 14.533, 48, 0 )
		print("highGridFront set: ")
		highGridFront.print()



		// grid on base plate, formerly used for FWD Z-height cal, now not used // Save to remove all references to lowerGrid
		lowerGrid.set(31.887, 27.507, 48, 0)
		print("lowerGrid set: ")
		lowerGrid.print()

	
		// now update the coords in tags to their updated values
		returnSEMCoordManager().addCoord(pickup_dropoff)
		returnSEMCoordManager().addCoord(clear)
		returnSEMCoordManager().addCoord(nominal_imaging)
		returnSEMCoordManager().addCoord(StoredImaging)
		returnSEMCoordManager().addCoord(highGridFront)
		returnSEMCoordManager().addCoord(highGridBack)
		returnSEMCoordManager().addCoord(lowerGrid)
}








	