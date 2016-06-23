// $BACKGROUND$

// this defines a transfer sequence: a series of moves by different subsystems. it will have a pre-check and a post-check and a do method. 


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

	void init(object self, string name, object myTransfer)
	{
		// public
		// initialize with the transfer object
		_name = name
		_skeleton = 0
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

		try
		{

			// lockout PECS UI
			myPecs.lockout()

			// lower pecs stage
			myPecs.moveStageDown()
			
			// home pecs stage
			myPecs.stageHome()
		
			// go to where gripper arms can safely open
			myTransfer.move("open_pecs")

			// open gripper arms
			myGripper.open()

			// move forward to where sample can be picked up
			myTransfer.move("pickup_pecs")

			continueCheck()

			// close gripper arms
			myGripper.close()

			// move to before gv
			myTransfer.move("beforeGV")

			continueCheck()

			// TEMP TESTING: home pecs stage
			// home pecs stage
			myPecs.stageHome()

			// slide sample into dovetail
			myTransfer.move("dropoff_pecs")

			// back off 1 mm to relax tension on springs
			myTransfer.move("dropoff_pecs_backoff")

			continueCheck()

			// open gripper arms
			myGripper.open()
		
			continueCheck()

			// move gripper back so that arms can close
			myTransfer.move("open_pecs")
			
			// close gripper arms
			myGripper.close()
			
			// go to prehome
			myTransfer.move("prehome")

			// move gripper out of the way by homing
			myTransfer.home()

			// turn transfer system off
			//myTransfer.turnOff()

			// unlock
			myPecs.unlock()
		}

		return 1
	}

	number undo(object self)
	{
		// public
		// this method is intended to undo the sequence (if possible)
		self.print("cannot undo this sequence")
		return 1
	}


}


