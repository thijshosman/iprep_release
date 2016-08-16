// define helper functions that will be used throughout the program

// define progress window
object myPW = alloc(progressWindow)
// convention for progresswindow:
// A: sample status
// B: operation
// C: slice number

// define mediator object
object aMediator = alloc(SafetyMediator)

// make sure we can return mediator after this script is installed
object returnMediator()
{
	return aMediator
}

// define SEMCoordManager object

object mySEMCoordManager = alloc(SEMCoordManager)

// allow classes to return this coordManager
object returnSEMCoordManager()
{
	return mySEMCoordManager
}

// define multi-ROI object and the object defining what is enabled

// create the ROIManager
object myROIManager = alloc(ROIManager)

// allow the workflow and UI access to the ROI manager
object returnROIManager()
{
	return myROIManager
}

// create the object that figures out which part of the ROI is enabled
object myROIEnables = alloc(ROIEnables)

// allow the workflow and UI access to the ROI enables
object returnROIEnables()
{
	return myROIEnables
}

// register progresswindow with mediator
returnMediator().registerProgressWindow(myPW)


