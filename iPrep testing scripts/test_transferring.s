// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

try
{

	// *** setup ***
		// reset slice number
		//IPrep_setSliceNumber(0)

		//IPrep_Setup_Imaging()
		//IPrep_StoreCurrentSEMPosition()
		//IPrep_StoreSEMPositionAsStoredImaging(7.240,-19.364,45.741)



	// *** transfer ***
	//IPrep_MoveToSEM()
	//IPrep_MoveToPECS()


	// *** imaging ***

	//IPrep_image()
	//IPrep_IncrementSliceNumber()

	// *** milling ***
	//IPrep_Mill()

}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")

