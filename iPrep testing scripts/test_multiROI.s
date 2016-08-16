
// get an ROI
object myROI 
returnROIManager().getROIAsObject("test1", myROI)
myROI.print()

// create a ROI and add it (overwrite if it isn't there)
object myROI2 = ROIFactory(0,"ExtraROI")
returnROIManager().addROI(myROI2)

// get attributes of ROI
myROI.getAFMode()

// get ROI that does not exist
//object myROI1 
//returnROIManager().getROIAsObject("testDoesNotExist", myROI1)
//myROI1.print()

// get custom digiscan parameters
taggroup dsp = myROI.getDigiscanParam()
dsp.taggroupopenbrowserwindow(0)

