image img:=getfrontimage()
number nrebin  = 2, s1 = 0, ns=3
number nprecycles  = 3, npostcycles=0
number xs,ys,zs,zn
number xt,yt,zt
get3dsize(img,xs,ys,zs)
number mediantype=2,kernelhalfsize=2
//image proc:=img.imageclone()
xt=xs/nrebin
yt=ys/nrebin
zt=zs
image proc:=realimage("test",4, xt, yt, zt )

image plane,zplane
setname(proc,"Repair1("+getname(img)+")")
number min,max,i
image kernel = realimage("kernel", 4, 3, 3 )
kernel = 1
for (zn=0;zn<zs;zn++)
{
	plane = img[0,0,zn,xs,ys,zn+1]
	plane.setname("plane")
//	showimage(plane)
	number bb=1/nrebin/nrebin
	for (i=0;i<nprecycles;i++)
	{
		plane = medianfilter( plane, 3, 1 )
		plane = convolution( plane, kernel )
	}
	zplane = rebin(plane, nrebin, nrebin) * bb
	zplane.setname("zplane")
//	showimage(zplane)
//	throw("hi")
	// zplane -= average(zplane)
	
	if (s1)
	{	// min, max
		number irange=1/(zplane.max()-zplane.min())
		min=zplane.min()
		zplane=(zplane-min)*irange
	}
	else
	{	// statistics 
		number v=sqrt(zplane.variance())
		number irange=1/(v*ns*2)
		min=zplane.average()-v*ns
		zplane=(zplane-min)*irange
	}
	
	for (i=0;i<npostcycles;i++)
	{
		zplane = medianfilter( zplane, 3, 1 )
		zplane = convolution( zplane, kernel )
	}
//	throw("Hi")
showimage(proc)

	proc[0,0,zn,xt,yt,zn+1]=zplane
//	proc[0,0,zt,xs,ys,zt+1]=medianfilter(proc[0,0,zn,xs,ys,zn+1],mediantype,kernelhalfsize)
	openandsetprogresswindow("Processing","Plane "+zn+"/"+zs,"")
	if (optiondown() && controldown()) break
}

openandsetprogresswindow("","","")
showimage(proc)
