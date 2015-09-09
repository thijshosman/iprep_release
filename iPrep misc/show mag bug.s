//show mag bug

number Z=emgetstagez()
number f=emgetfocus()
emsetstagez(60000)
emwaituntilready()
sleep(1)
emsetstagez(Z)
emwaituntilready()
emsetfocus(f)