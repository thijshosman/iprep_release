// Calc imaging parameters
// JAH, 20150826

// Issues: hard coded mag cal, UI layout poor
// Could set parameters when done (EM mag, Digiscan # pixels)

number n_pix = 1024 *4
number mag = emgetmagnification()
number cal = 145162 // um * X, Quanta/Digiscan, 201508
number fov = cal / mag
number ps = fov / n_pix

number done = 0
TagGroup DLG, DLGItems
while ( ! done )
{
	DLG = DLGCreateDialog( "Digiscan imaging parameters calculator\n\nSelect calculation method:", DLGItems )

	TagGroup radio1tg = DLGCreateRadioList( 1 )
	radio1tg.DLGAddRadioItem( "pixel size     (knowns: # pixels, magnification)", 1)
	radio1tg.DLGAddRadioItem( "pixel size     (knowns: # pixels, FOV)", 2)
	radio1tg.DLGAddRadioItem( "magnification  (knowns: # pixels, pixel size)", 3)
	radio1tg.DLGAddRadioItem( "magnification  (knowns: FOV)", 4)
	radio1tg.DLGAddRadioItem( "# pixels       (knowns: magnification, pixel size)", 5)
	radio1tg.DLGAddRadioItem( "FOV            (knowns: magnification)", 6)

	DLGitems.DLGAddElement( DLGCreateLabel( "Calculate:" ) )        
	DLGitems.DLGAddElement( radio1tg )

	TagGroup val1tg, val2tg, val3tg, val4tg

	DLGitems.DLGAddElement( DLGCreateRealField( "pixel size (microns) :", val1tg, ps, 8, 4 ) )        
	DLGitems.DLGAddElement( DLGCreateRealField( "magnification (X) :", val2tg, mag, 8, 0 ) )        
	DLGitems.DLGAddElement( DLGCreateRealField( "# pixels :", val3tg, n_pix, 8, 0 ) )        
	DLGitems.DLGAddElement( DLGCreateRealField( "FOV (microns) :", val4tg, fov, 8, 3 ) )        

	if ( !Alloc( UIframe ).Init( DLG ).Pose() )
		break

	ps = val1tg.DLGGetValue()
	mag = val2tg.DLGGetValue()
	n_pix = val3tg.DLGGetValue() 
	fov = val4tg.DLGGetValue() 
	
	number calc_type = radio1tg.DLGGetValue()

	if ( calc_type == 1 )
	// Calculate pixel size (knowns: # pixels, magnification)
	{
	//	n_pix = 1024 *4
	//	mag = emgetmagnification()
		fov = cal / mag
		
		ps = fov / n_pix
	}

	else if ( calc_type == 2 )
	// Calculate pixel size     (knowns: # pixels, FOV)
	{
	//	n_pix = 1024 *4
	//	fov = cal / mag
		mag = cal / fov
		
		ps = fov / n_pix
	}

	else if ( calc_type == 3 )
	// Calculate magnification (knowns: # pixels, pixel size)
	{
	//	n_pix = 1024 *4
	//	ps = fov / n_pix
		fov = ps * n_pix
		
		mag = cal / fov
	}

	else if ( calc_type == 4 )
	// Calculate magnification  (knowns: FOV)
	{
		
		mag = cal / fov
		ps = fov / n_pix

	}

	else if ( calc_type == 5 )
	// Calculate # pixels (knowns: magnification, pixel size)
	{
	//	ps = fov / n_pix
	//	mag = emgetmagnification()
		fov = cal / mag
		
		
		n_pix = fov / ps
	}
	
	else if ( calc_type == 6 )
	// Calculate FOV            (knowns: magnification)
	{
	//	ps = fov / n_pix
	//	mag = emgetmagnification()
		fov = cal / mag
		
		
		n_pix = fov / ps
	}
	else
		exit(0)

}

result(Datestamp()+": Digiscan/SEM imaging condition calculations\n" )
result("  SEM magnification (X): "+mag+"\n")
result("  FOV (microns): "+fov+"\n")
result("  # pixels in FOV: "+n_pix+"\n")
result("  Pixel size (microns): "+ps+"\n\n")

