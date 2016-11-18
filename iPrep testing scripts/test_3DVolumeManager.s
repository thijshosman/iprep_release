//$BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

// *** test 3D volume manager ***

try
{
	// init
	//returnVolumeManager().initForDefaultROI()
	//returnVolumeManager().initForAllROIs() // all enabled rois
	//returnVolumeManager().initForPECS()

/*
	// init
	returnVolumeManager().initForSpecificROI("test1")
	// use
	image temp_slice_im := RealImage("iprep_sem", 4, 1000,768)
	object my3DvolumeSEM = returnVolumeManager().returnVolume("test1")
	my3DvolumeSEM.addSlice(temp_slice_im)
	my3DvolumeSEM.show()
*/	

	// init
	//returnVolumeManager().initForDefaultROI()
	
	// create images of compatible size with stack just created
	image temp_slice_im0 := RealImage("iprep_sem0", 4, 4096,4096)
	temp_slice_im0 = 1000
	image temp_slice_im1 := RealImage("iprep_sem1", 4, 4096,4096)
	temp_slice_im1 = 2000
	
	//myWorkflow.returnDigiscan().config(temp_slice_im0,temp_slice_im1)
	//myWorkflow.returnDigiscan().acquire()
	
	result(returnWorkflow().returnDigiscan().DSGetWidth()+", "+returnWorkflow().returnDigiscan().DSGetHeight()+"\n")
	
	object my3DvolumeSEM0 = returnVolumeManager().returnVolume("StoredImaging_"+myWorkflow.returnDigiscan().getName0())
	my3DvolumeSEM0.addSlice(temp_slice_im0)
	
	object my3DvolumeSEM1 = returnVolumeManager().returnVolume("StoredImaging_"+myWorkflow.returnDigiscan().getName1())
	my3DvolumeSEM1.addSlice(temp_slice_im1)
	
	//my3DvolumeSEM.show()
	
	returnVolumeManager().showAll()




}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")





