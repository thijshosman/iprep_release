
This file describes what all the todos are for the demounit master development branch. 

*** bugs ***
- [] when PECS has rebooted, check connection before starting workflow. now it still sort of runs but pops up messages in the meantime with that it failed to talk to PECS. can be dangerous
- [] image sequence turns top illuminators off. this is probably wrong. 
- [] rethink locking out the PECS UI at the end of milling vs at the beginning of transfer
- [] when changing capture settings in DM, you have to press 'capture' button before this becomes the capture setting returned by DSGetWidth( paramID ). iprep image sequence does not need initialization when settings change
- [] when PECS reboots, we have a strange situation in which somehow the workflow still communications but still throws an exception somewhere that prevents it from continuing the workflow
- [] some commands lock the UI thread in DM (gripper etc), no logic behind it that is oberservable. needs to be fixed

*** general/helper ***
- [x] the persistance classes need to throw a readable exception when a tag is not found to facilitate easy fixes on systems that do not have all the tags. 

*** mediator ***
- [] allow mediator to print out a list of common states for later use in UI dialog that reflects state of subsystems

*** parkertransfer ***:
- [x] allow homing to happen in the wrong direction. 
- [x] direction should be in a tag so that iprep can use it either way, also for normal positions

*** pecs ***:
- [x] add new shutter and argon functions to simulator
- [x] gate valve: check sensors before issuing open/close to speed up workflow
- [x] check state shutter coating sensor
- [x] tmp check can fail due to unterminated rs485. add redundancy
- [x] set a flag that is used for shutoff gas flow to make sure it never gets executed twice and 0 gets remembered
- [] get coating to work (requires work by MP)

*** SEM ***:
- [] have a way to check that z-height is set (for example by moving 10 micron in z and seeing if it throws an exception?) -> checkFWDCoupling in sem
- [] correct for drift in survey image, set maximum shift parameter and don't move but continue workflow if shift exceeds this
- [] migrate quanta bug fix to SEM class as generic fix
- [x] change the way we keep in focus after a transfer. now we explicitly set the focus after going to a coord in some coords 
- [x] change going to coords from an xyz movement into only an xy movement so that focus stays the same. 

*** dock ***:
- [x] set holding torque during transfer when opens so that we don't have the thing close as it is picked up or the arm comes in (planar only for now)
- [] allow chamberscope camera on/off -> needs hardware fix? 

*** linearworkflow/state machine/device transfer sequences ***
- [x] make a class for 'transfers' and make an object for each transfer that defines it instead of hardcoding it in 
- [x] linearworkflow class. linearworkflow would invoke the 'do' method in this command-like pattern. this is more flexible than what we have now. we can lateron even go to a script-like 
- [x] migrate transfer stuff over to this class and create factory to create sequences
- [x] also migrate imaging/ebsd/eds to sequence class
- [x] migrate coating and etching to transfer sequence class
- [x] use return 0/1/-1 instead of throwing exceptions from state machine. rewrite corresponding iprep_main methods. update ui to use dead/unsafe checks
- [x] make sure that non-irrecoverable errors from state machine get processed in main in a different way than true irrecoverable errors. now they are treated the same
- [x] migrate 2 ROI example to a proper sequence
- [x] create a way to manually/dynamically load sequences in state machine. right now state machine loads default sequences and menu items can change them. it would be better if there were a way to dynamically load a sequence defined by a tag when the state machine initializes and a menu item that loads the tag and reinits the state machine
- [] add a precondition that the sem is in 'clear' state and if not, ask user if he wants to home it. check unsafe/dead flags first
- [] add a precondition that imaging point exists
- [] start/resume should reinit sequences used to reflect changes (and possibly re-init the 3D volumes)

*** setup ***
- [x] stop using IPrep_Setup_Imaging(), is now redundant

*** multi ROI ***
- [x] we need a way to iterate over ROIs. the most logical thing would be to use the subtag for all ROIs that labels them as 'enabled'. the sequence method would then just iterate over all of them. use example robin. 
- [x] update roimanager to return all enabled rois
- [x] put a little more thought into autofocusing. every ROI needs a 'autofocus every n slices' number and query the active slice number to see if it needs to trigger that. if so, for now it is the image sequences responsibility to visit this ROI to actually do it. add this subtag to the ROI/ROImanager class
- [x] replace ROImanager convertTagToROI with initROIFromTag in ROI object. much cleaner
- [x] find a way to put order in ROI and have ROI manager order them when returning them
- [x] ability to autofocus every x slices, and always autofocus when start is pressed

*** workflow/main ***
- [x] make sure that pecs is idle before a transfer to make sure we are not transfering during milling
- [x] don't check dock mode at iprep_init as this prevents dock swap when dm is offline
- [x] when a dock is no present, iprep_init throws exception and does not fully load
- [x] beam does not blank
- [x] beam does not focus on storedimaging after transfer
- [x] af_mode is set by setup_imaging to 2 so that workflow uses the fixed value. for autofocus, this needs to be 1. 
- [x] when pausing during milling, it pauses, but then when resuming it mills again
- [x] do we really want the state machine to throw exceptions when asked to go start milling/ebsd/etc when that is prohibited? think about it. 
- [x] when a transfer starts, check for consistency beforehand
- [x] do not give warnings for pecs stage in raised or lowered position; only argon/tmp issues
- [] home SEM stage to clear as part of workflow to prevent problems after pressing start button
- [] after dock swap, set a flag that does not allow movement until iprep_scribemarkervectorcorrection has been run
- [] if max slices is reached already and workflow has started, it still gets to running mode; needs a check
- [x] issue stop_milling command before starting workflow just to be safe. 
- [x] add method to dynamically load an image sequence and init it (in state machine). the others do not change as often so they can use the regular init if needed
- [] how can we run custom methods on a particular sequence to set it up? pecs imaging is going to use the name of the object as initialized as the folder to save pecs images in
- [] NB: all dead/unsafe setting happens in main, not state machine. the state machine just returns values (0,1,-1). the main functions need some proper sculpting to now put the system in a dead/unsafe state needlessly
- [] when a 'soft' error happens (ie return 0) in workflow (ie milling precondition not met) system should pause workflow. may require change to how DM handles pause/start/stop events
- [] we want to make sure that an error during the workflow, ie something that puts system in dead state, generates a popup dialog that user sees
- [] right now iprep_image puts the lastcompleted step at image, think about if you want to do this. it does allow manipulation of where workflow picks up
- [] consistencychecks should not be done by calling workflow object, but instead should be done through mediator


*** imaging ***
- [] order of images in 3D stack is reversed
- [] starting iprep_image from menu increases slice number. it is not supposed to do that
- [x] create factory class for image sequence for multiple ROIs
- [x] find a way to make sure that image step does not cause dead state when that is not really needed
- [] create a 3D volume stack manager that can be properly initialized and resumed
- [x] 3D stack: every ROI needs a stack. a manager returns a handle to the right stack by name. name of stack is name of ROI. these all need to be initialized. when they are closed they remain closed until re-initialized manually (for now). size of each stack is the same and is set by a global tag
- [x] 3D stack: init 3D stack as part of init method of device sequences. the sequence will init the right sequence. 
- [] 3D stack: when initting a stack, don't open a new one every time system resumes. check if it is already open and if it is, use it if the details fit. this can be handled by VolumeManager. 

*** UI ***
- [x] add iprep autofocus as a menu item
- [] move long function implementations from iprep_ui; these belong un iprep_main
- [x] add function that gives a string popup and asks user to save current SEM position under given name
- [] list all current SEM positions
- [x] list all current ROIs

*** gripper ***
- [] fix bug in open/close once: if gripper does not move, it won't work this way

*** digiscan ***
- [x] find way to configure digiscan with parameters from ROI object. can be done both nicely and hacky. 
- [] make class compatible with acquiring 2 signals simultaneously by doing the parameter configuration in config method 

*** BING Bugs ***
- [x] we cannot read argon setpoint, only flow. this causes long term drift when setting it back after transfers. need fix
- [x] go to etch does not work when having stage lowered manually beforehand. then it somehow uses coating parameters and messes up milling time remaining -(needs testing)
- [] there are still problems with go to etch/go to coat. stage does not always move and guns do not always go to right angle
- [] millingtimeremaining() is not working in coat mode


*** SW DM IPrep Bugs ***
- [] changing directory where data gets saved does not affect running process
- [] we no longer want to trigger on max slices to stop workflow
- [] make sure to grey out stop/pause after it is pressed so that we cannot resume before the actual pause has happened. this now causes problems since it calls script functions that are not supposed to be called until system is idle. 

*** alignment ***
- all this goes to iprep_alignment.s, a different file
- [] add a function to change ROI alignment by a standard vector (ie StoredImaging) due to crash
- the 'default' values after calibration should be in tags, not hardcoded. now the current value used is stored in tags
(1)- store calibration values for SEM (scribe_pos_ebsd, scribe_pos_planar, reference_ebsd, reference_planar) and parker (pickup_dropoff_ebsd, pickup_dropoff_planar) in (sem position and numeric) tags. these do NOT change except when alignment changes. 
(2)- store vectors for SEM coordinates (ie where is highgridfront with respect to scribe_pos? where is clear with respect to reference?) in (sem position)tags. these get applied when IPrep calibration routines are ran
(3)- store values used by workflow routines in tags. the workflow uses these and does not know of ebsd/planar. these tags do not get changed except by IPrep calibration routines. 
notes:
- no values are hardcoded in code; the vectors (2) can change manually, the calibration values can change (1), but (3) is always found by applying (2) to (1) in a controlled routine that can be ran as often as needed
- the vectors (2) and the calibration values (1) have default values that can be set by running a function. 


*** legacy ***
general improvements that are scheduled to be done in this branch:
(dock/gripper)-send allmotion configuration
(workflow)-changing tags during transfer creates consistency problems
(workflow)-system assumes that calibrateformode (which sets positions parker) is run before doing an initial transfer, which is different from how the SEM coordinates are set. change this t obe like SEM
(workflow)-iprep_init should not overwrite the parker_positions
(workflow)-calibrateformode: mode is only read after setting parkerpositions, this needs to be switched around
(workflow/sem)-we incorrectly reset focus to value used in nominal_imaging. need to rewrite the stuff with saving workflows in sem class.








