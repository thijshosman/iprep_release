// $BACKGROUND$

// this defines a transfer sequence: a series of moves by different subsystems. it will have a pre-check and a post-check and a do method. 


class transferSequence: object
{
	string _name
	string _skeleton

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

	void init(object self, string name, object myTransfer)
	{
		// public
		// initialize with the transfer object
		_name = name
		_skeleton = 1
		self.print("name regsitered as "+ _name)
	}

	number registered(object self)
	{
		// return _skeleton, 1 if this class (ABS) is registered, 0 for real implementations
		return _skeleton
	}

	number precheck(object self)
	{
		// public
		// checks that have to be  in order for this sequence to be allowed to run
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		return 1
	}

	number do(object self)
	{
		// public
		// performs actual transfer
		// returns 1 when succesful, 0 when it fails
		return 1
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		return 1
	}


}


class reseatSequenceDefault: object
{
	string _name
	string _skeleton

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

	void init(object self, string name, object myWorkflow1)
	{
		// public
		// initialize with the transfer object
		_name = name
		_skeleton = 0
		myWorkflow = myTransfer1
		self.print("name regsitered as "+ _name)
	}

	number registered(object self)
	{
		// return _skeleton, 1 if this class (ABS) is registered, 0 for real implementations
		return _skeleton
	}

	number precheck(object self)
	{
		// public
		// checks that have to be  in order for this sequence to be allowed to run
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		return 1
	}

	number do(object self)
	{
		// public
		// performs actual transfer
		// returns 1 when succesful, 0 when it fails
		
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


}

class semtopecsSequenceDefault: object
{
	string _name
	string _skeleton

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

	void init(object self, string name, object myWorkflow1)
	{
		// public
		// initialize with the transfer object
		_name = name
		_skeleton = 0
		myWorkflow = myTransfer1
		self.print("name regsitered as "+ _name)
	}

	number registered(object self)
	{
		// return _skeleton, 1 if this class (ABS) is registered, 0 for real implementations
		return _skeleton
	}

	number precheck(object self)
	{
		// public
		// checks that have to be  in order for this sequence to be allowed to run
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		return 1
	}

	number do(object self)
	{
		// public
		// performs actual transfer
		// returns 1 when succesful, 0 when it fails

		// this method is part of speed improvements in the workflow. we try to get the sample as fast
		// between the two points as a synchronous workflow allows. 

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


}

class pecstosemSequenceDefault: object
{
	string _name
	string _skeleton

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

	void init(object self, string name, object myWorkflow1)
	{
		// public
		// initialize with the transfer object
		_name = name
		_skeleton = 0
		myWorkflow = myTransfer1
		self.print("name regsitered as "+ _name)
	}

	number registered(object self)
	{
		// return _skeleton, 1 if this class (ABS) is registered, 0 for real implementations
		return _skeleton
	}

	number precheck(object self)
	{
		// public
		// checks that have to be  in order for this sequence to be allowed to run
		return 1
	}

	number postcheck(object self)
	{
		// public
		// checks that have to be performed after sequence has completed
		return 1
	}

	number do(object self)
	{
		// public
		// performs actual transfer
		// returns 1 when succesful, 0 when it fails

		// this method is part of speed improvements in the workflow. we try to get the sample as fast
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
		myWorkflow.returnTransfer.move("open_pecs")

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
	
		// parker move back to prehome
		myWorkflow.returnTransfer().move("prehome")

		// parker home and turn off to prevent singing
		myWorkflow.returnTransfer().home()

		// close gate valve
		myWorkflow.returnPecs().closeGVandCheck()

		// turn gas flow back on
		myWorkflow.returnPecs().restoreArgonFlow()

		// SEM stage move to clear position
		myWorkflow.returnSEM().goToClear()

		// move SEM dock down to clamp
		myWorkflow.returnSEMdock().clamp()

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


}

