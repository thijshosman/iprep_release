

// create the ROIManager
//object myROIManager = alloc(ROIManager)

// allow the workflow and UI access to the ROI manager
//object returnROIManager()
//{
//	return myROIManager
//}

// create the object that figures out which part of the ROI is enabled
//object myROIEnables = alloc(ROIEnables)

// allow the workflow and UI access to the ROI enables
//object returnROIEnables()
//{
//	return myROIEnables
//}

// create 2 rois, including the default digiscan parameter taggroup
object myROI1 = ROIFactory(0,"test1")
myROI1.print()

object myROI2 = ROIFactory(0,"test2")
myROI2.print()

// add these rois and print them all
returnROIManager().addROI(myROI1)
returnROIManager().addROI(myROI2)
returnROIManager().printAll()

// getting coord by name, old, no longer used
//object myROI3 = returnROIManager().getROIAsObject("test1")
//myROI3.print()

// getting coord by name, new
object myROI 
returnROIManager().getROIAsObject("test1", myROI)
myROI.print()

result("brightness enabled: "+returnROIEnables().brightness()+"\n")
result("contrast enabled: "+returnROIEnables().contrast()+"\n")

// deleting tag with name "test2"
returnROIManager().delROI("test2")

myROI.returnAsTag().taggroupopenbrowserwindow(0)

//taggroup dstag = myROI.getDigiscanParam()
//dstag.taggroupopenbrowserwindow(0)

