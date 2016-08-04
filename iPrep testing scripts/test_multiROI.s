//object myROI = returnROIManager().getROIAsObject("StoredImaging")
object myROI 
returnROIManager().getROIAsObject("test1", myROI)
myROI.print()

//object myROI2 = ROIFactory(0,"StoredImaging")
//returnROIManager().addROI(myROI2)

myROI.getAFMode()


// custom digiscan parameters
taggroup dsp = myROI.getDigiscanParam()
dsp.taggroupopenbrowserwindow(0)

