// $BACKGROUND$
class IPrep_3Dvolume: object
{
	// creates and manages IPrep 3D volumes
	// both for digiscan and for pecs

	image iprep_volume
	number slices
	number x,y


	image returnVolume(object self)
	{
		return iprep_volume
	}

	void show(object self)
	{
		showimage(iprep_volume)
	}

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




}

//testing

//object my3Dvolume = alloc(iprep_3Dvolume)
//my3Dvolume.initSEM_3D(10)
//my3Dvolume.show()

//image sl := RealImage("iprep_sem", 4, 1000,1000)
//sl = 11
//my3Dvolume.as()
//my3Dvolume.addSlice(sl)
//my3Dvolume.addSlice(sl)
