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
			self.do_actual()
			if(!self.postcheck())
			{
				self.print("postcheck failed")
				return returncode
			}

			// success
			returncode = 1
		}
		catch
		{
			self.print("exception caught in "+_name+". msg = "+GetExceptionString()+". executing final and aborting")
			self.final()
			//break so that flow continues
		
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

class imageSequence: deviceSequence
{

}

class millingSequence: deviceSequence
{

}






