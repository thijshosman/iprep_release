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


void Save_imaging_XYZ_position( void )
{
	number x,y,z
	x=myWorkflow.returnSEM().getX()
	y=myWorkflow.returnSEM().getY()
	z=myWorkflow.returnSEM().getZ()

	string s1 = "Save SEM position\n("+x+","+y+","+z+")\nas default iPrep imaging location?"
	string s2 = Datestamp()+": SEM position ("+x+","+y+","+z+") saved as default iPrep imaging location.\n"
	if (OKCancelDialog(s1))
		myWorkflow.returnSEM().saveCustomAsStoredImaging(x,y,z)
	
	result(s2)	

}

void Goto_nominal_imaging(void)
{
	object myNI = returnSEMCoordManager().getCoordAsCoord("NominalImaging")
	number xx,yy,zz
	xx=myNI.getX()
	yy=myNI.getY()
	zz=myNI.getZ()

	string s1 = "Nominal imaging position\n("+xx+","+yy+","+zz+")\n\nGo there now?"
	if (OKCancelDialog(s1))
		myWorkflow.returnSEM().goToStoredImaging()
	
	//WorkaroundQuantaMagBug()

}


void Recall_imaging_XYZ_position( void )
{
	object mySI = myWorkflow.returnSEM().returnStoredImaging()
	number xx,yy,zz
	xx=mySI.getX()
	yy=mySI.getY()
	zz=mySI.getZ()

	string s1 = "Currently saved iPrep SEM imaging position\n("+xx+","+yy+","+zz+")\n\nGo there now?"
	if (OKCancelDialog(s1))
		myWorkflow.returnSEM().goToStoredImaging()
	
	//WorkaroundQuantaMagBug()

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
	
	//WorkaroundQuantaMagBug()
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
	if ( GetNumber("Enter slice number (>=1) for first acquired image slice:", slice, slice ) )
		IPrep_setSliceNumber( slice - 1 )

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
		
		//WorkaroundQuantaMagBug()

	}
		
}

// PECS functions

void reseat(void)
{
	if (okcanceldialog("reseat the carrier in the PECS mount by moving it out and back in?"))
	myStateMachine.reseat()
}


// setup and init functions

void IPrep_setEBSD(void)
{
	// #todo: check current state
	IPrep_toggle_planar_ebsd("ebsd")
}

void IPrep_setPlanar(void)
{
	// #todo: check current state
	IPrep_toggle_planar_ebsd("planar")
}

// recovery functions
// intended to get the system consistent again

void homeSEMStageToClear(void)
{
	myWorkflow.returnSEM().homeToClear()
}


void homeParker(void)
{
	myWorkflow.returnTransfer().home()
}

void lowerPECSStage(void)
{
	myWorkflow.returnPECS().moveStageDown()
}

void openGV(void)
{
	myWorkflow.returnPECS().openGVandCheck()
}

void closeGV(void)
{
	myWorkflow.returnPECS().closeGVandCheck()
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


void Set_autofocus_enable_dialog( void )
{	
// Set Autofocus tag
	string tagname = "IPrep:SEM:AF:Enable"
	number afs_enable = 0
	GetPersistentNumberNote( tagname, afs_enable )
	if (GetInteger( "Autofocus enable: "+afs_enable, afs_enable, afs_enable) )
		SetPersistentNumberNote( tagname, afs_enable )

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
	string SS_SUB_MENU_4 = "Workflow Items"


	// workflow	
	AddScriptToMenu( "Set_starting_slice_number()", "Set starting slice number...", SS_MENU_HEAD , SS_SUB_MENU_0 , 0)
	AddScriptToMenu( "iprep_setup_imaging()", "use current settings for imaging", SS_MENU_HEAD , SS_SUB_MENU_0 , 0)

	// SEM
	AddScriptToMenu( "Save_imaging_XYZ_position()", "Save imaging XYZ position...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)

	AddScriptToMenu( "Recall_imaging_XYZ_position()", "Recall imaging position...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "beep()", "---", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )

	AddScriptToMenu( "Recall_imaging_parameters_from_image()", "Recall imaging parameters from front image...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "beep()", "-----", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )
	AddScriptToMenu( "Save_imaging_position_focus()", "Save imaging position focus...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Recall_imaging_position_focus()", "Recall imaging position focus...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "beep()", "----", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )

	AddScriptToMenu( "Set_autofocus_enable_dialog()", "Set autofocus state...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "beep()", "------", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )
	
	AddScriptToMenu( "Goto_scribe_mark()", "Goto scribe mark...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	//AddScriptToMenu( "Goto_alignment_grid()", "Goto FWD alignment grid...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Goto_nominal_imaging()", "Goto nominal imaging position...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Goto_highgridback()", "Goto grid on back post...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "Goto_highgridfront()", "Goto grid on front post...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)

	AddScriptToMenu( "beep()", "--", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )

	// PECS
	AddScriptToMenu( "reseat()", "reseat sample carrier in PECS mount", SS_MENU_HEAD , SS_SUB_MENU_2 , 0)

	// setup
	AddScriptToMenu( "IPrep_init()", "Initialize Hardware and Workflow", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_consistency_check()", "IPrep state consistency check", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_recover_deadflag()", "auto recover from dead state", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_setEBSD()", "setup EBSD dock and switch to EBSD mode", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)
	AddScriptToMenu( "IPrep_setPlanar()", "setup Planar dock and switch to Planar mode", SS_MENU_HEAD , SS_SUB_MENU_3 , 0)

	// looped workflow elements
	AddScriptToMenu( "IPrep_image()", "Run Image step...", SS_MENU_HEAD , SS_SUB_MENU_4 , 0)
	AddScriptToMenu( "IPrep_incrementSliceNumber()", "Increment slice number by 1", SS_MENU_HEAD , SS_SUB_MENU_4 , 0)
	AddScriptToMenu( "IPrep_MoveToPECS()", "Move sample to PECS", SS_MENU_HEAD , SS_SUB_MENU_4 , 0)
	AddScriptToMenu( "IPrep_Pecs_Image_beforemilling()", "Take PECS Camera image before milling", SS_MENU_HEAD , SS_SUB_MENU_4 , 0)
	AddScriptToMenu( "IPrep_mill()", "Run Milling step...", SS_MENU_HEAD , SS_SUB_MENU_4 , 0)
	AddScriptToMenu( "IPrep_Pecs_Image_aftermilling()", "Take PECS Camera image after milling", SS_MENU_HEAD , SS_SUB_MENU_4 , 0)
	AddScriptToMenu( "IPrep_MoveToSEM()", "Move sample to SEM", SS_MENU_HEAD , SS_SUB_MENU_4 , 0)


	// service menu #todo: make password protected
	string SS_MENU_HEAD_SERVICE = "Service"
	string SS_SUB_MENU_SERVICE_0 = "Safety Flags"
	string SS_SUB_MENU_SERVICE_1 = "Manual State Setup"
	string SS_SUB_MENU_SERVICE_2 = "save or load iprep tags"


	AddScriptToMenu( "homeSEMStageToClear()", "home SEM stage to clear", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "openGV()", "open gate valve", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "closeGV()", "close gate valve", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "homeParker()", "home parker stage", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "lowerPECSStage", "lower pecs stage", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "setSEMstate()", "set workflow state to SEM", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)
	AddScriptToMenu( "setPECSstate()", "set workflow state to PECS", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_1 , 0)


	AddScriptToMenu( "setAliveSafe()", "remove dead/unsafe flag", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_0 , 0)

	AddScriptToMenu( "saveTagsToFile()", "save tags", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_2 , 0)
	AddScriptToMenu( "loadTagsFromFile()", "load tags", SS_MENU_HEAD_SERVICE , SS_SUB_MENU_SERVICE_2 , 0)





}

iprep_InstallMenuItems()
