DSSetScanControl(1) // 1 is grab, 0 is release
result(DSHasScanControl()+"\n")

number dwellTime = 0.05        //in seconds

number xImg, yImg

image survey := GetFrontImage( )

if ( DSIsValidDSImage( survey ) )        // Act only if it is a DigiScan image

{

 number sizeX, sizeY

 GetSize( survey, sizeX, sizeY )

 number cx = trunc( sizeX / 2 )

 number cy = trunc( sizeY / 2 )

 number radius = trunc( min( sizeX, sizeY ) / 10 )

 number angleStep = 12 // degree

 number steps = trunc( 360 / angleStep ) // Calculate steps

 number angle

 complexnumber pos

 
 DSInvokeButton( 7, 0 )        // Remove beam marker via the GUI in case it is shown

 DSSetScanControl( 1 )        // Get ScanControl

 for ( number loop = 1; loop <= 10000; loop++ )

 {

         Result( "Loop " + loop + ": \n" )

         for ( number c = 0; c < steps; c++ )

         {

                 angle = PI( ) / 180 * c * angleStep        // current angle in radians

                 pos = Complex( radius, angle )        // store position vector in polar complex number

                 pos = Complex( cx, cy ) + Rect( pos ) // store beam position as complex number using carthesian coordinats

                 DSPositionBeam( survey, Real( pos ), Imaginary( pos ) )

                 Result( "Placing beam at:\t " + Real( pos ) + " / " + Imaginary( pos ) + " [pixels] \n" )

                 sleep( dwelltime )
                 if(optiondown())
                 {
					throw("stopped by user")
                 }

         }

 }

 
 DSSetScanControl( 0 )        // Release ScanControl

}

else 

{

 Throw( "Front image is not a DigiScan survey image." )

}

Result( "\n Done" )

