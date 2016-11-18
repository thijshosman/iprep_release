

image temp_slice_im0, temp_slice_im1

myWorkflow.returnDigiscan().config(temp_slice_im0,temp_slice_im1)

myWorkflow.returnDigiscan().acquire()

temp_slice_im1.showimage()

/*

image survey := GetFrontImage( )
 
number sizeX, sizeY
GetSize( survey, sizeX, sizeY )

//result(sizeX)
number xnew = trunc( sizeX / 4 )
number ynew = trunc( sizeY / 4 )

result("xnew: "+xnew+"\n")
result("ynew: "+ynew+"\n")

DSPositionBeam(survey, xnew,ynew)


//DSInvokeButton( 7, 1 )

DSSetScanControl(1) // 1 is grab, 0 is release
//result(DSHasScanControl()+"\n")
*/
