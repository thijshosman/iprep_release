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

// Workaround for SEM magnification bug after using TH class for stored imaging #TODO:Fix
		number old = emgetmagnification()
		emsetmagnification(old)

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
	
	WorkaroundQuantaMagBug()

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

void Goto_alignment_grid( void )
{
	string s1 = "Move to FWD alignment grid?"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEM().goTofwdGrid()
		WorkaroundQuantaMagBug()
	}
}


void Goto_scribe_mark( void )
{
	string s1 = "Move to scribe mark?"
	if (OKCancelDialog(s1))
	{
		myWorkflow.returnSEM().goToScribeMark()
		WorkaroundQuantaMagBug()
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
		
		WorkaroundQuantaMagBug()

	}
		
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
	
	AddScriptToMenu( "Set_starting_slice_number()", "Set starting slice number...", SS_MENU_HEAD , SS_SUB_MENU_0 , 0)
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
	AddScriptToMenu( "Goto_alignment_grid()", "Goto FWD alignment grid...", SS_MENU_HEAD , SS_SUB_MENU_1 , 0)
	AddScriptToMenu( "beep()", "--", SS_MENU_HEAD , SS_SUB_MENU_1 , 0 )


}

iprep_InstallMenuItems()
