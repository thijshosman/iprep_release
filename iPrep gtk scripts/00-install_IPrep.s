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

InstallFile( PathConcatenate( gPath, "IPrep_statePersistence.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_progressWindow.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_general.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_multi_roi.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_init_helpers.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_UPS_APC.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_UPS_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_SEM_Quanta.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_SEM_Nova.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_SEM_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_dock_planar.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_dock_EBSD.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_dock_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_transfer_parkerIPA.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_transfer_parkerARIES.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_transfer_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_gripper_rev1.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_gripper_rev2.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_gripper_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_pecs_rev1.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_pecs_rev2.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_pecs_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_pecscamera.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_pecscamera_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_digiscan.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_digiscan_simulator.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_ebsd_simulator.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_ebsd_manual.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_ebsd_oi_automatic.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_hardwareFactory.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_workflowElements.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_workflowHelperFunctions.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_3Dvolume.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_device_sequences.s" ), package, 3 )
InstallFile( PathConcatenate( gPath, "IPrep_sequenceFactory.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_mainStateMachine.s" ), package, 3 )


// InstallFile( PathConcatenate( gPath, "IPrep_alignment.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_main.s" ), package, 3 )

InstallFile( PathConcatenate( gPath, "IPrep_UI.s" ), package, 3 )

result("Done installing "+package+" scripts as plugin.\n")

//string menu = "Detector_Engineering"
//string submenu = ""
//InstallInMenu( "alloc(EFT_cooldown).init().startthread()", "Cool Down", menu, submenu, package, 3 )
//
//submenu = "Orius"
//InstallInMenu( "UI_for_EEPROM()", "HEAD EEPROM", menu, submenu, package, 3 )


//InstallFile( PathConcatenate( gPath, "configure menu.s" ), package, 3 )

