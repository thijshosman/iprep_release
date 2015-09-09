image img = IFMFilteredCrossCorrelation( D, E, "Copy of Hanning Window" )
//image img:=getfrontimage()
number t=0,b,l=0,r
GetSize( img, r, b )
result( "r="+r+",b="+b+"\n")
number x,y
number eoriginchoice = 1

IUImageFindMax( img, t,l,b,r, x,y, eoriginchoice )
result( "x="+x+",y="+y+" pixels\n")

number scale_x, scale_y
d.GetScale(scale_x, scale_y)
string units = d.GetUnitString()

number x_cal = x * scale_x
number y_cal = y * scale_y
result( "x="+x_cal+",y="+y_cal+" "+units+"\n")