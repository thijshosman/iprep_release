// $BACKGROUND$

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
		self.print(name+" initialized")
	}

	number final(object self)
	{
		// public, inheritable
		// this method always gets executed afterwards if:
		// -precheck fails (ie returns 0)
		// -postcheck fails (ie returns 0)
		// -an exception is caught by do_actual
		self.print("base method 'final' called")
		return 1
	}

	number precheck(object self)
	{
		// public, inheritable
		// checks that have to be  in order for this sequence to be allowed to run, or things that have to be executed pre do()
		// otherwise, goes directly to final. 
		// NB: only check state of subsystems, not states controlled by higher level controls (ie mystatemachine)
		self.print("base method 'precheck' called")
		return 1
	}

	number postcheck(object self)
	{
		// public, inheritable
		// checks that have to be performed after sequence has completed, or code that will be executed after do()
		// gets executed after sequence (but only if do_actual() succeeds (ie returns 1))
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
			// break //so that flow continues
			return 0
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

		// stop milling if milling
		myWorkflow.returnPecs().stopMilling()

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

		//if (okcanceldialog("paused. press ok to continue"))
		//{
		//	return 1
		//}

		// open and close again to make sure it is actually closed
		// (2016-08-24)
		//myWorkflow.returnGripper().open()
		//myWorkflow.returnGripper().close()

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

		// stop milling if milling
		myWorkflow.returnPecs().stopMilling()

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
		//if (myWorkflow.returnGripper().getState() != "closed")
		//{
		//	myWorkflow.returnGripper().close()
		//}		

		// open and close again to make sure it is actually closed
		// (2016-08-24)
		//myWorkflow.returnGripper().open()
		//myWorkflow.returnGripper().close()

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

		// stop milling if milling
		myWorkflow.returnPecs().stopMilling()

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
		//if (myWorkflow.returnGripper().getState() != "closed")
		//{
		//	myWorkflow.returnGripper().close()
		//}

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

		// parker home 
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

class image_current_settings: deviceSequence
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

		self.print("executing test image step using current settings")
		
		// *** imaging ***

		image temp_slice_im0, temp_slice_im1
		
		// digiscan

		// use digiscan parameters as setup in the normal 'capture' at this moment
		
		myWorkflow.returnDigiscan().config(temp_slice_im0,temp_slice_im1)

		// get digiscan control
		myWorkflow.returnDigiscan().getControl()

		// unblank
		myWorkflow.returnSEM().blankOff()

		myWorkflow.returnDigiscan().acquire()

			
		if (myWorkflow.returnDigiscan().getConfigured0())
		{
			// add tags
			//TagGroup tg = temp_slice_im0.ImageGetTagGroup()
			//tg.addTag("IPrep:focus",myWorkflow.returnSEM().measureWD())
			temp_slice_im0.saveDefaultTags()

			// Save Digiscan image 0
			IPrep_saveSEMImage(temp_slice_im0, "digiscan "+myWorkflow.returnDigiscan().getName0(), myWorkflow.returnDigiscan().getName0())
			
			// Close Digiscan image
			ImageDocument imdoc0 = ImageGetOrCreateImageDocument(temp_slice_im0)
			imdoc0.ImageDocumentClose(0)


		}

		if (myWorkflow.returnDigiscan().getConfigured1())
		{
			// add tags
			//TagGroup tg = temp_slice_im1.ImageGetTagGroup()
			//tg.addTag("IPrep:focus",myWorkflow.returnSEM().measureWD())
			temp_slice_im1.saveDefaultTags()

			// Save Digiscan image 1
			IPrep_saveSEMImage(temp_slice_im1, "digiscan "+myWorkflow.returnDigiscan().getName1(), myWorkflow.returnDigiscan().getName1())
			
			// Close Digiscan image
			ImageDocument imdoc1 = ImageGetOrCreateImageDocument(temp_slice_im1)
			imdoc1.ImageDocumentClose(0)

						

			// blank
			myWorkflow.returnSEM().blankOn()

			// get digiscan control (if needed, no real need to ever automatically release control until done)
			//myWorkflow.returnDigiscan().releaseControl()
		}

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
		// blank beam
		myWorkflow.returnSEM().blankOn()
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
		returnVolumeManager().initForDefaultROI()
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

		self.print("executing single ROI default imaging step")

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
		
		// temp, show the ROI
		myROI.print()

		// fix magnificationbug on Quanta (not needed since already fixed in SEM class)
		//WorkaroundQuantaMagBug()

		// *** focus before imaging ***

		if (myROI.getAFMode() == 1) //autofocus on every nth slice
		{
			if (myROI.getAFBefore() == 1 && IPrep_sliceNumber() % myROI.getAFnSlice() == 0 )
			{
				IPrep_autofocus_complete()
			}
		}
		else if (myROI.getAFMode() == 2) // no autofocus, use stored value
		{
			self.print("IMAGE: focus is: "+myROI.getFocus()+", setting focus to this value")
			myWorkflow.returnSEM().setDesiredWD(myROI.getFocus()) // automatically sets it after storing it in object
		}

		// *** imaging ***

		if (myROI.getImageOn() == 1 && IPrep_sliceNumber() % myROI.getImagenSlice() == 0 )
		{
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
				myWorkflow.returnSEM().setMag(myROI.getMag())
			}

			// Acquire Digiscan image, use digiscan parameters saved in ROI
			
			//taggroup dsp = myROI.getDigiscanParam()

			image temp_slice_im0, temp_slice_im1
			
			// digiscan

			// can set digiscan parameter taggroup from this ROI to overwrite 'capture' settings
			//myWorkflow.returnDigiscan().config(dsp,temp_slice_im0,temp_slice_im1)
			// or use digiscan parameters as setup in the normal 'capture' at this moment
			
			myWorkflow.returnDigiscan().config(temp_slice_im0,temp_slice_im1)

			// get digiscan control
			myWorkflow.returnDigiscan().getControl()

			// unblank
			myWorkflow.returnSEM().blankOff()

			myWorkflow.returnDigiscan().acquire()

			// Verify SEM is functioning properly - pause acquisition otherwise (might be better to do before AFS with a test scan, easier here)
			// if tag exists
			number pixel_threshold = 500
			string tagname = "IPrep:SEM:Emission check threshold"
			if(GetPersistentNumberNote( tagname, pixel_threshold ))
			{
				number avg
				// use the image that is just acuired, 0 by default
				if (myWorkflow.returnDigiscan().getConfigured0())
				{
					avg = average( temp_slice_im0 )
				}
				else
				{
					avg = average( temp_slice_im1 )
				}

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
			
			if (myWorkflow.returnDigiscan().getConfigured0())
			{
				// Save Digiscan image 0
				temp_slice_im0.saveDefaultTags(myROI)
				IPrep_saveSEMImage(temp_slice_im0, "digiscan "+myWorkflow.returnDigiscan().getName0(), myWorkflow.returnDigiscan().getName0())
				
				// Close Digiscan image
				ImageDocument imdoc0 = ImageGetOrCreateImageDocument(temp_slice_im0)
				imdoc0.ImageDocumentClose(0)

				// add image to 3D volume and update, quietly ignore if stack is not initialized
				try
				{
					if (myworkflow.returnDigiscan().numberOfSignals() == 2) // 2 signals, so add signal name
					{
						object my3DvolumeSEM = returnVolumeManager().returnVolume("StoredImaging_"+myWorkflow.returnDigiscan().getName0())
						my3DvolumeSEM.addSlice(temp_slice_im0)
						my3DvolumeSEM.show()
					}
					else
					{
						object my3DvolumeSEM = returnVolumeManager().returnVolume("StoredImaging")
						my3DvolumeSEM.addSlice(temp_slice_im0)
						my3DvolumeSEM.show()
					}
				}
				catch
				{
					self.print("ignoring 3D volume stack")
					break
				}

			}

			if (myWorkflow.returnDigiscan().getConfigured1())
			{

				// Save Digiscan image 1
				temp_slice_im1.saveDefaultTags(myROI)
				IPrep_saveSEMImage(temp_slice_im1, "digiscan "+myWorkflow.returnDigiscan().getName1(), myWorkflow.returnDigiscan().getName1())
				
				// Close Digiscan image
				ImageDocument imdoc1 = ImageGetOrCreateImageDocument(temp_slice_im1)
				imdoc1.ImageDocumentClose(0)

				// add image to 3D volume and update, quietly ignore if stack is not initialized
				try
				{
					if (myworkflow.returnDigiscan().numberOfSignals() == 2) // 2 signals, so add signal name
					{
						object my3DvolumeSEM = returnVolumeManager().returnVolume("StoredImaging_"+myWorkflow.returnDigiscan().getName1())
						my3DvolumeSEM.addSlice(temp_slice_im1)
						my3DvolumeSEM.show()
					}
					else
					{
						object my3DvolumeSEM = returnVolumeManager().returnVolume("StoredImaging")
						my3DvolumeSEM.addSlice(temp_slice_im1)
						my3DvolumeSEM.show()
					}
				}
				catch
				{
					self.print("ignoring 3D volume stack")
					break
				}

			}

			// blank
			myWorkflow.returnSEM().blankOn()

			// get digiscan control (if needed, no real need to ever automatically release control until done)
			//myWorkflow.returnDigiscan().releaseControl()
		}

		// *** autofocus after imaging ****

		if (myROI.getAFMode() == 1) //autofocus on every nth slice
		{
			if (myROI.getAFBefore() == 0 && IPrep_sliceNumber() % myROI.getAFnSlice() == 0 )
			{
				IPrep_autofocus_complete()
			}
		}

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
		// blank beam
		myWorkflow.returnSEM().blankOn()
		return 1
	}
}

class image_iter: deviceSequence
{
	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
		returnVolumeManager().initForAllROIsAndSignals()
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
		// runs through all ROIs that have the 'enabled' subtag set to 1 in ascending order of "order" subtag
		number returncode = 0

		// *** general

		// *** go through ROIs
		object tall_enabled = returnROIManager().getAllEnabledROIList()
		number count = tall_enabled.SizeOfList()

		self.print("found "+count+"positions. visiting them sequentially")

		foreach(object myROI; tall_enabled)
		{
			self.print("IMAGE: ROI: "+myROI.getName())
			// go to ROIs SEM coord, but only if we are not already there
			if (myWorkflow.returnSEM().getCurrentImagingPosition() == myROI.getCoordName())
			{
				// already there
				self.print("IMAGE: already at "+myROI.getCoordName()+", leaving stage where it is")
			}
			else
			{
				// go there
				self.print("IMAGE: going to location: "+myROI.getCoordName()+" belong to ROI "+myROI.getName())
				myWorkflow.returnSEM().goToImagingPosition(myROI.getCoordName())
			}

			// temp, show the ROI
			myROI.print()

			// fix magnificationbug on Quanta (not needed since already fixed in SEM class)
			//WorkaroundQuantaMagBug()

			// *** focus before imaging ***

			if (myROI.getAFMode() == 1) //autofocus on every nth slice
			{
				if (myROI.getAFBefore() == 1 && IPrep_sliceNumber() % myROI.getAFnSlice() == 0 )
				{
					IPrep_autofocus_complete()
				}
			}
			else if (myROI.getAFMode() == 2) // no autofocus, use stored value
			{
				self.print("IMAGE: focus is: "+myROI.getFocus()+", setting focus to this value")
				myWorkflow.returnSEM().setDesiredWD(myROI.getFocus()) // automatically sets it after storing it in object
			}

			// *** imaging ***

			if (myROI.getImageOn() == 1 && IPrep_sliceNumber() % myROI.getImagenSlice() == 0 )
			{
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
					myWorkflow.returnSEM().setMag(myROI.getMag())
				}

				// Acquire Digiscan image, use digiscan parameters saved in ROI
				
				taggroup dsp = myROI.getDigiscanParam()

				image temp_slice_im0, temp_slice_im1
				
				// digiscan

				// can set digiscan parameter taggroup from this ROI to overwrite 'capture' settings
				myWorkflow.returnDigiscan().config(dsp,temp_slice_im0,temp_slice_im1)
				// or use digiscan parameters as setup in the normal 'capture' at this moment
				
				//myWorkflow.returnDigiscan().config(temp_slice_im0,temp_slice_im1)

				// get digiscan control
				myWorkflow.returnDigiscan().getControl()

				// unblank
				myWorkflow.returnSEM().blankOff()

				myWorkflow.returnDigiscan().acquire()

				// Verify SEM is functioning properly - pause acquisition otherwise (might be better to do before AFS with a test scan, easier here)
				// if tag exists
				number pixel_threshold = 500
				string tagname = "IPrep:SEM:Emission check threshold"
				if(GetPersistentNumberNote( tagname, pixel_threshold ))
				{
					number avg
					// use the image that is just acuired, 0 by default
					if (myWorkflow.returnDigiscan().getConfigured0())
					{
						avg = average( temp_slice_im0 )
					}
					else
					{
						avg = average( temp_slice_im1 )
					}

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
				
				if (myWorkflow.returnDigiscan().getConfigured0())
				{
					// Save Digiscan image 0
					temp_slice_im0.saveDefaultTags(myROI)
					// #todo: this is not pretty, but we need a way of continuing a run with using StoredImaging as a regular enabled ROI
										
					if (myROI.getName() == "StoredImaging")
						IPrep_saveSEMImage(temp_slice_im0, "digiscan "+myWorkflow.returnDigiscan().getName0(), myWorkflow.returnDigiscan().getName0())
					else
						IPrep_saveSEMImage(temp_slice_im0, "digiscan "+myROI.getName()+" "+myWorkflow.returnDigiscan().getName0(), myROI.getName()+"_"+myWorkflow.returnDigiscan().getName0())
					
					
					// Close Digiscan image
					ImageDocument imdoc0 = ImageGetOrCreateImageDocument(temp_slice_im0)
					imdoc0.ImageDocumentClose(0)

					// add image to 3D volume and update, quietly ignore if stack is not initialized
					try
					{
						if (myworkflow.returnDigiscan().numberOfSignals() == 2) // 2 signals, so add signal name
						{
							object my3DvolumeSEM = returnVolumeManager().returnVolume(myROI.getName()+"_"+myWorkflow.returnDigiscan().getName0())
							my3DvolumeSEM.addSlice(temp_slice_im0)
							my3DvolumeSEM.show()
						}
						else
						{
							object my3DvolumeSEM = returnVolumeManager().returnVolume(myROI.getName())
							my3DvolumeSEM.addSlice(temp_slice_im0)
							my3DvolumeSEM.show()
						}
					}
					catch
					{
						self.print("ignoring 3D volume stack")
						break
					}

				}

				if (myWorkflow.returnDigiscan().getConfigured1())
				{

					// Save Digiscan image 1
					temp_slice_im1.saveDefaultTags(myROI)
					// #todo: this is not pretty, but we need a way of continuing a run with using StoredImaging as a regular enabled ROI
					
					if (myROI.getName() == "StoredImaging")
						IPrep_saveSEMImage(temp_slice_im1, "digiscan "+myWorkflow.returnDigiscan().getName1(), myWorkflow.returnDigiscan().getName1())
					else
						IPrep_saveSEMImage(temp_slice_im1, "digiscan "+myROI.getName()+" "+myWorkflow.returnDigiscan().getName1(), myROI.getName()+"_"+myWorkflow.returnDigiscan().getName1())
					
					// Close Digiscan image
					ImageDocument imdoc1 = ImageGetOrCreateImageDocument(temp_slice_im1)
					imdoc1.ImageDocumentClose(0)

					// add image to 3D volume and update, quietly ignore if stack is not initialized
					try
					{
						if (myworkflow.returnDigiscan().numberOfSignals() == 2) // 2 signals, so add signal name
						{
							object my3DvolumeSEM = returnVolumeManager().returnVolume(myROI.getName()+"_"+myWorkflow.returnDigiscan().getName1())
							my3DvolumeSEM.addSlice(temp_slice_im1)
							my3DvolumeSEM.show()
						}
						else
						{
							object my3DvolumeSEM = returnVolumeManager().returnVolume(myROI.getName())
							my3DvolumeSEM.addSlice(temp_slice_im1)
							my3DvolumeSEM.show()
						}
					}
					catch
					{
						self.print("ignoring 3D volume stack")
						break
					}

				}

				// blank
				myWorkflow.returnSEM().blankOn()

				// get digiscan control (if needed, no real need to ever automatically release control until done)
				//myWorkflow.returnDigiscan().releaseControl()
			}

			// *** autofocus after imaging ****

			if (myROI.getAFMode() == 1) //autofocus on every nth slice
			{
				if (myROI.getAFBefore() == 0 && IPrep_sliceNumber() % myROI.getAFnSlice() == 0 )
				{
					IPrep_autofocus_complete()
				}
			}

		}
				
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
		// for ebsd step, we do blanking/uncoupling in postcheck
		
		// blank
		myWorkflow.returnSEM().blankOn()

		// decouple FWD (in case oxford instruments coupled it)
		myWorkflow.returnSEM().uncoupleFWD()

		return 1
	}

	number do_actual(object self)
	{
		// public

		number returncode = 0

		string tagname


		// timeout
		number timeout
		tagname = "IPrep:EBSD:timeout"
		if(!GetPersistentNumberNote( tagname, timeout ))
		{
			throw("EBSD timeout (IPrep:EBSD:timeout) not set")
		}


		self.print("EBSD starting. press option and shift to abort")

		// init EBSD system with correct site, prefix for dataname and type
		string sitename
		string data_prefix
		number type
		number mag
		string coordname

		// sitename
		tagname = "IPrep:EBSD:sitename"
		if(!getpersistentstringnote( tagname, sitename ))
		{
			throw("EBSD sitename (IPrep:EBSD:sitename) not set")
		}

		// data_prefix
		tagname = "IPrep:EBSD:data_prefix"
		if(!getpersistentstringnote( tagname, data_prefix ))
		{
			throw("EBSD data_prefix (IPrep:EBSD:data_prefix not set")
		}

		// type
		tagname = "IPrep:EBSD:type"
		if(!GetPersistentNumberNote( tagname, type ))
		{
			throw("EBSD type (IPrep:EBSD:type) not set")
		}

		// mag
		tagname = "IPrep:EBSD:mag"
		if(!GetPersistentNumberNote( tagname, mag ))
		{
			throw("EBSD mag (IPrep:EBSD:mag) not set")
		}

		// SEM coordname
		tagname = "IPrep:EBSD:semcoord"
		if(!getpersistentstringnote( tagname, coordname ))
		{
			throw("EBSD SEM coord (IPrep:EBSD:semcoord not set")
		}		

		// set magnification
		self.print("EBSD: magnification is: "+mag)
		myWorkflow.returnSEM().setMag(mag)


		// go to sem coord
		self.print("coordname for EBSD: "+coordname)
		// go to ROIs SEM coord, but only if we are not already there
		if (myWorkflow.returnSEM().getCurrentImagingPosition() == coordname)
		{
			// already there
			self.print("EBSD: already at "+coordname+", leaving stage where it is")
		}
		else
		{
			// go there
			self.print("EBSD: going to location: "+coordname)
			myWorkflow.returnSEM().goToImagingPosition(coordname)
		}

		// setup EBSD interface
		myWorkflow.returnEBSD().init(sitename, data_prefix, type)

		// release digiscan control, just in case it is still set
		myWorkflow.returnDigiscan().releaseControl()

		// unblank
		myWorkflow.returnSEM().blankOff()

		// start
		myWorkflow.returnEBSD().EBSD_start()

		sleep(1)

		number busy = 1
		number abort = 0
		number err_flag = 0

		try
		{

			number tick = GetOSTickCount()
			number tock = 0

			while (busy == 1 && abort == 0)
			{
				tock = GetOSTickCount()
				self.print("EBSD running, progress = "+myWorkflow.returnEBSD().returnProgress()+", error code = "+myWorkflow.returnEBSD().returnError())
				
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

					
				}
				
				if ((optiondown() && shiftdown()))
				{
					self.print("EBSD aborted by user")

					if (okcanceldialog("EBSD acquisition aborted by user, continue workflow?"))
					{
						// continue workflow
						returncode = 1
						//self.print("ok")
					}
					else
					{
						// abort workflow
						returncode = 0
						//self.print("canceled")
					}
					self.print("debug: returncode after abort: "+ returncode)
					abort = 1
				}

				sleep(1)
				busy = myWorkflow.returnEBSD().isBusy()
			}

			// finished acquisition loop, send an extra stop just in case
			myWorkflow.returnEBSD().EBSD_stop()

			// check for errors in communication or other unusual behavior
			if (myWorkflow.returnEBSD().returnError() == 1 || myWorkflow.returnEBSD().returnError() == 2)
			{
				if (okcanceldialog("Error duing EBSD acquisition. continue workflow? "))
				{
					// continue
					returncode = 1
				}
				else
				{
					// abort
					returncode = 0
				}
				self.print("debug: returncode after err: "+ returncode)
				err_flag = 1

			}

		}
		catch
		{
			print("exception in EBSD sequence: "+GetExceptionString()+", last error code is "+myWorkflow.returnEBSD().returnError())
			myWorkflow.returnEBSD().EBSD_stop()
			return 0
		}
		

		if (abort != 1 && err_flag != 1) // success, no abort or errors
		{
			returncode = 1 // to indicate that even though we had an issue, we still want to continue
		}

		self.print("debug: returncode: "+ returncode)
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

		// raise the stage just in case (temp fix)
		// #TODO: when all bugs in switching etch/coat mode have changed, this step becomes superfluous
		myWorkflow.returnPecs().moveStageUp()

		// go to etch mode (which should include raising stage)
		myWorkflow.returnPecs().goToEtchMode()

		string tagname = "IPrep:PECS:milling timeout"
		number timeout
		if(!GetPersistentNumberNote( tagname, timeout ))
		{
			throw("PECS milling timeout not set")
		}

		self.print("Milling started. press option and shift to abort")

		myWorkflow.returnPecs().startMilling()

		number tick = GetOSTickCount()
		number tock = 0

		while (myWorkflow.returnPECS().getMillingStatus() == 1)
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

			self.print("milling time remaining: "+myWorkflow.returnPecs().millingTimeRemaining())
			sleep(2)
			
		}
		returncode = 1

		myWorkflow.returnPecs().lockout()
		//self.print("debug: returncode: "+returncode)
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

		string tagname = "IPrep:PECS:coating timeout"
		number timeout
		if(!GetPersistentNumberNote( tagname, timeout ))
		{
			throw("PECS milling timeout not set")
		}

		self.print("coating started. press option and shift to abort")

		myWorkflow.returnPecs().startCoating()

		number tick = GetOSTickCount()
		number tock = 0

		number status1 = 1
		string status2 = "1"

		//while (myWorkflow.returnPECS().getMillingStatus() != 0)
		while (status2 != "0")
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

			self.print("coating time remaining: "+myWorkflow.returnPecs().coatingTimeRemaining())
			status1 = myWorkflow.returnPECS().getMillingStatus()
			status2 = myWorkflow.returnPECS().getSystemStatus()
			debug("coating status1: "+status1+", status2: "+status2+"\n")
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

class PECSImageDefault: deviceSequence
{
	// declare object since it is used below
	object myWorkflow

	number init(object self, string name1, object workflow1)
	{
		self.setname(name1)
		myWorkflow = workflow1
		returnVolumeManager().initForPECS(self.name())

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
		// take image and save it in pecs dir

		// raise stage to bring sample in focus
		myWorkflow.returnPecs().moveStageUp()

		// turn on illuminator
		myWorkflow.returnPecs().ilumOn()
		
		image temp_slice_im

		// acquire
		myWorkflow.returnPECSCamera().acquire(temp_slice_im)

		// turn off illuminator
		myWorkflow.returnPecs().ilumOff()
		
		// save image
		IPrep_savePECSImage(temp_slice_im, self.name())

		// if something happens during DM handling of the image, quietly ignore it
		try 
		{

			// show image
			//temp_slice_im.showimage() // only show if image is not a null image

			object myPECSvolumeSEM = returnVolumeManager().returnVolume(self.name())
			myPECSvolumeSEM.addSlice(temp_slice_im)
			myPECSvolumeSEM.show()

			// Close image
			ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
			imdoc.ImageDocumentClose(0)
		}
		catch
		{
			self.print("quietly ignoring exception: "+ GetExceptionString())
			break // so that flow continues
		}
		

		//

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




