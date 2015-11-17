class IROI: object
{
	// simple container class for Region of Interest
	string name
	number enabled

	// attributes
	string coordName // name of stage coordinate associated with this ROI so that it can be queried by semcoordmanager
	number focus // the focus value
	number brightness // the brightness value
	number contrast // the contrast value
	number mag // the magnification value 
	number voltage // the voltage value (in kv)
	number ss // spot size used
	number stigx // stig x value used
	number stigy // stig y value used

	taggroup digiscan_param // complete set of digiscan parameter array
	number af_mode // autofocus mode used. 0 = off, 1 = on every slice, 2 = on for first slice, then off

	string getName(object self)
	{
		return name
	}

	void setName(object self, string name1)
	{
		// set name
		name = name1
	}

	void setEnabled(object self, number st)
	{
		enabled = st
	}

	number getEnabled(object self)
	{
		return enabled
	}

	void IROI(object self)
	{
		// constructor, default values
		name="unnamed"
		coordName = "nominal_imaging"
		focus =0
		brightness =0
		contrast =0
		mag =0
		voltage =0
		ss =0
		stigx =0
		stigy =0
		enabled = 0
		af_mode = 0 // default
		digiscan_param =  NewTagGroup()


	}

	void setAFMode(object self, number mode1)
	{
		af_mode = mode1
	}

	void setDigiscanParam(object self, taggroup tg)
	{
		digiscan_param = tg
	}

	void setCoordName(object self, string name1)
	{
		coordName = name1
	}

	// value setters

	void setFocus(object self, number val1)
	{
		focus = val1
	}

	void setbrightness(object self, number val1)
	{
		brightness = val1
	}

	void setContrast(object self, number val1)
	{
		contrast = val1
	}

	void setMag(object self, number val1)
	{
		mag = val1
	}

	void setVoltage(object self, number val1)
	{
		voltage = val1
	}

	void setss(object self, number val1)
	{
		ss = val1
	}

	void setStigx(object self, number val1)
	{
		stigx = val1
	}

	void setStigy(object self, number val1)
	{
		stigy = val1
	}

	// getter methods

	number getFocus(object self)
	{
		return focus
	}

	number getMag(object self)
	{
		return mag
	}

	number getContrast(object self)
	{
		return contrast
	}

	number getBrightness(object self)
	{
		return brightness
	}

	number getVoltage(object self)
	{
		return voltage
	}

	number getss(object self)
	{
		return ss
	}

	number getStigx(object self)
	{
		return stigx
	}

	number getStigy(object self)
	{
		return stigy
	}

	string getCoordName(object self)
	{
		return coordName
	}

	number getAFMode(object self)
	{
		return af_mode
	}

	taggroup getDigiscanParam(object self)
	{
		return digiscan_param
	}	

	void print(object self)
	{
		result("ROI: name: "+name+", enabled: "+enabled+"\n")
		result("  brightness: "+brightness+", contrast: "+contrast+"\n")
		result("  mag: "+mag+", focus: "+focus+"\n")

	}

	taggroup returnAsTag(object self)
	{
		// returns this coord as tag, to be saved in taggroup
		TagGroup tg = NewTagGroup()

		tg.addTag("name",name)
		tg.addTag("coordName",coordName)
		tg.addTag("enabled",enabled)
		tg.addTag("af_mode",af_mode)
		
		tg.addTagAsFloat("focus", focus)
		tg.addTagAsFloat("brightness", brightness)
		tg.addTagAsFloat("contrast", contrast)
		tg.addTagAsFloat("mag", mag)
		tg.addTagAsFloat("voltage", voltage)
		tg.addTagAsFloat("ss", ss)
		tg.addTagAsFloat("stigx", stigx)
		tg.addTagAsFloat("stigy", stigy)
		tg.TagGroupSetTagAsTagGroup("digiscan_param",digiscan_param)
	
		return tg
	}
}

object ROIFactory(number type, string name1)
{
	// creates various kinds of standard ROI objects

	if (type == 0)
	{
		// default ROI, intended to be used for legacy mode
		// assumes coord to the the same name
		object aROI = alloc(IROI)
		aROI.setName(name1)
		aROI.setCoordName(name1) // coord has same name as ROI
		aROI.setEnabled(1) // enable by default
		aROI.setFocus(9.7) // default focus
		aROI.setDigiscanParam(GetTagGroup("Private:DigiScan:Faux:Setup:Record")) // default, 'capture' (2)
		return aROI
	}


}

class ROIEnables: object
{
	// manages which values are enabled for all ROIs

	number enable_brightness // enable setting brightness
	number enable_contrast // enable setting contrast
	number enable_mag // enable setting mag
	number enable_voltage // enable setting beam energy
	number enable_ss // enable setting spot size
	number enable_stigx // enable setting stigmation in x
	number enable_stigy // enable setting stigmation in y


	void ROIEnables(object self)
	{
		// disable all enables by default

		enable_brightness =0
		enable_contrast =0
		enable_mag =0
		enable_voltage =0
		enable_ss =0
		enable_stigx =0
		enable_stigy =0
	}

	number getAnEnable(object self, string name1)
	{
		// *** private ***
		string tagname = "IPrep:ROIEnables:"+name1
		number returnval
		GetPersistentNumberNote( tagname, returnval )
		return returnval
	}

	// setter methods
	void enableBrightness(object self, number val1)
	{
		enable_brightness = val1
	}

	void enableContrast(object self, number val1)
	{
		enable_contrast = val1
	}

	void enableMag(object self, number val1)
	{
		enable_mag = val1
	}

	void enableVoltage(object self, number val1)
	{
		enable_voltage = val1
	}

	void enabless(object self, number val1)
	{
		enable_ss = val1
	}

	void enableStigx(object self, number val1)
	{
		enable_stigx = val1
	}

	void enableStigy(object self, number val1)
	{
		enable_stigy = val1
	}


	// getter methods

	number brightness(object self)
	{
		return self.getAnEnable("brightness")
	}

	number contrast(object self)
	{
		return self.getAnEnable("contrast")
	}

	number mag(object self)
	{
		return self.getAnEnable("mag")
	}

	number voltage(object self)
	{
		return self.getAnEnable("voltage")
	}

	number ss(object self)
	{
		return self.getAnEnable("ss")
	}

	number stigx(object self)
	{
		return self.getAnEnable("stigx")
	}

	number stigy(object self)
	{
		return self.getAnEnable("stigy")
	}


}


class ROIManager: object
{

	// manages a list of IROI objects saved in tags
	string location // location in persistent taggroup

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("ROIManager", level, text)
	}

	void print(object self, string printstr)
	{
		result("ROIManager: "+printstr+"\n")
		self.log(2,printstr)
	}

	void ROIManager(object self)
	{
		// constructor
		location = "IPrep:ROIs" // default location
	}

	void init(object self, string location1)
	{
		// inits
		// path to correct tag
		location = location1
	}

	TagGroup getROIList(object self)
	{
		// get the list of ROI tags in the persistent taggroup

		taggroup tg = GetPersistentTagGroup()
		return TagGroupGetOrCreateTagList( tg, location )
	}

	number checkROIExistence(object self, string name)
	{
		// returns 1 if ROI found

		taggroup subtag // not used
		taggroup tall = self.getROIList()
		number count = tall.TagGroupCountTags( ) 
		number i
		
		for (i=0; i<count; i++)
		{
			// index the list and get single tag
			tall.TagGroupGetIndexedTagAsTagGroup(i,subtag)
			string name1
			subtag.TagGroupGetTagAsString("name", name1)

			if (name1 == name)
			{			
				//result("found "+name1+"\n")
				//subtag.taggroupopenbrowserwindow(0)
				return 1
			}
		}
		return 0
	}


	number getROIAsTag(object self, string name, taggroup &subtag)
	{
		// eagerly finds coord with given name and return it
		taggroup tall = self.getROIList()
		number count = tall.TagGroupCountTags( ) 
		number i
		
		for (i=0; i<count; i++)
		{
			// index the list and get single tag
			tall.TagGroupGetIndexedTagAsTagGroup(i,subtag)
			string name1
			subtag.TagGroupGetTagAsString("name", name1)

			if (name1 == name)
			{			
				self.print("found "+name1)
				//subtag.taggroupopenbrowserwindow(0)
				return 1
			}
		}
		return 0

	}

	void addROI(object self, object aROI)
	{
		// adds a coord to the list. create if name does not exist, overwrite if it does
		
		// get the taglist we want to add the coord to
		taggroup t1 = self.getROIList()
		
		taggroup subtag
		// search for the name
		if (self.getROIAsTag(aROI.getName(),subtag))
		{
			// ROI with same name found, now replace it with the new one
			self.print("replacing existing "+aROI.getName())
			TagGroupReplaceTagsWithCopy(subtag,aROI.returnAsTag())
			
			//subtag.TagGroupOpenBrowserWindow( 0 )
			//aROI.returnAsTag().TagGroupOpenBrowserWindow( 0 )
		}
		else
		{
			// coord with that name does not exist yet. add it. 
			self.print("inserting "+aROI.getName())
			t1.TagGroupAddTagGroupAtEnd( aROI.returnAsTag() )
		}
		
		ApplicationSavePreferences()

	}

	number delROI(object self, string namestring)
	{
		taggroup tall = self.getROIList()
		number count = tall.TagGroupCountTags( ) 
		number i
		
		if(namestring == "")
			return 0 // no empty namestring allowed

		taggroup subtag
		for (i=0; i<count; i++)
		{
			// index the list and get single tag
			tall.TagGroupGetIndexedTagAsTagGroup(i,subtag)
			string name1
			subtag.TagGroupGetTagAsString("name", name1)

			if (name1 == namestring)
			{			
				// found, delete the tag with this index
				//subtag.taggroupopenbrowserwindow(0)
				tall.TagGroupDeleteTagWithIndex(i)
				self.print("deleted ROI: "+name1)
				return 1
			}
		}
		return 0 // not found
	}

	object convertTagToROI(object self, taggroup subtag)
	{
		// converts a tag to a sem object

		string name
		subtag.TagGroupGetTagAsString("name",name)

		string coordName
		subtag.TagGroupGetTagAsString("coordName",coordName)

		number enabled
		subtag.TagGroupGetTagAsNumber("enabled",enabled)

		number af_mode
		subtag.TagGroupGetTagAsNumber("af_mode",af_mode)

		taggroup digiscan_param
		subtag.TagGroupGetTagAsTaggroup("digiscan_param",digiscan_param)

		number focus
		subtag.TagGroupGetTagAsFloat("focus",focus)

		number brightness
		subtag.TagGroupGetTagAsFloat("brightness",brightness)

		number contrast
		subtag.TagGroupGetTagAsNumber("contrast",contrast)
		
		number mag
		subtag.TagGroupGetTagAsNumber("mag",mag)

		number voltage
		subtag.TagGroupGetTagAsNumber("voltage",voltage)

		number ss
		subtag.TagGroupGetTagAsNumber("ss",ss)		

		number stigx
		subtag.TagGroupGetTagAsNumber("stigx",stigx)

		number stigy
		subtag.TagGroupGetTagAsNumber("stigy",stigy)


		object tempROI = alloc(IROI)
		tempROI.setName(name)
		tempROI.setCoordName(coordName)
		tempROI.setEnabled(enabled)
		tempROI.setAFMode(af_mode)
		tempROI.setDigiscanParam(digiscan_param)
		tempROI.setFocus(focus)
		tempROI.setBrightness(brightness)
		tempROI.setContrast(contrast)
		tempROI.setMag(mag)
		tempROI.setVoltage(voltage)
		tempROI.setss(ss)
		tempROI.setStigx(stigx)
		tempROI.setStigy(stigy)

		return tempROI
	}

	number getROIAsObject(object self, string name, object &obj)
	{
		// returns tag with given name from persistent list and create ROI
		taggroup subtag
		if (self.getROIAsTag(name,subtag))
		{	
			obj =  self.convertTagToROI(subtag)
			return 1
		}
		else
			return 0


	}

	void printAll(object self)
	{
		// prints all ROIs
		
		// get the list of stored ROIs
		taggroup tall = self.getROIList()
		number count = tall.TagGroupCountTags( ) 
		number i
		taggroup subtag // temporary storage
		string name
		
		for (i=0; i<count; i++)
		{
			// index the list and get single tag
			tall.TagGroupGetIndexedTagAsTagGroup(i,subtag)
			
			TagGroupGetTagAsString(subtag,"name",name)
			//result(name+"\n")
			self.convertTagToROI(subtag).print()

			//tg.TagGroupOpenBrowserWindow( 0 )
			//result(i)
		}

	}


}

/*

// create the ROIManager
object myROIManager = alloc(ROIManager)

// allow the workflow and UI access to the ROI manager
object returnROIManager()
{
	return myROIManager
}

// create the object that figures out which part of the ROI is enabled
object myROIEnables = alloc(ROIEnables)

// allow the workflow and UI access to the ROI enables
object returnROIEnables()
{
	return myROIEnables
}


object myROI1 = ROIFactory(0,"test1")
myROI1.print()

object myROI2 = ROIFactory(0,"test2")
myROI2.print()

// add these rois and print them all
returnROIManager().addROI(myROI1)
returnROIManager().addROI(myROI2)
returnROIManager().printAll()

// getting coord by name, old, no longer used
//object myROI3 = returnROIManager().getROIAsObject("test1")
//myROI3.print()

// getting coord by name, new
object myROI 
returnROIManager().getROIAsObject("test1", myROI)
myROI.print()

result("brightness enabled: "+returnROIEnables().brightness()+"\n")
result("contrast enabled: "+returnROIEnables().contrast()+"\n")

*/


