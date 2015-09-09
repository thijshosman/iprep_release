number getUnitMultiplier( image img )
{	
	string units0 = ImageGetDimensionUnitString( img, 0 )
	string units1 = ImageGetDimensionUnitString( img, 1 )
	number unitMultiplier = 1

	if ( units0 != units1 )
		throw( "Error: image not correctly calibrated (axes calibrations not equal)" )

	if ( units0 == "um" || units0 == "µm" ) unitMultiplier = 1e-6
	else if ( units0 == "mm" ) unitMultiplier = 1e-3
	else if ( units0 == "nm" ) unitMultiplier = 1e-9
	else if ( units0 == "A" || units0 == "Ã" ) unitMultiplier = 1e-10
	else if ( units0 == "m" ) unitMultiplier = 1
	else throw( "Error: image units ("+units0+" not recognized." )

	return unitMultiplier
}
  

void iprep_moveToImageROI( image img )
{  
	ImageDisplay imageDisp = img.ImageGetImageDisplay( 0 )  
	number count = imageDisp.ImageDisplayCountROIS()  
	number index  
	number scale0 = ImageGetDimensionScale( img, 0 ) 
	number origin0 = ImageGetDimensionOrigin( img, 0 ) 
	string units0 = ImageGetDimensionUnitString( img, 0 )
	number scale1 = ImageGetDimensionScale( img, 1 ) 
	number origin1 = ImageGetDimensionOrigin( img, 1 ) 
	string units1 = ImageGetDimensionUnitString( img, 1 )

	number unitMultiplier = getUnitMultiplier( img )

	number centerx,centery,sizex,sizey
	img.get2Dsize( sizex, sizey )
	centerx = sizex / 2
	centery = sizey / 2

	number xc,yc
	number ROIfound = 0
	for (index = count-1; index >= 0; --index )  
	{   
		ROI currentROI = imageDisp.ImageDisplayGetROI( index )  
//		if ( ROIGetLabel( currentROI ) == centerROIName )	// Ignore any calibration with the name centerROIName
//			continue

		if ( ROIIsPoint( currentROI ) )
		{
			number xu,yu
			ROIGetPoint( currentROI, xu, yu )
			xc=(xu-centerx)*scale0*unitMultiplier
			yc=(yu-centery)*abs(scale1)*(-unitMultiplier)	// Flip y axis cal to match stage coordinates
//			Result( "Point distance from image center: "+currentROI.ROIGetLabel()+": "+xc+","+yc+" m\n")
			ROIfound = 1
			imageDisp.ImageDisplayDeleteROI( currentROI )
			break
		}
		else if ( ROIIsRectangle( currentROI ) )
		{
			number t,l,b,r
			ROIGetRectangle( currentROI, t,l,b,r )
			xc=((r+l)/2-centerx)*scale0*unitMultiplier
			yc=((b+t)/2-centery)*abs(scale1)*(-unitMultiplier)	// Flip y axis cal to match stage coordinates
//			Result( "Region center distance from image center: "+currentROI.ROIGetLabel()+": "+xc+","+yc+" m\n")
			number lx2=(r-l)/2,ly2=(b-t)/2
			try
				ROISetRectangle( currentROI, centery-ly2,centerx-lx2,centery+ly2,centerx+lx2 )
			catch
				imageDisp.ImageDisplayDeleteROI( currentROI )
				
			ROIfound = 1
			break
		}
	}  

	if ( ROIfound )
	{
		number stagex, stagey
		stagex = EMGetStageX()/1000
		stagey = EMGetStageY()/1000
		number newX,newY
		newX = stagex + xc*1000
		newY = stagey + yc*1000
//result("("+stagex+","+stagey+")\n")
//result("("+(newX)+","+(newY)+")\n")

		EMSetStageXY( newX*1000, newY*1000 )
		// nCorr_SetPosX_mm( stagex - xc*1000 )	//	*1000 is to convert from m to mm
		// nCorr_SetPosY_mm( stagey - yc*1000 )
	}
}


void iprep_moveToImageROI( void )
{
	image img:=GetFrontImage()
	iprep_moveToImageROI( img )
}


 iprep_moveToImageROI(  )
