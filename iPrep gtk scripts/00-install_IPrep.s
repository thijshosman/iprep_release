// Install iPrep script files into GTK package.

void InstallFile( string file, string package, number level )
{
	Result( "About to install file: " + file + "\n" )
	if( package == "" ) {
		AddScriptFileToMenu( file, file, "Doesn't matter", "Doesn't matter", 1 )
	} else {
	try	
		AddScriptFileToPackage(	file, package, level, file, "Doesn't matter", "Doesn't matter",	1 )
	catch
		result("error installing "+file+"\n")
	}
}

void InstallInMenu( string command, string name, string menu, string submenu, string package, number level )
{
	Result( "About to install command: " + command + " as menu item: " + name + "\n" )
	if( package == "" ) {
		AddScriptToMenu( command, name, menu, submenu, 0 )
	} else {
		AddScriptToPackage( command, package, level, name, menu, submenu, 0 )
	}
}

String gpath
if ( GetCurrentScriptSourceFilePath( gpath ) )
{
	gpath = PathExtractDirectory( gpath, 0 )
}
else 
{
	gpath = PathConcatenate( PathBeginRelative(), "CameraScripts" );
}



string package = "IPrep"

InstallFile( PathConcatenate( gPath, "statePersistance.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "progressWindow.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "iprep_general.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "multi_roi.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "iprep_init_helpers.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "hardwareFactory.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "UPS_APC.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "UPS_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "SEM_iprep.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "SEM_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "PlanarSEMdock.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "EBSDSEMdock.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "dock_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "transfer.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "transfer_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "gripper.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "gripper_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "pecs_iprep.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "pecs_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "pecscamera_iprep.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "pecscamera_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "digiscan_iprep.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "digiscan_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "ebsd_simulator.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "ebsd_manual.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "ebsd_oi_automatic.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "workflowElements.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "workflowHelperFunctions.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "iprep_3Dvolume.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "device_sequences.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "sequenceFactory.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "mainStateMachine.s" ), package, 3 )


// InstallFile( PathConcatenate( gPath, "iprep_alignment.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "iprep_main.s" ), package, 3 )

//InstallFile( PathConcatenate( gPath, "iprep_pecsstatuschecker.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "iprep_UI.s" ), package, 3 )

result("Done installing "+package+" scripts as plugin.\n")

//string menu = "Detector_Engineering"
//string submenu = ""
//InstallInMenu( "alloc(EFT_cooldown).init().startthread()", "Cool Down", menu, submenu, package, 3 )
//
//submenu = "Orius"
//InstallInMenu( "UI_for_EEPROM()", "HEAD EEPROM", menu, submenu, package, 3 )


//InstallFile( PathConcatenate( gPath, "configure menu.s" ), package, 3 )

