// $BACKGROUND$
class IPrep_3Dvolume: object
{
	// creates and manages IPrep 3D volumes
	// both for digiscan and for pecs

	image iprep_volume
	number slices
	number x,y
	string name

	string getName(object self)
	{
		return name
	}

	image returnVolume(object self)
	{
		return iprep_volume
	}

	void show(object self)
	{
		showimage(iprep_volume)
	}

	void initReal(object self, string name1, number slices1, number x1, number y1)
	{
		// init real image stack
		name = name1
		slices = slices1
		iprep_volume := RealImage(name1, 4, x1,y1,slices1)
		x=x1
		y=y1
	}

	void initColor(object self, string name1, number slices1, number x1, number y1)
	{
		// *** public ***
		// init color image stack

		name = name1
		slices = slices1
		iprep_volume := RGBImage(name1, 4, x1,y1,slices1)
		x=x1
		y=y1
	}
/*
	void init(object self, object ROI, number slices1)
	{
		// init a stack based on the ROI object supplied

		// #todo: why not use something other than real? 
		// #todo: migrate to factory
		name = ROI.getName()+"_stack"
		slices = slices1
		self.initReal(ROI.getName(), slices, ROI.getDigiscanX(), ROI.getDigiscanY())

	}
*/
	// old init methods, now used by factory
/*
	void initSEM_3D(object self,number slices1, number x1, number y1)
	{
		// *** public ***
		// init SEM stack

		slices = slices1
		iprep_volume := RealImage("sem_3D", 4, x1,y1,slices)
		x=x1
		y=y1
	}	

	void initPECS_3D(object self,number slices1)
	{
		// *** public ***
		// init PECS stack
		number x1, y1
		slices = slices1
		iprep_volume := RGBImage("iprep_3D", 4, 2592,1944,slices)
		getsize(iprep_volume,x1,y1)
		x=x1
		y=y1
	}	
*/
	// operations

	void shift(object self)
	{
		//*** private ***
		// removes last slice, shifts 1 to n-1 slices back to free up first slice
		number count
		for (count=slices-1; count>0; count--)
		{
			image cur := slice2(iprep_volume, 0, 0, count, 0, x, 1, 1, y,1)
			image next := slice2(iprep_volume, 0, 0, count-1, 0, x, 1, 1, y,1)
			cur=next
		}
	}

	void addSlice(object self, image &PECSSlice)
	{
		// adds 1 slice to the front of the image, removes the last slice
		self.shift()
		image frontslice := slice2(iprep_volume,0,0,0,0,x,1,1,y,1)
		frontslice = PECSSlice
	}

	// testing
	void as(object self)
	{
		number count
		for (count=0; count<=slices-1; count++)
			{
				image test := slice2(iprep_volume, 0, 0, count, 0, x, 1, 1, y,1)
				test = count*10
			}
	}

	// end testing


}



// *** factories for different 3D volumes
object create3DVolume(string type, string name) // main factory
{
	if(type == "StoredImaging") // standard 3D volume in b/w for SEM images
	{	
		// get StoredImaging ROI, current 'capture' width/height
		object myROI
		returnROIManager().getROIAsObject("StoredImaging", myROI)
		
		// create volume object and populate it with parameters. then return it
		object vol = alloc(IPrep_3Dvolume)
		vol.initReal(name+"_stack", GetTagValue("IPrep:volume slices"), returnWorkflow().returnDigiscan().DSGetWidth(), returnWorkflow().returnDigiscan().DSGetHeight())
		return vol
	}
	else if (type == "PECS_full") // standard 3D volume in color for PECS images at full FOV
	{	
		// create volume object and populate it with parameters. then return it
		object vol = alloc(IPrep_3Dvolume)
		vol.initColor(name+"_stack",GetTagValue("IPrep:volume slices"),2592,1944)
		return vol
	}
	else if (type == "lookup_ROI") // 3D volume with coordinates x,y and name name
	{
		// get StoredImaging ROI, current 'capture' width/height
		object myROI
		returnROIManager().getROIAsObject(name, myROI)
		
		// create volume object and populate it with parameters. then return it
		object vol = alloc(IPrep_3Dvolume)
		vol.initReal(name+"_stack", GetTagValue("IPrep:volume slices"), myROI.getDigiscanX(), myROI.getDigiscanY())

		//vol.init(myROI,GetTagValue("IPrep:volume slices"))
		return vol
	}
	else
		throw("trying to generate 3D volume that does not exist")
}

object create3DVolume(object myROI) // factory for given ROI
{
	// create a volume for an ROI as argument

	object vol = alloc(IPrep_3Dvolume)
	vol.initReal(myROI.getName()+"_stack", GetTagValue("IPrep:volume slices"), myROI.getDigiscanX(), myROI.getDigiscanY())
	return vol
}

object create3DVolumeWithCustomName(object myROI, string name) // factory for given ROI that takes signal name into account
{
	// create a volume for an ROI as argument

	object vol = alloc(IPrep_3Dvolume)
	vol.initReal(name+"_stack", GetTagValue("IPrep:volume slices"), myROI.getDigiscanX(), myROI.getDigiscanY())
	return vol

}

class VolumeManager: object
{
	// manages 3D stacks, one for each ROI, in an objectlist
	// does not manage the PECS volume

	object list 
	object PECSImage

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("VolManager", level, text)
	}

	void print(object self, string printstr)
	{
		result("VolManager: "+printstr+"\n")
		self.log(2,printstr)
	}

	void VolumeManager(object self)
	{
		// constructor, allocate the list
		list = alloc(objectlist)
	}

	void initForAllROIs(object self)
	{
		// initializes a 3D volume for a given ROI based on its digiscan parameters and add it to the list
		
		// delete the list
		list.ClearList()

		object tall_enabled = returnROIManager().getAllEnabledROIList()
		number count = tall_enabled.SizeOfList()

		self.print("found "+count+" enabled ROIs. creating a volume for each")

		foreach(object myROI; tall_enabled)
		{
			self.print("found "+myROI.getName())
			object vol = create3DVolume(myROI)

			// now add to list
			list.AddObjectToList(vol)
			//vol.show()
		}
	}

	void initForAllROIsAndSignals(object self)
	{
		// initializes a 3D volume for a given ROI based on its digiscan parameters and add it to the list
		
		// delete the list
		list.ClearList()

		object tall_enabled = returnROIManager().getAllEnabledROIList()
		number count = tall_enabled.SizeOfList()

		self.print("found "+count+" enabled ROIs. creating a volume for each")

		foreach(object myROI; tall_enabled)
		{
			self.print("found "+myROI.getName())
			if (returnworkflow().returnDigiscan().numberOfSignals() == 2) // 2 signals, create 3d stack for each
			{
				object vol0 = create3DVolumeWithCustomName(myROI, myROI.getName()+"_"+returnworkflow().returnDigiscan().getName0())
				list.AddObjectToList(vol0)
				object vol1 = create3DVolumeWithCustomName(myROI, myROI.getName()+"_"+returnworkflow().returnDigiscan().getName1())
				list.AddObjectToList(vol1)
			}
			else // only 1 signal
			{	
				object vol = create3DVolume(myROI)
				// now add to list
				list.AddObjectToList(vol)
			}

		}
	}

	void initForDefaultROI(object self)
	{
		// delete the list
		list.ClearList()

		// use 2 signals
		if (returnworkflow().returnDigiscan().numberOfSignals() == 2) // 2 signals, create 3d stack for each
		{
				object vol0 = create3DVolume("StoredImaging", "StoredImaging_"+returnworkflow().returnDigiscan().getName0())
				list.AddObjectToList(vol0)
				object vol1 = create3DVolume("StoredImaging", "StoredImaging_"+returnworkflow().returnDigiscan().getName1())
				list.AddObjectToList(vol1)
		}
		else // only 1 signal
		{
			object vol = create3DVolume("StoredImaging", "StoredImaging")
			list.AddObjectToList(vol)
		}



		//vol.show()
	}

	void initForSpecificROI(object self, string name)
	{
		
		// get ROI
		object myROI
		returnROIManager().getROIAsObject(name, myROI)
		
		// use 2 signals
		if (returnworkflow().returnDigiscan().numberOfSignals() == 2) // 2 signals, create 3d stack for each
		{
				object vol0 = create3DVolumeWithCustomName(myROI, myROI.getName()+"_"+returnworkflow().returnDigiscan().getName0())
				list.AddObjectToList(vol0)
				object vol1 = create3DVolumeWithCustomName(myROI, myROI.getName()+"_"+returnworkflow().returnDigiscan().getName1())
				list.AddObjectToList(vol1)
		}
		else
		{
			object vol = create3DVolume("lookup_ROI", name)
			// now add to list
			list.AddObjectToList(vol)
		}


		
		//vol.show()
	}

	void initForPECS(object self, string name)
	{
		object vol = create3DVolume("PECS_full", name)
		list.AddObjectToList(vol)
		//PECSImage.show()
	}

	void showAll(object self)
	{
		foreach( object myVol; list )
		{
			myVol.show()
		}
	}

	object returnVolume(object self, string name)
	{
		// returns handle of 3D volume so that images can be added
		// greedy 

		foreach( object myVol; list )
		{
			if (myVol.getName() == name || myVol.getName() == name+"_stack")
				return myVol
		}

		// not found
		throw ("ROI in volume not found: "+name)

	}

}

// create volume manager
object myVolumeManager = alloc(VolumeManager)

object returnVolumeManager()
{
	// returns the volumeManager object
	return myVolumeManager
}

// *** generate a 3D volume for an ROI





//testing

//object my3Dvolume = alloc(iprep_3Dvolume)
//my3Dvolume.initSEM_3D(10)
//my3Dvolume.show()

//image sl := RealImage("iprep_sem", 4, 1000,1000)
//sl = 11
//my3Dvolume.as()
//my3Dvolume.addSlice(sl)
//my3Dvolume.addSlice(sl)
