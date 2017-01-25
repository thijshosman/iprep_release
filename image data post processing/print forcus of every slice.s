// iterate through stack of images and print the focus value as reported in the tag
Image img := GetFrontImage()

TagGroup tg = img.ImageGetTagGroup()
tg.addTag("test1:test2",1)

saveAsGatan(img, "c:\\temp\\testimg.dm4")
tg.TagGroupOpenBrowserWindow( 0 ) 




