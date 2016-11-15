// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

// get an ROI
//object myROI 
//returnROIManager().getROIAsObject("test1", myROI)
//myROI.print()

// create a ROI
string name = "aTestROI2"
object myROI = ROIFactory(0,name)
myROI.print()

// return a ROI from manager, either as tag or as object
taggroup subtag
//subtag = myROI.returnAsTag()
returnROIManager().getROIAsTag("test1",subtag) // as taggroup
returnROIManager().getROIAsObject("test1",myROI) // as ROI object

//result(myROI.getName()+", order="+myROI.getOrder()+", mag="+myROI.getMag()+", image size=("+myROI.getDigiscanX()+","+myROI.getDigiscanY()+")\n")

// digiscan parameters
subtag = myROI.getDigiscanParam()
number x
TagGroupGetTagAsNumber( subtag,"Image Width", x)
debug(x+"\n")
result(GetTagStringFromSubtag("Signal 0:Selected",subtag))
result(GetTagStringFromSubtag("Signal 1:Selected",subtag))

if (GetTagStringFromSubtag("Signal 0:Selected",subtag) == "true")
	debug("yes")

subtag.taggroupopenbrowserwindow(0)

//object p
//returnROIManager().getROIAsObject("yo",p)

//myROI.initROIFromTag(subtag)

//myROI.setOrder(2)

// add it (overwrite if it isnt there)
//returnROIManager().addROI(myROI) 
//myROI.print()

//myROI = ROIFactory(0,"aTestROI4")
//myROI.setOrder(4)
//returnROIManager().addROI(myROI)
//myROI.print()

//myROI = ROIFactory(0,"aTestROI3")
//myROI.setOrder(3)
//returnROIManager().addROI(myROI)
//myROI.print()

// return as object list
//object list = returnROIManager().getROIObjectList()

// or enabled list
object list = returnROIManager().getAllEnabledROIList()

// print each ROI
//foreach(object item; list)
//{
//	item.print()
//	result("order: "+item.getOrder()+"\n")
//	taggroup dsp = item.getDigiscanParam()
//	dsp.taggroupopenbrowserwindow(0)
//}

// check that tag exists
//if (!returnROIManager().checkROIExistence("aTestROI2"))
//	okdialog("not found")



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
