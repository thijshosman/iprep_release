// $BACKGROUND$
/* INSTALL AS A LIBRARY for all users

Requires:
--

=====================================
iPrep_UI
=====================================
Version 20150729

History:
20150729 - Created.

*/

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()


/////////////////////
// Initial functions
/////////////////////

// *** sem functions ***

void Save_imaging_XYZ_position( void )
{
	number x,y,z
	x=myWorkflow.returnSEM().getX()
	y=myWorkflow.returnSEM().getY()
	z=myWorkflow.returnSEM().getZ()

	string s1 = "Save SEM position\n("+x+","+y+","+z+")\nas default iPrep imaging location?"
	string s2 = Datestamp()+": SEM position ("+x+","+y+","+z+") saved as default iPrep imaging location (storedImaging).\n"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEM().saveCustomAsStoredImaging(x,y,z)
		result(s2)	
	}
	

}

void Goto_nominal_imaging(void)
{
	object myNI = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
	number xx,yy,zz
	xx=myNI.getX()
	yy=myNI.getY()
	zz=myNI.getZ()

	string s1 = "Nominal imaging position\n("+xx+","+yy+","+zz+")\n\nGo there now?"
	if (OKCancelDialog(s1))
	{	myWorkflow.returnSEM().goToNominalImaging()
		WorkaroundQuantaMagBug()

	}
}


void Recall_imaging_XYZ_position( void )
{
	object mySI = myWorkflow.returnSEM().returnStoredImaging()
	number xx,yy,zz
	xx=mySI.getX()
	yy=mySI.getY()
	zz=mySI.getZ()

	string s1 = "Currently saved iPrep SEM imaging position (storedImaging)\n("+xx+","+yy+","+zz+")\n\nGo there now?"
	if (OKCancelDialog(s1))
	{	
		myWorkflow.returnSEM().goToStoredImaging()
		//WorkaroundQuantaMagBug()
		//result(s1)
	}
}


void Save_imaging_position_focus( void )
{
	number current_focus = myWorkflow.returnSEM().measureWD()
	
	number saved_focus = 0
	string tagname = "IPrep:SEM:WD:value"
	GetPersistentNumberNote( tagname, saved_focus )

	string s1 = "Current SEM imaging focus value: ("+current_focus+" mm)\n"
	string s2 = "Currently saved iPrep SEM imaging focus value: ("+saved_focus+" mm)\n"
	string s3 = Datestamp()+": Current SEM focus ("+current_focus+" mm) saved as default iPrep imaging focus value.\n"

	if (OKCancelDialog(s1+s2+"\nSave current SEM imaging focus value?"))
	{
		myWorkflow.returnSEM().setDesiredWD(current_focus)
		result(s3)
	}
}

void Recall_imaging_position_focus( void )
{
	number current_focus = myWorkflow.returnSEM().measureWD()
	
	number saved_focus = 0
	string tagname = "IPrep:SEM:WD:value"
	GetPersistentNumberNote( tagname, saved_focus )

	string s1 = "Current SEM imaging focus value: ("+current_focus+" mm)\n"
	string s2 = "Currently saved iPrep SEM imaging focus value: ("+saved_focus+" mm)\n"

	if (OKCancelDialog(s2+s1+"\nSet current SEM imaging focus value to saved value ("+saved_focus+" mm)?"))
	{
		myWorkflow.returnSEM().setDesiredWD(saved_focus)
	}
	
	WorkaroundQuantaMagBug()
}

void GoToSpecifiedCoord(void)
{
	string s0 = "Please enter a coord name. "
	string s1 = "StoredImaging"
	string enterdValue = "StoredImaging"
	if (getstring(s0, s1, enterdValue))
	{
		if (returnSEMCoordManager().checkCoordExistence(enterdValue))
		{
		myWorkflow.returnSEM().goToImagingPosition(enterdValue)

		}
		else 
		{
			// coord not found
			string s2 = "coord "+enterdValue+" not found!"
			result(s2+"\n")
			okdialog(s2)
		}
	}


}

void Goto_alignment_grid( void ) // not needed in Nova
{
	string s1 = "Move to FWD alignment grid?"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEM().goTofwdGrid()
		//WorkaroundQuantaMagBug()
	}
}

void Goto_highgridback( void )
{
	string s1 = "Move to grid on post closest to back of chamber?"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEM().goToHighGridBack()
		//WorkaroundQuantaMagBug()
	}


}

void Goto_clear()
{
	string s1 = "Move to clear position from imaging position by moving Z last?"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEM().goToClear()
		WorkaroundQuantaMagBug()
	}
}


void Goto_highgridfront( void )
{
	string s1 = "Move to grid on post closest to front of chamber?"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEM().goToHighGridFront()
		//WorkaroundQuantaMagBug()
	}


}

void Goto_scribe_mark( void )
{
	string s1 = "Move to scribe mark?"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEM().goToScribeMark()
		//WorkaroundQuantaMagBug()
	}
}


void Set_starting_slice_number( void )
{
	number slice = IPrep_sliceNumber() + 1
	if ( GetNumber("Enter slice number (>=0) for first acquired image slice:", slice, slice ) )
		IPrep_setSliceNumber( slice )

	if ( slice < 0)
		slice = 0
		
}

void Recall_imaging_parameters_from_image( void )
{
	image img:=GetFrontImage()

	number XX,  YY,  ZZ, count = 0
	string tagname = "Microscope Info:Stage Position:Stage "
	if ( GetNumberNote( img, tagname+"X", XX ) )
		count ++
		
	if ( GetNumberNote( img, tagname+"Y", YY ) )
		count ++

	if ( GetNumberNote( img, tagname+"Z", ZZ ) )
		count ++

	if (count != 3)
		throw( "No image position information found in front image." )
	
	if ( OKCancelDialog("Goto SEM stage location: ("+XX+","+YY+","+ZZ+")"))
	{
		if ( EMGetStageZ() > ZZ )
		{
			EMSetStageXY( XX, YY )
			EMSetStageZ( ZZ )
		}
		else
		{
			EMSetStageZ( ZZ )
			EMSetStageXY( XX, YY )
		}
		
		WorkaroundQuantaMagBug()

	}
		
}

void Set_autofocus_enable_dialog( void )
{
	// set autofocus state for workflow

	// get the ROI (default/StoredImaging in this case)
	object myROI 
	string name1 = "StoredImaging"
	returnROIManager().getROIAsObject(name1, myROI)

	number af_mode = myROI.getAFMode()
	GetNumber("Enter autofocus mode (0=leave alone, 1=autofocus, 2=fixed value saved)", af_mode, af_mode )
	
	if (af_mode > 2)
	{
		result("leaving Autofocus alone\n")
		throw ("invalid number, leaving autofocus mode alone")
	}
	else
		myROI.setAFMode(af_mode)

	result("Autofocus mode set to "+af_mode+"\n")
}



// PECS functions

void pecs_reseat(void)
{
	if (okcanceldialog("reseat the carrier in the PECS mount by moving it out and back in?"))
		IPrep_reseat()
}

void pecs_raise(void)
{
	if (okcanceldialog("raise the PECS stage?"))
		myWorkflow.returnPecs().moveStageUp()
}

void pecs_lower(void)
{
	if (okcanceldialog("lower the PECS stage?"))
		myWorkflow.returnPecs().moveStageDown()
}

void pecs_home(void)
{
	if (okcanceldialog("home the PECS stage?"))
		myWorkflow.returnPecs().stageHome()
}

// setup and init functions

void IPrep_init_sequence()
{
	myStateMachine.init(myWorkflow)
}


void IPrep_setEBSD(void)
{
	// #todo: check current state
	string s1 = "Are you sure you want to change the system mode to EBSD?"
	if (OKCancelDialog(s1))
		IPrep_toggle_planar_ebsd("ebsd")
}

void IPrep_setPlanar(void)
{
	// #todo: check current state
	string s1 = "Are you sure you want to change the system mode to Planar?"
	if (OKCancelDialog(s1))
		IPrep_toggle_planar_ebsd("planar")
}

void IPrep_setScribeROI(void)
{
	// interprets user rectangular ROI and realigns scribe mark


	string s1 = "Is live view running and is there an ROI on image around the correct scribe position?"
	if(!okcanceldialog(s1))
		return

	try
	{
		image im := getfrontimage()

		//get roi
		number t,l,b,r
		GetSelection(im,t,l,b,r)
		result("top: "+t+", left: "+l+", bottom: "+b+", right: "+r+"\n")

		//get size
		number x,y,z
		getsize(im,x,y)
		result("width: "+x+", height: "+y+"\n")

		// center of image: 
		number image_center_x, image_center_y
		image_center_x = x/2
		image_center_y = y/2
		result("image center: ("+image_center_x+","+image_center_y+")\n")

		// center of roi: 
		number roi_center_x, roi_center_y
		roi_center_x = l+(r-l)/2
		roi_center_y = t+(b-t)/2
		result("roi center: ("+roi_center_x+","+roi_center_y+")\n")

		// calculate vector from center: 
		number misalignment_vector_x, misalignment_vector_y
		misalignment_vector_x = image_center_x - roi_center_x
		misalignment_vector_y = roi_center_y - image_center_y
		result("vector: ("+misalignment_vector_x+","+misalignment_vector_y+")\n")

		// get calibration data from image
		number scale_x, scale_y, x_cal, y_cal
		im.GetScale(scale_x, scale_y)
		string units = im.GetUnitString()
		x_cal = misalignment_vector_x * scale_x
		y_cal = misalignment_vector_y * scale_y
		result( "misalignment of x="+x_cal+", y="+y_cal+" "+units+"\n")



		// add a new coordinate that functions as the test point to see if calibration succeeded
		object newscribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos")
		newscribe_pos.corrX(-x_cal/1000)
		newscribe_pos.corrY(-y_cal/1000)
		newscribe_pos.setName("testcal")
		returnSEMCoordManager().addCoord(newscribe_pos)

		myWorkflow.returnSEM().goToImagingPosition("testcal")

		if (abs(x_cal/1000) > 2 || abs(y_cal/1000) > 2)
		{
			result("correction too big: x= "+x_cal+" um, y= "+y_cal+" um\n")
			result("maximum correction is 2 mm in x and y")
			throw("correction too big, aborting")
		}


		if (okcanceldialog("Did the stage move the scribe mark to the center of the live view image?"))
			IPrep_scribemarkVectorCorrection(-x_cal/1000,-y_cal/1000)
		else
		{
			result("not succeeded, user did not accept change\n")	
			return
		}
		result("scribe mark correction done\n")
	}
	catch
	{
		okdialog("something went wrong: "+GetExceptionString())
		break
	}



}






// recovery functions
// intended to get the system consistent again

void homeSEMStageToClear(void)
{
	object myClear = returnSEMCoordManager().getCoordAsCoord("clear")
	number xx,yy,zz
	xx=myClear.getX()
	yy=myClear.getY()
	zz=myClear.getZ()

	string s1 = "clear position\n("+xx+","+yy+","+zz+")\n\nGo (home) there now?"
	if (OKCancelDialog(s1))
		myWorkflow.returnSEM().homeToClear()
	WorkaroundQuantaMagBug()
}

void gotoPickupDropoff(void)
{
	object myP = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
	number xx,yy,zz
	xx=myP.getX()
	yy=myP.getY()
	zz=myP.getZ()

	string s1 = "pickup dropoff position\n("+xx+","+yy+","+zz+")\n\nGo there now?"
	if (OKCancelDialog(s1))
		myWorkflow.returnSEM().goToPickup_Dropoff()
	WorkaroundQuantaMagBug()
}

void homeParker(void)
{
	string s1 = "Home the parker stage now?"
	if (OKCancelDialog(s1))
		myWorkflow.returnTransfer().home()
}

void lowerPECSStage(void)
{
	string s1 = "Lower the PECS stage now?"
	if (OKCancelDialog(s1))
		myWorkflow.returnPECS().moveStageDown()
}

void openGV(void)
{
	string s1 = "Open the Gate Valve?"
	if (OKCancelDialog(s1))
		myWorkflow.returnPECS().openGVandCheck()
}

void closeGV(void)
{
	string s1 = "Close the Gate Valve?"
	if (OKCancelDialog(s1))
		myWorkflow.returnPECS().closeGVandCheck()
}

void clamp(void)
{
	string s1 = "Clamp the dock?"
	if (OKCancelDialog(s1))
	{	
		myWorkflow.returnSEMDock().clamp()
		myWorkflow.returnSEMDock().lookupState(1)
	}
}

void unclamp(void)
{
	string s1 = "Unclamp the dock?"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEMDock().unclamp()
		myWorkflow.returnSEMDock().lookupState(1)
	}
}

void lockPecs(void)
{
	myWorkflow.returnPECS().lockout()
}

void unlockPecs(void)
{
	myWorkflow.returnPECS().unlock()
}

void gripperOpen(void)
{
	myWorkflow.returnGripper().open()		
}

void gripperClose(void)
{
	myWorkflow.returnGripper().close()
}

void setAliveSafe(void)
{
	returnDeadFlag().setAliveSafe()
}

void setSEMstate(void)
{
	myStateMachine.changeWorkflowState("SEM")

}

void setPECSstate(void)
{
	myStateMachine.changeWorkflowState("PECS")

}





void saveTagsToFile(void)
{
	taggroup PT = getpersistenttaggroup()

	taggroup ipreptg 
	PT.TagGroupGetTagAsTagGroup("IPrep",ipreptg)

	//ipreptg.TagGroupOpenBrowserWindow( 0 )

	ipreptg.TagGroupSaveToFile("c:\\temp\\iprep_tags")

}

void loadTagsFromFile(void)
{
	taggroup PT = getpersistenttaggroup()

	taggroup ipreploadtg = newtaggroup()

	ipreploadtg.TagGroupLoadFromFile("c:\\temp\\iprep_tags")

	//ipreploadtg.TagGroupOpenBrowserWindow( 0 )

	PT.addtaggroup(ipreploadtg,"IPrep")

	//PT.TagGroupOpenBrowserWindow( 0 )
}



number IPrep_calibrate_transfer()
{
	result("iprep_calibrate_transfer"+"\n")
	// #todo: no longe works until alignment is fixed
	//myWorkflow.calibrateForMode()
}

// Multi ROI functions

void IPrep_addROI()
{
	// create a ROI. ask user for name and store current SEM position as a new SEMPosition under that ROI with current wd and mag

	string s0 = "an ROI with default values will be generated with entered name. it will default to an SEM position with the same name and current location"
	string s1 = "newregionname"
	string newROIname = "testpositionui"

	if (getstring(s0,s1,newROIname))
	{
		// create the ROI
		object myROI = ROIFactory(0,newROIname)
		
		// set mag
		myROI.setMag(myWorkflow.returnSEM().measureMag())
		
		// set focus
		myROI.setFocus(myWorkflow.returnSEM().measureWD())

		// add the ROI
		returnROIManager().addROI(myROI)
		result("ROI created with name "+newROIname+"\n\n")
		myROI.print()

		// now add SEM position with same name
		number x,y,z
		x=myWorkflow.returnSEM().getX()
		y=myWorkflow.returnSEM().getY()
		z=myWorkflow.returnSEM().getZ()

		// create new coord
		object aCoord = alloc(SEMCoord)
		
		// set position
		aCoord.set(newROIname,x,y,z)

		// add the coord
		returnSEMCoordManager().addCoord(aCoord)

		result("saved position "+newROIname+"\n\n")
		aCoord.print()


	}
}

void IPrep_addSEMPosition()
{
	// ask user for a new ROI name and add it with default settings

	number x,y,z
	x=myWorkflow.returnSEM().getX()
	y=myWorkflow.returnSEM().getY()
	z=myWorkflow.returnSEM().getZ()

	string s0 = "Please enter a name. Current SEM location and focus will be saved as this position. existing names will be overwritten"
	string s1 = "newposition"
	string newROIname = "testpositionUI"
	if (getstring(s0, s1, newROIname))
	{
		// #todo: get current focus value and save that too, but doesn't matter since we save focus in ROI now, not coord


		object aCoord = alloc(SEMCoord)
		aCoord.set(newROIname,x,y,z)
		returnSEMCoordManager().addCoord(aCoord)
		
		result("saved position "+newROIname+"\n\n")
		aCoord.print()
	}
}



void IPrep_printEnabledROIs()
{
	// print a list of all enabled ROIS in order

	object tall_enabled = returnROIManager().getAllEnabledROIList()
	number count = tall_enabled.SizeOfList()
	
	result("found "+count+"positions:\n")
	number i=0
		foreach(object myROI; tall_enabled)
		{

			result(i+": "+myROI.getName()+", order="+myROI.getOrder()+", mag="+myROI.getMag()+", image size=("+myROI.getDigiscanX()+","+myROI.getDigiscanY()+")\n")

		}
}

void IPrep_setSetCustomImageSequence()
{
	// load a custom image sequence into workflow


	string q = "Which image sequence do you want to use? image_single is default single ROI with name StoredImaging"
	string oldSequence= getTagString("IPrep:workflowSequences:imaging")
	string newImagingSequenceName = "image_single"

	// see if user cancels

	// test if we can load this

	number s1 = getstring(q,oldSequence,newImagingSequenceName)
	number s2 = myStateMachine.loadCustomImageSequence(newImagingSequenceName)
	if (s2 && s1)
	{
		print("imaging sequence "+newImagingSequenceName+" loaded")
		// now make it the active one in case we reinitialize
		overwriteTag(getpersistenttaggroup(), "IPrep:workflowSequences:imaging", newImagingSequenceName)
	}
	else
	{
		//debug("s1: "+s1+", s2: "+s2+"\n")
		// if not, we can now revert back
		myStateMachine.loadCustomImageSequence(oldSequence)
		print("imaging sequence "+oldSequence+" loaded")

		okdialog(newImagingSequenceName+"not loaded. leaving "+oldSequence+"in there")
	}

	
	

}


// Single (default) ROI functions

void IPrep_setSingleROIFocus() // deprecated
{
	// set working distance to current measured working distance for default ROI
	
	string s0 = "Set working distance for default ROI to current measured working distance?"	

	if (okcanceldialog(s0))
	{
		object myROI
		string name1 = "StoredImaging"
		if (!returnROIManager().getROIAsObject(name1, myROI))
		{
			print("defaultROI does not exist!")
			return
		}
		number imagingWD = myWorkflow.returnSEM().measureWD()
		myROI.setFocus(imagingWD)
		print("Working Distance for defeault ROI set to: "+imagingWD)
	}
}

void IPrep_setSingleImageSequence()
{
	// load a single image sequence into workflow for use with 1 ROI

	number s2 = myStateMachine.loadCustomImageSequence("image_single")
	if (s2)
	{
		print("imaging sequence image_single loaded")
		// now make it the active one in case we reinitialize
		overwriteTag(getpersistenttaggroup(), "IPrep:workflowSequences:imaging", "image_single")
	}
	else
	{
		throw ("problem loading image_single")
	}
}

void IPrep_useCurrentMagForROI()
{
	// use the current mag value in the ROI 
	
	string name1 = "StoredImaging"
	object myROI
	returnROIManager().getROIAsObject(name1, myROI)

	number val = 0
	val = myWorkflow.returnSEM().measureMag()

	// set mag
	myROI.setMag(val)

	// add the ROI
	returnROIManager().addROI(myROI)
	result("ROI "+name1+" updatd with new mag "+val+" \n\n")
	myROI.print()
}

void IPrep_useCurrentFocusForROI()
{
	// use the current focus value in the ROI 
	// remember that focus is only set from ROI if that mode (2) is selected

	string name1 = "StoredImaging"
	object myROI
	returnROIManager().getROIAsObject(name1, myROI)

	number val = 0
	val = myWorkflow.returnSEM().measureWD()

	// set focus
	myROI.setFocus(val)

	// add the ROI
	returnROIManager().addROI(myROI)
	result("ROI "+name1+" updatd with new focus "+val+" \n\n")
	myROI.print()
}


/////////////////////
// Menus
/////////////////////

void iprep_InstallMenuItems( void )
{
	string SS_MENU_HEAD = "iPrep"
	string SS_SUB_MENU_0 = "Workflow"
	string SS_SUB_MENU_1 = "SEM"
	string SS_SUB_MENU_2 = "PECS"
	string SS_SUB_MENU_3 = "Recovery and Setup"
	string SS_SUB_MENU_5 = "Loop Control"
	string SS_SUB_MENU_6 = "Multi ROI Setup"
	string SS_SUB_MENU_7 = "Single ROI Setup"

	// workflow	
	AddScriptToMenu( "Set_starting_slice_number()", "Set starting slice number...", SS_MENU_HEAD , SS_SUB_MENU_0 , 0)
	AddScriptToMenu( "IPrep_acquire_ebsd()", "Run EBSD step", SS_MENU_HEAD , SS_SUB_MENU_0 , 0)
	AddScriptToMenu( "IPrep_image()", "Run Image step", SS_MENU_HEAD , SS_SUB_MENU_0 , 0)
	AddScriptToMenu( "IPrep_Pecs_Image_aftermilling()", "Run PECS Image After Milling step", SS_MENU_HEAD , SS_SUB_MENU_0 , 0)


	// SEM
	AddScriptToMenu( "homeSEMStageToClear()", "home SEM stage to clear", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)

	AddScriptToMenu( "beep()", "---", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )

	AddScriptToMenu( "Save_imaging_XYZ_position()", "Save imaging XYZ position (as stored imaging)...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Recall_imaging_XYZ_position()", "Recall current stored imaging position...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	
	AddScriptToMenu( "beep()", "---", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )

	AddScriptToMenu( "Recall_imaging_parameters_from_image()", "Recall imaging parameters from front image...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	
	AddScriptToMenu( "beep()", "-----", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )
	
	AddScriptToMenu( "Save_imaging_position_focus()", "Save imaging position focus...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Recall_imaging_position_focus()", "Recall imaging position focus...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	
	AddScriptToMenu( "beep()", "----", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )

	AddScriptToMenu( "Set_autofocus_enable_dialog()", "Set autofocus state...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	
	AddScriptToMenu( "IPrep_autofocus()", "Run IPrep Autofocus routine", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)

	AddScriptToMenu( "beep()", "------", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )

	AddScriptToMenu( "GoToSpecifiedCoord()", "Goto a user specified coordinate...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)

	AddScriptToMenu( "Goto_clear()", "Goto clear and move in z last...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Goto_scribe_mark()", "Goto scribe mark...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Goto_nominal_imaging()", "Goto nominal imaging position...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Goto_highgridback()", "Goto grid on back post...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Goto_highgridfront()", "Goto grid on front post...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "WorkaroundQuantaMagBug()", "WorkaroundQuantaMagBug", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)

	AddScriptToMenu( "beep()", "--", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )

	// PECS
	AddScriptToMenu( "lockPecs()", "Lock PECS UI", SS_MENU_HEAD , SS_SUB_MENU_2 , 0)
	AddScriptToMenu( "unlockPecs()", "Unlock PECS UI", SS_MENU_HEAD , SS_SUB_MENU_2 , 0)
	AddScriptToMenu( "pecs_reseat()", "reseat sample carrier in PECS mount", SS_MENU_HEAD , SS_SUB_MENU_2 , 0)
	AddScriptToMenu( "pecs_lower()", "lower PECS stage", SS_MENU_HEAD , SS_SUB_MENU_2 , 0)
	AddScriptToMenu( "pecs_raise()", "raise PECS stage", SS_MENU_HEAD , SS_SUB_MENU_2 , 0)
	AddScriptToMenu( "pecs_home()", "rotate PECS stage to home", SS_MENU_HEAD , SS_SUB_MENU_2 , 0)

	// setup
	AddScriptToMenu( "IPrep_init()", "Initialize Hardware", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_init_sequence()", "Initialize Active Sequences", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_consistency_check()", "IPrep state consistency check", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_recover_deadflag()", "auto recover from dead state", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_setEBSD()", "switch to EBSD dock and EBSD mode", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_setPlanar()", "switch to Planar dock and Planar mode", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_calibrate_transfer()", "reinitialize all SEM stage and Parker calibrations from mode selection", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_setScribeROI()", "calibrate scribe mark position after setting ROI", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)

	// ROI Setup
	AddScriptToMenu( "IPrep_addSEMPosition()", "Add a new SEM coordinate", SS_MENU_HEAD , SS_SUB_MENU_6 , 0)
	AddScriptToMenu( "IPrep_addROI()", "Add a ROI of current conditions", SS_MENU_HEAD , SS_SUB_MENU_6 , 0)
	AddScriptToMenu( "IPrep_setSetCustomImageSequence()", "Setup system to use custom image sequence", SS_MENU_HEAD , SS_SUB_MENU_6 , 0)
	AddScriptToMenu( "IPrep_printEnabledROIs()", "show all enabled ROIs in order", SS_MENU_HEAD , SS_SUB_MENU_6 , 0)
	

	// single ROI
	AddScriptToMenu( "IPrep_setSingleImageSequence()", "load single default image ROI with name StoredImaging", SS_MENU_HEAD , SS_SUB_MENU_7 , 0)
	AddScriptToMenu( "IPrep_useCurrentFocusForROI()", "Use the current focus for StoredImaging ROI", SS_MENU_HEAD , SS_SUB_MENU_7 , 0)
	AddScriptToMenu( "IPrep_useCurrentMagForROI()", "Use the current mag for StoredImaging ROI", SS_MENU_HEAD , SS_SUB_MENU_7 , 0)





	// iprep loop control
	//AddScriptToMenu( "IPrep_startrun()", "Start run...", SS_MENU_HEAD , SS_SUB_MENU_5 , 0)
	//AddScriptToMenu( "iprep_pauserun()", "Pause run...", SS_MENU_HEAD , SS_SUB_MENU_5 , 0)
	//AddScriptToMenu( "iprep_stoprun()", "Stop run...", SS_MENU_HEAD , SS_SUB_MENU_5 , 0)
	//AddScriptToMenu( "iprep_resumerun()", "Resume run...", SS_MENU_HEAD , SS_SUB_MENU_5 , 0)

	// service menu #todo: make password protected
	string SS_MENU_HEAD_SERVICE = "Service"
	string SS_SUB_MENU_SERVICE_0 = "Safety Flags"
	string SS_SUB_MENU_SERVICE_1 = "Manual State Setup"
	string SS_SUB_MENU_SERVICE_2 = "save or load iprep tags"
	string SS_SUB_MENU_SERVICE_3 = "Workflow Items"

	
	AddScriptToMenu( "gotoPickupDropoff()", "Goto pickup_dropoff position", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "openGV()", "open gate valve", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "closeGV()", "close gate valve", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "clamp()", "clamp sem dock", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "unclamp()", "unclamp sem dock", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "homeParker()", "home parker stage", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "lowerPECSStage()", "lower pecs stage", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "setSEMstate()", "set workflow state to SEM", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "setPECSstate()", "set workflow state to PECS", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "gripperOpen()", "Open Gripper", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "gripperClose()", "Close Gripper", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)


	AddScriptToMenu( "setAliveSafe()", "remove dead/unsafe flag", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_0 , 0)

	AddScriptToMenu( "saveTagsToFile()", "save tags", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_2 , 0)
	AddScriptToMenu( "loadTagsFromFile()", "load tags", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_2 , 0)


	// looped workflow elements
	AddScriptToMenu( "IPrep_image()", "Run Image step...", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)
	AddScriptToMenu( "IPrep_acquire_ebsd()", "Run EBSD acquisition step...", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)
	AddScriptToMenu( "IPrep_incrementSliceNumber()", "Increment slice number by 1", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)
	AddScriptToMenu( "IPrep_MoveToPECS()", "Move sample to PECS", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)
	AddScriptToMenu( "IPrep_Pecs_Image_beforemilling()", "Take PECS Camera image before milling", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)
	AddScriptToMenu( "IPrep_mill()", "Run Milling step...", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)
	AddScriptToMenu( "IPrep_coat()", "Run Coating step...", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)
	AddScriptToMenu( "IPrep_Pecs_Image_aftermilling()", "Take PECS Camera image after milling", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)
	AddScriptToMenu( "IPrep_MoveToSEM()", "Move sample to SEM", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_3 , 0)


}

iprep_InstallMenuItems()
