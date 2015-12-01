// status display element

class IPrep_status : UIFrame
{
	TagGroup CreateTags(object self)
	{
		TagGroup tags = DLGCreateDialog("IPrep Status")
		TagGroup position;
		position = DLGBuildPositionFromApplication();
		position.TagGroupSetTagAsString( "Width", "Medium" );
		position.DLGSide( "Left" );
		tags.DLGPosition( position );
		
		TagGroup Button1 = DLGCreatePushButton("Rotate", "Button1_Click");
		Button1.DLGIdentifier("Button1");
		tags.DLGAddElement(Button1);

		TagGroup Button2 = DLGCreatePushButton("Crop", "Button2_Click");
		Button2.DLGIdentifier("Button2");
		tags.DLGAddElement(Button2);
		
		TagGroup Button3 = DLGCreatePushButton("ROI", "Button3_Click");
		Button2.DLGIdentifier("Button3");
		tags.DLGAddElement(Button3);

		taggroup tb = DLGCreateTextBox( 50, 10,  100 )
		tb.DLGIdentifier("test")
		tags.DLGAddElement(tb);

		return tags;
	}

	rotateandcrop( object self )
	{
		self.super.init( self.CreateTags() );
	}

	void Button1_Click( object self )
	{
		

		//Find image and ROI
		image in := getfrontimage()
		ImageDisplay imageDisp = in.ImageGetImageDisplay( 0 ) 
		number xscale,yscale
		string units

		number count = imageDisp.ImageDisplayCountROIS()
		if(count<1)throw("No ROI on image")
		ROI currentROI = imageDisp.ImageDisplayGetROI( 0)

		number x1,y1,x2,y2
		ROIGetLine(currentROI,y1,x1,y2,x2)

		//find angle
		number angle =atan((x2-x1)/(y2-y1))
		result("Angle "+angle*360/(2*pi())+"\n")

		//save calibration from original image
		getscale(in,xscale,yscale)
		units = getunitstring(in)
		
		//rotate image and crop
		image dummy = rotate(in,angle)
		//find shotest side then cut out square in centre srt(2) in size so always the same size
		//and always without cropping
		
		number xsizein,ysizein, crop
		getsize(in,xsizein,ysizein)

		if(xsizein >= ysizein)
			{
			crop = 0.5*ysizein/sqrt(2)
			}

		else if(xsizein<ysizein)
			{
			crop = 0.5*xsizein/sqrt(2)
			}

		number xsizedummy, ysizedummy
		getsize(dummy,xsizedummy,ysizedummy)

		image out = dummy

		setscale(out,xscale,yscale)
		setunitstring(out,units)
		//cleanup
		deleteimage(dummy)
		showimage(out)

	}
	void Button2_Click( object self )
	{
		

		//Find image and ROI
		image in := getfrontimage()
		ImageDisplay imageDisp = in.ImageGetImageDisplay( 0 ) 
		number xscale,yscale
		string units

		number count = imageDisp.ImageDisplayCountROIS()
		if(count<1)throw("No ROI on image")
		ROI currentROI = imageDisp.ImageDisplayGetROI( 0)

		number x1,y1,x2,y2

		ROIGetRectangle( currentROI,y1,x1,y2,x2 )  


		//save calibration from original image
		getscale(in,xscale,yscale)
		units = getunitstring(in)
		
		//crop
		image dummy = in[y1,x1,y2,x2]

		image out = dummy

		setscale(out,xscale,yscale)
		setunitstring(out,units)
		//cleanup
		deleteimage(dummy)
		showimage(out)

	}

	void Button3_Click( object self)
	{
		image in := getfrontimage()
		ImageDisplay imageDisp = in.ImageGetImageDisplay( 0 )

		number xsize, ysize
		number height = 1400
		number width = 1400
		getsize(in,xsize,ysize)
		if(xsize<width)width=xsize
		if(ysize<height)height=ysize

		ROI selection = NewROI( ) 

		selection.ROISetRectangle(((ysize/2)-(height/2)), ((xsize/2)-(width/2)), ((ysize/2)+(height/2)),((xsize/2)+(width/2)) )
		selection.ROISetColor( 0, 100, 0 )
		imageDisp.ImageDisplayAddROI( selection )	
	}
		
}

object grotateandcrop = alloc(rotateandcrop);
number grotateandcropTok = RegisterScriptPalette( grotateandcrop, "rotateandcrop", "rotate and crop");
// Use UnregisterScriptPalette() to unregister the floating palette: 
// UnregisterScriptPalette(grotateandcropTok);
//string tokstr  = format(grotateandcropTok, "%f");
//result("The test-palette token is " + tokstr + ". Use UnregisterScriptPalette(" + tokstr + ") to unregister the palette.");
//OKDialog("The test-palette token is " + tokstr + ". Use UnregisterScriptPalette(" + tokstr + ") to unregister the palette.");
