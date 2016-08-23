// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

// get an ROI
//object myROI 
//returnROIManager().getROIAsObject("test1", myROI)
//myROI.print()

// create a ROI and add it (overwrite if it isnt there)
//object myROI2 = ROIFactory(0,"ExtraROI")
//returnROIManager().addROI(myROI2)

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

object multiROIseq = createSequence("image_iter")
multiROIseq.init("image_iter",myWorkflow)

multiROIseq.do_actual()
