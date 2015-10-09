// creates hardware instances that are either real or simulated

object createGripper(number simulator)
{
	if(simulator == 1)
		return alloc(gripper_simulator)
	else
		return alloc(gripper)
}

object createDock(number type)
{
	if(type == 1) // simulator
		return alloc(dock_simulator)
	else if (type == 2)
		return alloc(planarSEMdock)
	else if (type == 3)
		return alloc(EBSDSEMdock)
}

object createPecs(number simulator)
{
	if(simulator == 1)
		return alloc(pecs_simulator)
	else
		return alloc(pecs_iprep)
}

object createSem(number simulator)
{
	if(simulator == 1)
		return alloc(SEM_Simulator)
	else
		return alloc(SEM_IPrep)
}

object createTransfer(number simulator)
{
	if(simulator == 1)
		return alloc(parkerTransfer_simulator)
	else
		return alloc(parkerTransfer)
}

object createPecsCamera(number simulator)
{
	if(simulator == 1)
		return alloc(pecsCamera_simulator)
	else
		return alloc(pecsCamera_iprep)
}

object creatDigiscan(number simulator)
{
	if(simulator == 1)
		return alloc(digiscan_simulator)
	else
		return alloc(digiscan_iprep)
}

object createUPS(number simulator)
{
	if(simulator == 1)
		return alloc(UPS_simulator)
	else
		return alloc(UPS_APC)
}


