// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

// get an ROI
//object myROI 
//returnROIManager().getROIAsObject("test1", myROI)
//myROI.print()

// create a ROI and add it (overwrite if it isnt there)
object myROI = ROIFactory(0,"aTestROI2")
myROI.setOrder(2)
returnROIManager().addROI(myROI)
myROI.print()

myROI = ROIFactory(0,"aTestROI4")
myROI.setOrder(4)
returnROIManager().addROI(myROI)
myROI.print()

myROI = ROIFactory(0,"aTestROI3")
myROI.setOrder(3)
returnROIManager().addROI(myROI)
myROI.print()

// return as object list
//object list = returnROIManager().getROIObjectList()

// or enabled list
object list = returnROIManager().getAllEnabledROIList()

// print each ROI
foreach(object item; list)
{
	item.print()
	result("order: "+item.getOrder()+"\n")
}

// check that tag exists
if (!returnROIManager().checkROIExistence("aTestROI2"))
	okdialog("not found")



// get attributes of ROI
//myROI.getAFMode()

// get ROI that does not exist
//object myROI1 
//returnROIManager().getROIAsObject("testDoesNotExist", myROI1)
//myROI1.print()

// get custom digiscan parameters
//taggroup dsp = myROI.getDigiscanParam()
//dsp.taggroupopenbrowserwindow(0)

//returnROIManager().getAllEnabled().taggroupopenbrowserwindow(0)

//object multiROIseq = createSequence("image_iter")
//multiROIseq.init("image_iter",myWorkflow)

//multiROIseq.do_actual()
