// #BACKGROUND$
string s1="Private:AFS Parameters"
string s2="Focus accuracy"
string s3="Focus limit (lower)"
string s4="Focus limit (upper)"
string s5="Focus search range"
number n2,n3,n4,n5

string str2 
number focus_range_fraction = .2
number focus = EMGetFocus()
number focus_range = .1*focus
number focus_res = .01*focus

str2 = s1+":"+s2
GetPersistentNumberNote( str2, n2 )
n2 = focus_res
if ( !GetNumber( str2, n2, n2 ) ) exit(0)
SetPersistentNumberNote( str2, n2 )


str2 = s1+":"+s3
GetPersistentNumberNote( str2, n3 )
n3 = focus - focus * focus_range_fraction
if ( !GetNumber( str2, n3, n3 ) ) exit(0)
SetPersistentNumberNote( str2, n3 )

str2 = s1+":"+s4
GetPersistentNumberNote( str2, n4 )
n4 = focus + focus * focus_range_fraction
if ( !GetNumber( str2, n4, n4 ) ) exit(0)
SetPersistentNumberNote( str2, n4 )

str2 = s1+":"+s5
GetPersistentNumberNote( str2, n5 )
n5=focus_range
if ( !GetNumber( str2, n5, n5 ) ) exit(0)
SetPersistentNumberNote( str2, n5 )

//AF_Run()
// /*
number start_focus = EMGetFocus()
result("\n"+datestamp()+": start WD = "+(start_focus/1000)+"\n")
AFS_Run()

while( AFS_IsBusy() )
{
	sleep( 1 )
	result(".")
}
result("\n")
number end_focus = EMGetFocus()
result(datestamp()+": final WD = "+(end_focus/1000)+"\n")
//*/
/*
{
	number mag=EMGetMagnification()
	number focus=EMGetFocus()
	number i=0,df
	image plot:=RealImage("AF test,mag="+mag+",prec="+n2,4,11,1)
	plot.showimage()
	plot.displayat(500,100)
	plot=focus/1000
	for (df=-2.5;df<=2.5;df+=.5)
	{
		EMSetFocus(focus+1000*df)
		sleep(1)
		if (shiftdown() &&optiondown() ) exit(0)
		number start_focus = EMGetFocus()
		result(i+":"+datestamp()+": start WD = "+(start_focus/1000)+"\n")
		AFS_Run()
		number end_focus = EMGetFocus()
		result(i+":"+datestamp()+": final WD = "+(end_focus/1000)+"\n\n")
		plot[i,0]=end_focus/1000
		plot.updateimage()
		i+=1
	}
}
*/