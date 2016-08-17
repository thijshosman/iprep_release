// $BACKGROUND$

//object myWorkflow = returnWorkflow()
//object myStateMachine = returnStateMachine()
//object myMediator = returnMediator()

// this defines a transfer sequence: a series of moves by different subsystems. it will have a pre-check and a post-check and a do method. 


class deviceSequence: object
{
	// this class acts as the base class for transfer sequences and contains all the logic. 
	// some of these methods are to be inherited by implementations of sequences. these are: 
	// precheck(), postcheck(), do_actual(), undo_actual(), final()

	// timer numbers
	number tick, tock

	string _name

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("sequence "+_name+" ", level, text)
	}

	void print(object self, string str1)
	{
		result("sequence "+_name+": "+str1+"\n")
		self.log(2,str1)
	}

	string name(object self)
	{
		return _name
	}

	void setname(object self, string name)
	{
		// public, static
		// initialize with the transfer object
		_name = name
		self.print("transfer "+name+" initialized")
	}

	number final(object self)
	{
		// public, inheritable
		// this method always gets executed afterwards if something fails
		self.print("base method 'final' called")
		return 1
	}

	number precheck(object self)
	{
		// public, inheritable
		// checks that have to be  in order for this sequence to be allowed to run
		// otherwise, goes directly to final. only check state of subsystems, not states controlled by higher level controls (ie mystatemachine)
		self.print("base method 'precheck' called")
		return 1
	}

	number postcheck(object self)
	{
		// public, inheritable
		// checks that have to be performed after sequence has completed
		// gets executed after sequence
		self.print("base method 'postcheck' called")
		return 1
	}

	number do_actual(object self)
	{
		// public, inheritable
		// must be inherited and populated
		self.print("base method 'do_actual' called")
	}

	number do(object self)
	{
		// public, static
		// performs actual transfer
		// returns 1 when succesful, 0 when it fails
		number returncode = 0

		if (!self.precheck())
		{
			self.print("precheck failed")
			return returncode
		}

		try
		{
			number success = self.do_actual()

			if(success == 0)
			{
				self.print("do_actual returned 0 (failed). running final. ")
				self.final()
				return returncode
			}


			if(!self.postcheck())
			{
				self.print("postcheck failed. running final. ")
				self.final()
				return returncode
			}

			// success
			returncode = 1
		}
		catch
		{
			self.print("exception caught in "+_name+". msg = "+GetExceptionString()+". executing final and aborting")
			self.final()
			break //so that flow continues
		
		}

		return returncode
	}

	number undo(object self)
	{
		// public, inheritable
		// this method is intended to undo the sequence (if possible)
		self.print("base method 'undo' called")
		return 0
	}

}

class skeletonSequence: deviceSequence
{
	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number precheck(object self)
	{
		// public
		// no pre-check needed
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		// in this case there is no post-check needed
		return 1
	}

	number do_actual(object self)
	{
		// public
		
		//myWorkflow.returnPecs().dostuff()

		return 1
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 0
	}

	number final(object self)
	{
		// public
		// not needed in this case
		return 1
	}
}



class testSequence: deviceSequence
{
	// test class that inherits transferSequence

	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number do_actual(object self)
	{
		result("do_actual called from child\n")
		//self.print("")
		//if (optiondown())
		return 1
	}

	number undo(object self)
	{
		// public, inheritable
		// this method is intended to undo the sequence (if possible)
		self.print("undo called from child")
		return 0
	}

}


//object aTestSequence = alloc(testSequence)
//aTestSequence.init("myTest",myWorkflow)
//aTestSequence.do()



class reseatSequenceDefault: deviceSequence
{

	// implementation of transferSequence
	// reseating procedure as of 2016-07-21

	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number precheck(object self)
	{
		// public
		// no pre-check needed
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		// in this case there is no post-check needed
		return 1
	}

	number do_actual(object self)
	{
		// public
		
		// move sample out and into dovetail 
		// use after sample transfer so that it will be in the same position as during transfer


		// lockout PECS UI
		myWorkflow.returnPecs().lockout()

		// lower pecs stage
		myWorkflow.returnPecs().moveStageDown()
		
		// home pecs stage
		myWorkflow.returnPecs().stageHome()
	
		// go to where gripper arms can safely open
		myWorkflow.returnTransfer().move("open_pecs")

		// open gripper arms
		myWorkflow.returnGripper().open()

		// move forward to where sample can be picked up
		myWorkflow.returnTransfer().move("pickup_pecs")

		continueCheck()

		// close gripper arms
		myWorkflow.returnGripper().close()

		// move to before gv
		myWorkflow.returnTransfer().move("beforeGV")

		continueCheck()

		// TEMP TESTING: home pecs stage
		// home pecs stage
		myWorkflow.returnPecs().stageHome()

		// slide sample into dovetail
		myWorkflow.returnTransfer().move("dropoff_pecs")

		// back off 1 mm to relax tension on springs
		myWorkflow.returnTransfer().move("dropoff_pecs_backoff")

		continueCheck()

		// open gripper arms
		myWorkflow.returnGripper().open()
	
		continueCheck()

		// move gripper back so that arms can close
		myWorkflow.returnTransfer().move("open_pecs")
		
		// close gripper arms
		myWorkflow.returnGripper().close()
		
		// close again if not closed all the way (bug 2016-08-12)
		if (myWorkflow.returnGripper().getState() != "closed")
		{
			myWorkflow.returnGripper().close()
		}

		// go to prehome
		myWorkflow.returnTransfer().move("prehome")

		// move gripper out of the way by homing
		myWorkflow.returnTransfer().home()

		// unlock
		myWorkflow.returnPecs().unlock()
		

		return 1
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 0
	}

	number final(object self)
	{
		// public
		// not needed in this case
		return 1
	}

}

class semtopecsSequenceDefault: deviceSequence
{

	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number precheck(object self)
	{
		// public
		// no pre-check needed
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		// in this case there is no post-check needed
		return 1
	}

	number do_actual(object self)
	{
		// public
		// performs actual transfer from SEM to PECS

		// we try to get the sample as fast between the two points as a synchronous workflow allows. 

		// lockout PECS UI
		myWorkflow.returnPecs().lockout()

		// turn off gas flow
		myWorkflow.returnPecs().shutoffArgonFlow()

		// move pecs stage down
		myWorkflow.returnPecs().moveStageDown()

		// home pecs stage
		myWorkflow.returnPecs().stagehome()

		// move SEM stage to clear point
		myWorkflow.returnSEM().goToClear()

		// hold dock in place to make sure it does not move down by itself as a result of spring force overcoming stepper drive
		myWorkflow.returnSEMdock().hold()

		// move SEM dock clamp up to release sample
		myWorkflow.returnSEMdock().unclamp()

		// move SEM stage to pickup point
		myWorkflow.returnSEM().goToPickup_Dropoff()

		// open GV
		myWorkflow.returnPecs().openGVandCheck()

		// move transfer system to location where arms can safely open
		myWorkflow.returnTransfer().move("backoff_sem")

		// gripper open
		myWorkflow.returnGripper().open()

		// move transfer system to pickup point
		myWorkflow.returnTransfer().move("pickup_sem")

		continueCheck()

		// gripper close, sample is picked up
		myWorkflow.returnGripper().close()
		
		// move SEM stage to clear point so that dock is out of the way
		myWorkflow.returnSEM().goToClear()

		if (GetTagValue("IPrep:simulation:samplechecker") == 1)
		{
			// check that sample is no longer present in dock, if simulation of dock is off
			if (myWorkflow.returnSEMdock().checkSamplePresent())
			{
				self.print("sample still detected in dock after pickup")
				throw("sample still detected in dock after pickup")
			}
		}

		// intermediate point as not to trigger the torque limit
		// #TODO: fix unneeded step
		myWorkflow.returnTransfer().move("beforeGV")

		// turn hold off again
		myWorkflow.returnSEMdock().unhold()

		// slide sample into dovetail
		myWorkflow.returnTransfer().move("dropoff_pecs")

		// back off 1 mm to relax tension on springs
		myWorkflow.returnTransfer().move("dropoff_pecs_backoff")

		// open gripper arms
		myWorkflow.returnGripper().open()
	
		// move gripper back so that arms can close
		myWorkflow.returnTransfer().move("open_pecs")
		
		// close gripper arms
		myWorkflow.returnGripper().close()
		
		// close again if not closed all the way (bug 2016-08-12)
		if (myWorkflow.returnGripper().getState() != "closed")
		{
			myWorkflow.returnGripper().close()
		}		

		// go to prehome
		myWorkflow.returnTransfer().move("prehome")

		// move gripper out of the way by homing
		myWorkflow.returnTransfer().home()

		// close GV
		myWorkflow.returnPecs().closeGVandCheck()

		// turn gas flow back on
		myWorkflow.returnPecs().restoreArgonFlow()

		// move SEM dock clamp down to safely move it around inside SEM
		myWorkflow.returnSEMdock().clamp()

		// unlock
		myWorkflow.returnPecs().unlock()

		return 1
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 0
	}

	number final(object self)
	{
		// public
		// restore gas flow
		myWorkflow.returnPecs().restoreArgonFlow()	
		// turn hold off again
		myWorkflow.returnSEMdock().unhold()
		return 1
	}


}

class pecstosemSequenceDefault: deviceSequence
{

	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number precheck(object self)
	{
		// public
		// no pre-check needed
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		// in this case there is no post-check needed
		return 1
	}

	number do_actual(object self)
	{
		// public
		// move the sample from PECS to SEM

		// we try to get the sample as fast
		// between the two points as a synchronous workflow allows. 

		// lockout PECS UI
		myWorkflow.returnPecs().lockout()

		// turn off gas flow
		myWorkflow.returnPecs().shutoffArgonFlow()

		// lower pecs stage
		myWorkflow.returnPecs().moveStageDown()
		
		// home pecs stage
		myWorkflow.returnPecs().stageHome()
	
		// go to where gripper arms can safely open
		myWorkflow.returnTransfer().move("open_pecs")

		// open gripper arms
		myWorkflow.returnGripper().open()

		// move forward to where sample can be picked up
		myWorkflow.returnTransfer().move("pickup_pecs")

		continueCheck()

		// close gripper arms
		myWorkflow.returnGripper().close()

		continueCheck()

		// open GV
		myWorkflow.returnPecs().openGVandCheck()

		// move sem stage to clear point
		myWorkflow.returnSEM().goToClear()

		// hold dock in place to make sure it does not move down by itself as a result of spring force overcoming stepper drive
		myWorkflow.returnSEMdock().hold()
	
		// move SEM dock up to allow sample to go in
		myWorkflow.returnSEMdock().unclamp()

		// move into chamber
		myWorkflow.returnTransfer().move("dropoff_sem")

		continueCheck()

		// SEM Stage to dropoff position
		myWorkflow.returnSEM().goToPickup_Dropoff()

		continueCheck()

		// gripper open to release sample
		myWorkflow.returnGripper().open()

		// parker back off to where arms can open/close
		myWorkflow.returnTransfer().move("backoff_sem")

		// gripper close
		myWorkflow.returnGripper().close()
	
		// close again if not closed all the way (bug 2016-08-12)
		if (myWorkflow.returnGripper().getState() != "closed")
		{
			myWorkflow.returnGripper().close()
		}

		// intermediate point as not to trigger the torque limit
		// #TODO: fix unneeded step
		myWorkflow.returnTransfer().move("beforeGV")

		// SEM stage move to clear position
		myWorkflow.returnSEM().goToClear()

		// turn hold off again
		myWorkflow.returnSEMdock().unhold()

		// move SEM dock down to clamp
		myWorkflow.returnSEMdock().clamp()

		// parker move back to prehome
		myWorkflow.returnTransfer().move("prehome")

		// parker home and turn off to prevent singing
		myWorkflow.returnTransfer().home()

		// close gate valve
		myWorkflow.returnPecs().closeGVandCheck()

		// turn gas flow back on
		myWorkflow.returnPecs().restoreArgonFlow()

		if (GetTagValue("IPrep:simulation:samplechecker") == 1)
		{
			// check that sample is present
			if (!myWorkflow.returnSEMdock().checkSamplePresent())
			{
				self.print("sample not detected in dock after dropoff")
				throw("sample not detected in dock after dropoff")
			}
		}

		// move SEM stage to nominal imaging plane
		myWorkflow.returnSEM().goToNominalImaging()

		// unlock
		myWorkflow.returnPecs().unlock()

		return 1
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 0
	}

	number final(object self)
	{
		// public
		// restore gas flow
		myWorkflow.returnPecs().restoreArgonFlow()	
		// turn hold off again
		myWorkflow.returnSEMdock().unhold()
		return 1
	}


}

class image_single: deviceSequence
{
	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number precheck(object self)
	{
		// public
		// #todo: define prechecks. SEM in right position? 

		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		// in this case there is no post-check needed
		return 1
	}

	number do_actual(object self)
	{
		// public
		// performs single image
		number returncode = 0


		// unblank
		myWorkflow.returnSEM().blankOff()

		// get the ROI (default/StoredImaging in this case)
		object myROI 
		string name1 = "StoredImaging"
		if (!returnROIManager().getROIAsObject(name1, myROI))
		{
			self.print("IMAGE: tag does not exist!")
			return returncode
		}

		// go to ROI1
		self.print("IMAGE: going to location: "+myROI.getName())
		myWorkflow.returnSEM().goToImagingPosition(myROI.getName())
		
		// fix magnificationbug on Quanta
		WorkaroundQuantaMagBug()

		// focus
		if (myROI.getAFMode() == 1) //autofocus on every slice
		{
			self.print("IMAGE: autofocusing")
			IPrep_autofocus()
			number afs_sleep = 1	// seconds of delay
			sleep( afs_sleep )

			number current_focus = myWorkflow.returnSEM().measureWD()	
			number saved_focus = myROI.getFocus()
			number change = current_focus - saved_focus
			self.print("IMAGE: Autofocus changed focus value by "+change+" mm")

		}
		else if (myROI.getAFMode() == 2) // no autofocus, use stored value
		{
			self.print("IMAGE: focus is: "+myROI.getFocus())
			myWorkflow.returnSEM().setDesiredWD(myROI.getFocus()) // automatically sets it after storing it in object
		}

		// brightness
		if(returnROIEnables().brightness())
		{
			self.print("IMAGE: brightness is: "+myROI.getBrightness())
			myROI.getBrightness()
		}

		// contrast
		if(returnROIEnables().contrast())
		{
			self.print("IMAGE: contrast is: "+myROI.getContrast())
			myROI.getContrast()
		}

		// mag
		if(returnROIEnables().mag())
		{
			self.print("IMAGE: magnification is: "+myROI.getMag())
			myROI.getMag()
		}

		// voltage
		if(returnROIEnables().voltage())
		{
			self.print("IMAGE: voltage is: "+myROI.getVoltage())
			myROI.getVoltage()
		}

		// ss
		if(returnROIEnables().ss())
		{
			self.print("IMAGE: spot size is: "+myROI.getss())
			myROI.getss()
		}	

		// stigx
		if(returnROIEnables().stigx())
		{
			self.print("IMAGE: stigmation in X is: "+myROI.getStigx())
			myROI.getStigx()
		}

		// stigy
		if(returnROIEnables().stigy())
		{
			self.print("IMAGE: stigmation in Y is: "+myROI.getStigy())
			myROI.getStigy()
		}

		// Acquire Digiscan image, use digiscan parameters saved in ROI
		
		taggroup dsp = myROI.getDigiscanParam()

		image temp_slice_im
		
		// digiscan

		// can set digiscan parameter taggroup from this ROI to overwrite 'capture' settings
		//myWorkflow.returnDigiscan().config(dsp)
		// or use digiscan parameters as setup in the normal 'capture' at this moment
		myWorkflow.returnDigiscan().config()
		
		// fix magnificationbug on Quanta
		// second time, before imaging
		WorkaroundQuantaMagBug()

		myWorkflow.returnDigiscan().acquire(temp_slice_im)


		
		
		// Verify SEM is functioning properly - pause acquisition otherwise (might be better to do before AFS with a test scan, easier here)
		// if tag exists
		number pixel_threshold = 500
		string tagname = "IPrep:SEM:Emission check threshold"
		if(GetPersistentNumberNote( tagname, pixel_threshold ))
		{
			number avg = average( temp_slice_im )

			if ( avg < pixel_threshold )
			{
				// average image value is less than threshold, assume SEM emission problem, pause acq
				string str = datestamp()+": Average image value ("+avg+") is less than emission check threshold ("+pixel_threshold+")\n"
				self.print(""+ str )
				string str2 = "\nAcquisition has been paused.\n\nCheck SEM is working properly and press <Continue> to resume acquisition, or <Cancel> to stop."
				string str3 = "\n\nNote: Threshold can be set at global tag: IPrep:SEM:Emission check threshold"
				if ( !ContinueCancelDialog( str + str2 +str3 ) )
				{
						str = ": Acquisition terminated by user" 
						self.print("IMAGE: "+str)	
						return returncode	
				}
			}
			else
			{
				self.print("IMAGE: Average image value ("+avg+") is greater than emission check threshold ("+pixel_threshold+"). SEM emission assumed OK." )	
			}

		}
		

		// Save Digiscan image
		IPrep_saveSEMImage(temp_slice_im, "digiscan")

		// Close Digiscan image
		ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
		imdoc.ImageDocumentClose(0)
			
		// add image to 3D volume and update 
		// quietly ignore if stack is not initialized
		try
		{
			object my3DvolumeSEM = myWorkflow.return3DvolumeSEM()
			my3DvolumeSEM.addSlice(temp_slice_im)
			my3DvolumeSEM.show()
		}
		catch
		{
			self.print("ignoring 3D volume stack")
			break
		}

		// blank
		myWorkflow.returnSEM().blankOn()

		return returncode
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 0
	}

	number final(object self)
	{
		// public
		// blank beam
		myWorkflow.returnSEM().blankOn()
		return 1
	}


}

class EBSD_default: deviceSequence
{
	// default EBSD acquisition
	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number precheck(object self)
	{
		// public
		// no pre-check needed
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		// in this case there is no post-check needed
		return 1
	}

	number do_actual(object self)
	{
		// public

		number returncode = 0

		// unblank
		myWorkflow.returnSEM().blankOff()

		number tick = GetOSTickCount()
		number tock = 0

		string tagname = "IPrep:EBSD:timeout"
		number timeout
		if(!GetPersistentNumberNote( tagname, timeout ))
		{
			throw("EBSD timeout not set")
		}

		self.print("EBSD starting. press option and shift to abort")

		myWorkflow.returnEBSD().EBSD_start()

		while (myWorkflow.returnEBSD().isBusy()!=0)
		{
			tock = GetOSTickCount()
			if ((tock-tick)/1000 > timeout)
			{
				self.print("EBSD timeout passed")
				
				if (okcanceldialog("timeout for EBSD acquisition passed, continue workflow?"))
				{
					// continue
					returncode = 1
				}
				else
				{
					// abort
					returncode = 0
				}

				break	
			}
			
			if ((optiondown() && shiftdown()))
			{
				self.print("EBSD aborted")

				if (okcanceldialog("EBSD acquisition aborted, continue workflow?"))
				{
					// continue
					returncode = 1
				}
				else
				{
					// abort
					returncode = 0
				}

				break
			}

			sleep(1)
			
		}



		// blank
		myWorkflow.returnSEM().blankOn()

		// decouple FWD (in case oxford instruments coupled it)
		myWorkflow.returnSEM().uncoupleFWD()

		return 1
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 0
	}

	number final(object self)
	{
		// public
		
		// blank
		myWorkflow.returnSEM().blankOn()

		// decouple FWD (in case oxford instruments coupled it)
		myWorkflow.returnSEM().uncoupleFWD()

		return 1
	}
}

class mill_default: deviceSequence
{
	// default EBSD acquisition
	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number precheck(object self)
	{
		// public
		// no pre-check needed
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		// in this case there is no post-check needed
		return 1
	}

	number do_actual(object self)
	{
		// public

		number returncode = 0

		// go to etch mode (which should include raising stage)
		myWorkflow.returnPecs().goToEtchMode()

		number tick = GetOSTickCount()
		number tock = 0

		string tagname = "IPrep:PECS:milling timeout"
		number timeout
		if(!GetPersistentNumberNote( tagname, timeout ))
		{
			throw("PECS milling timeout not set")
		}

		self.print("Milling started. press option and shift to abort")

		myWorkflow.returnPecs().startMilling()

		while (myWorkflow.returnPECS().getMillingStatus() != 0)
		{
			tock = GetOSTickCount()
			if ((tock-tick)/1000 > timeout)
			{
				self.print("milling timeout passed")
				
				myWorkflow.returnPecs().stopMilling()
				myWorkflow.returnPecs().stageHome()

				if (okcanceldialog("timeout for milling passed, continue workflow?"))
				{
					// continue
					break
				}
				else
				{
					// abort
					return returncode
				}

				break	
			}
			
			if ((optiondown() && shiftdown()))
			{
				self.print("milling aborted")

				myWorkflow.returnPecs().stopMilling()
				myWorkflow.returnPecs().stageHome()

				if (okcanceldialog("milling aborted, continue workflow?"))
				{
					// continue
					break
				}
				else
				{
					// abort
					return returncode
				}

				
			}

			sleep(1)
			
		}
		returncode = 1

		// #TODO
		// take image (PECS)

		myWorkflow.returnPecs().lockout()
		self.print("debug: returncode: "+returncode)
		return returncode
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 0
	}

	number final(object self)
	{
		// public
		
		myWorkflow.returnPecs().lockout()

		return 1
	}
}

class coat_default: deviceSequence
{
	// default EBSD acquisition
	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
	}

	number precheck(object self)
	{
		// public
		// no pre-check needed
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		// in this case there is no post-check needed
		return 1
	}

	number do_actual(object self)
	{
		// public

		number returncode = 0

		// go to etch mode (which should include raising stage)
		myWorkflow.returnPecs().goToCoatMode()

		number tick = GetOSTickCount()
		number tock = 0

		string tagname = "IPrep:PECS:coating timeout"
		number timeout
		if(!GetPersistentNumberNote( tagname, timeout ))
		{
			throw("PECS milling timeout not set")
		}

		self.print("coating started. press option and shift to abort")

		myWorkflow.returnPecs().startCoating()

		while (myWorkflow.returnPECS().getMillingStatus() != 0)
		{
			tock = GetOSTickCount()
			if ((tock-tick)/1000 > timeout)
			{
				self.print("coating timeout passed")
				
				myWorkflow.returnPecs().stopMilling()
				myWorkflow.returnPecs().stageHome()

				if (okcanceldialog("timeout for milling passed, continue workflow?"))
				{
					// continue
					break
				}
				else
				{
					// abort
					return returncode
				}

				break	
			}
			
			if ((optiondown() && shiftdown()))
			{
				self.print("coating aborted")

				myWorkflow.returnPecs().stopMilling()
				myWorkflow.returnPecs().stageHome()

				if (okcanceldialog("coating aborted, continue workflow?"))
				{
					// continue
					break
				}
				else
				{
					// abort
					return returncode
				}

				break
			}

			sleep(1)
			
		}
		returncode = 1
		myWorkflow.returnPecs().lockout()

		return returncode
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 0
	}

	number final(object self)
	{
		// public
		
		myWorkflow.returnPecs().lockout()

		return 1
	}
}






