
class pauseVar:object
{
	number i

	void pauseVar(object self)
	{
		i = 0
	}

	void set(object self, number ii)
	{
		i = ii
	}

	number get(object self)
	{	
		return i
	}

}

object myPauseVar = alloc(pauseVar)

object returnPauseVar()
{
	return myPauseVar
}



string IPrep_getstatus()
{
return "test"

}


Number IPrep_MoveToPECS()
{
	result("IPrep_MoveToPECS\n")
	sleep(5)
	return 1
	
}

Number IPrep_MoveToSEM()
{
	result("IPrep_MoveToSEM\n")
	sleep(5)
	return 1
}

Number IPrep_StartRun()
{
	returnPauseVar().set(0)
	result("IPrep_StartRun\n")
	return 1	
}

Number IPrep_PauseRun()
{
	returnPauseVar().set(1)
	result("IPrep_PauseRun\n")
	return 1	
}

Number IPrep_ResumeRun()
{
	result("IPrep_ResumeRun\n")
	return 1
}

Number IPrep_StopRun()
{
	result("IPrep_StopRun\n")
	return 1
}

Number IPrep_Image()
{
	number i
/*	while (1)
	{
		sleep(1)
		result("looping, i= "+i+"\n")
		i++
	
		if (returnPauseVar().get())
		{
			result("pause called, aborting loop\n")
			break
		}
	
	
		if (optiondown() && shiftdown())
		{	
			result("aborted, break called\n")
			break
		}
	}
*/	//result("IPrep_Image\n")
	//sleep(5)
	return 1	
}

Number IPrep_Mill()
{
	result("IPrep_Mill\n")
	sleep(5)
	return 1		
}

Number IPrep_IncrementSliceNumber()
{
	result("IPrep_IncrementSliceNumber\n")
	sleep(5)
	return 1		
}

Number IPrep_End_Imaging()
{
	result("IPrep_End_Imaging\n")
	return 1	
}








