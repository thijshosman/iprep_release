// $BACKGROUND$

object myWorkflow = returnWorkflow()


// define autofocus here since it uses workflow elements but needs to be there later

void IPrep_autofocus_complete()
{

	// get digiscan control
	myWorkflow.returnDigiscan().getControl()
	//unblank
	myWorkflow.returnSEM().blankOff()

	print("IMAGE: autofocusing")
	number old_focus = myWorkflow.returnSEM().measureWD()	

	// dirty hack: if simulating SEM, do not autofocus
	number sim
	getpersistentnumbernote("IPrep:simulation:sem",sim)
	if (sim == 1)
	{
		result("simulating sem, skipping af\n")
		
	}
	else
	{
		IPrep_autofocus()
		number afs_sleep = 1	// seconds of delay
		sleep( afs_sleep )
	}
	
	number new_focus = myWorkflow.returnSEM().measureWD()	
	myWorkflow.returnSEM().setDesiredWDToCurrent()

	print("IMAGE: old focus: "+old_focus+" mm, new focus: "+new_focus+" mm")
	
	//blank
	returnWorkflow().returnSEM().blankOn()
}

// save tags for IPrep

void SaveDefaultTags(image img)
{
	TagGroup ntg = img.ImageGetTagGroup()
	TagGroup tg = newtaggroup() 

	tg.addTag("focus",myWorkflow.returnSEM().measureWD())
	tg.addTag("slice",IPrep_sliceNumber())

	ntg.addTagGroup(tg,"", "IPrep")


}

void SaveDefaultTags(image img, object myROI)
{
	TagGroup ntg = img.ImageGetTagGroup()
	TagGroup tg = newtaggroup() 

	tg.addTag("focus",myWorkflow.returnSEM().measureWD())
	tg.addTag("slice",IPrep_sliceNumber())

	taggroup ROItag = myROI.returnAsTag()

	tg.addTagGroup(ROItag,"","ROI")

	ntg.addTagGroup(tg,"", "IPrep")
}


