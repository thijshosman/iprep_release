// $BACKGROUND$
// creates hardware instances that are either real or simulated
// 20170118: now also allows us to create different devices to reflect different hardware at install sites
// parker: 1=simulator, 2=ipa (demo unit), 3=aries (manchester)
// gripper: 1=simulator, 2= rev2 (demo unit), 3= rev1 (as in manchester)
// sem: 1=simulator, 2=quanta (demo unit), 3=nova (manchester)
// pecs: 1=simulator, 2=rev2(demo unit), 3=rev1 (as in manchester)



object createGripper(number simulator)
{
	if(simulator == 1)
		return alloc(gripper_simulator)
	else if (simulator == 2)
		return alloc(gripper_rev2)
	else if (simulator == 3)
		return alloc(gripper_rev1)
	else
		throw("gripper type set to unknown value")
}

object createDock(number type)
{
	if(type == 1) // simulator
		return alloc(dock_simulator)
	else if (type == 2)
		return alloc(planarSEMdock)
	else if (type == 3)
		return alloc(EBSDSEMdock)
	else
		throw("dock type is set to unknown value")
}

object createPecs(number simulator)
{
	if(simulator == 1)
		return alloc(pecs_simulator)
	else if (simulator == 2)
		return alloc(pecs_iprep_rev2)
	else if (simulator == 3)
		return alloc (pecs_iprep_rev1)
	else
		throw("pecs type is set to unknown value")
}

object createSem(number simulator)
{
	if(simulator == 1)
		return alloc(SEM_Simulator)
	else if (simulator == 2)
		return alloc(SEM_IPrep_Quanta)
	else if (simulator == 3)
		return alloc(SEM_IPrep_Nova)
	else
		throw("sem type is set to unknown value")
}

object createTransfer(number simulator)
{
	if(simulator == 1)
		return alloc(parkerTransfer_simulator)
	else if (simulator == 2)
		return alloc(parkerTransfer_IPA)
	else if (simulator == 3)
		return alloc(parkerTransfer_ARIES)
	else
		throw("transfer type is set to unknown value")
}

object createPecsCamera(number simulator)
{
	if(simulator == 1)
		return alloc(pecsCamera_simulator)
	else
		return alloc(pecsCamera_iprep)
}

object createDigiscan(number simulator)
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

object createEBSDHandshake(number simulator)
{
	if(simulator == 3)
		return alloc(EBSD_OI_automatic)
	else if (simulator == 2)
		return alloc(EBSD_manual)
	else if (simulator == 1)
		return alloc(EBSD_simulator)
	else
		throw("ebsd type is set to wrong value, not 1, 2 or 3")
}


