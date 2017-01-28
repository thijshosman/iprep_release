
*** Using the IPrep ***

this directory contains files that explain how to run samples on the IPrep. some of these files contain information about a specific topic (ie to use the IPrep multi region of interest (ROI) framework) and some contain more detailed descriptions of various system parts. This started as an attempt to write down how certain problems are solved in the IPrep so that it is not just described on the code. 

Since IPrep is not a fully developed Gatan product just yet, some UI elements needed for setting up runs are lacking. In order to facilite discontinuous experiments and being able to recover from issues without loss of data, the system makes extensive use of DM tags. the idea behind that is that these tags are set by the user and used by the code. this is a form of persistence of parameters. Tags can be viewed by opening DM and going to file>global tags. Most tags used for IPrep are under the IPrep taggroup, but there are exceptions when dealing with generic DM functionality that IPrep uses (like autofocus; these tags are stored somewhere else). 

The user is encouraged to setup everything and manually test imaging/ebsd acquisition prior to starting the workflow, since all IPRep will do is run that sequence over again. A running 10 image history is stored for each ROI/signal. 

There are 2 kinds of fault/error flags: dead and unsafe. 
Dead generally means that something is not in the correct position and that getting all states consistent with what the system expects resolves the error. 
Unsafe means that something is not behaving correctly and needs to be carefully looked at before workflow can resume. This might indicate a real problem with the hardware. A call to Gatan has to be made to resolve this. 

Thijs Hosman, January 23 2017

