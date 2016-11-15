//$BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

// *** test 3D volume manager ***

try
{
	// init
	//returnVolumeManager().initForDefaultROI()
	//returnVolumeManager().initForAllROIs() // all enabled rois
	returnVolumeManager().initForSpecificROI("test1")
	//returnVolumeManager().initForPECS()

	// use
	image temp_slice_im := RealImage("iprep_sem", 2, 1000,768)
	object my3DvolumeSEM = returnVolumeManager().returnVolume("test1")
	my3DvolumeSEM.addSlice(temp_slice_im)
	my3DvolumeSEM.show()
	

}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")





