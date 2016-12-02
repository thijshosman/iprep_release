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

void restoreDefaultAlignmentPlanar()
{
// restore reference and scribe pos 

}

void restoreDefaultAlignmentEBSD()
{

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
	self.print("setDefaultPositions: setting default positions for use with Planar dock ")
	// #todo: get this from global tag instead of hardcoded value

	myTransfer.setPositionTag("backoff_sem",420) // location where gripper arms can safely open/close in SEM chamber
	myTransfer.setPositionTag("dropoff_sem",470.25) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
	myTransfer.setPositionTag("pickup_sem",470.25) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
	
}

void setTransferPositionsEBSD()
{
	// save default positions in global tags
	self.print("setDefaultPositions: setting positions for use with EBSD dock ")
	// #todo: get this from global tag instead of hardcoded value

	myTransfer.setPositionTag("backoff_sem",420) // location where gripper arms can safely open/close in SEM chamber
	myTransfer.setPositionTag("dropoff_sem",513) // location where sample gets dropped off (arms will open)  // #20150819: was 485.75  // #20150827: was 486.75, #20150903: was 487.75
	myTransfer.setPositionTag("pickup_sem",513) // location in where sample gets picked up  // #20150819: was 485.75  // #20150827: was 486.75
}

void setDefaultPositionsDovetail()
{
	// saves calibrated positions, both generic ones (ie dovetail and home) for both docks and dock specific ones
	// #TODO: these should come from tags themselves, not these harcoded values
	self.print("setting generic positions (dovetail, home etc.)")

	// generic positions
	myTransfer.setPositionTag("outofway",0) // home position, without going through homing sequence
	myTransfer.setPositionTag("prehome",5) // location where we can move to close to home from where we home
	myTransfer.setPositionTag("open_pecs",23.5) // location where arms can open in PECS  // #20150819: was 29, #20150903: was 28
	myTransfer.setPositionTag("pickup_pecs",42) // location where open arms can be used to pickup sample // #20150827: was 48.5, #20150903: was 49.5
	myTransfer.setPositionTag("beforeGV",100) // location where open arms can be used to pickup sample
	myTransfer.setPositionTag("dropoff_pecs",40) // location where sample gets dropped off in PECS // #20150827: was 45.5
	myTransfer.setPositionTag("dropoff_pecs_backoff",41) // location where sample gets dropped off in PECS // #20150827: was 46.5



}	

void calibrateForMode()
{
	// calibrate SEMdock and parker for this particular mode (as defined by mode tag)

	self.print("calibrating sem postions and parker positions for mode")

	number mode = getSystemMode()
	self.print("mode = "+mode)
	
	if (mode == "ebsd")
	{
		mySEMdock.calibrateCoordsEBSD()
	}
	else if (mode == "planar")
	{
		mySEMdock.calibrateCoordsPlanar()
	}
	else
	{
		print("mode not set")
	}

	number sim_dock_simulate =  GetTagValue("IPrep:simulation:dock")
	
	// init SEM Dock and transfer system
	mySEMdock.init()
	myTransfer.init()


}


number calibrateCoordsEBSD()
	{
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
		clear.set(reference.getX(), reference.getY(), reference.getZ()-5)
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














	