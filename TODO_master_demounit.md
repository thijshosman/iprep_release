
This file describes what all the todos are for the demounit master development branch. 

*** general/helper ***

- [x] the persistance classes need to throw a readable exception when a tag is not found to facilitate easy fixes on systems that do not have all the tags. 

*** parkertransfer ***:

- [x] allow homing to happen in the wrong direction. 
- [] direction should be in a tag so that iprep can use it either way, also for normal positions

*** pecs ***:

- [x] add new shutter and argon functions to simulator
- [x] gate valve: check sensors before issuing open/close to speed up workflow
- [x] check state shutter coating sensor
- [x] tmp check can fail due to unterminated rs485. add redundancy
- [x] set a flag that is used for shutoff gas flow to make sure it never gets executed twice and 0 gets remembered

*** SEM ***:

- [] prevent sem from moving 
- [] have a way to check that z-height is set (for example by moving 10 micron in z and seeing if it throws an exception?) -> checkFWDCoupling in sem
- [] correct for drift in survey image, set maximum shift parameter and don't move but continue workflow if shift exceeds this


*** dock ***:

- [x] set holding torque during transfer when opens so that we don't have the thing close as it is picked up or the arm comes in (planar only for now)
- [] allow chamberscope camera on/off -> needs hardware fix? 

*** linearworkflow ***

- [] make a class for 'transfers' and make an object for each transfer that defines it instead of hardcoding it in 
- [] linearworkflow class. linearworkflow would invoke the 'do' method in this command-like pattern. this is more flexible than what we have now. we can lateron even go to a script-like 
- [] migrate everything over to this class and create factory to create sequences

*** workflow ***

- [] we want to make sure that an error during the workflow, ie something that puts system in dead state, generates a popup dialog that user sees
- [] right now iprep_image puts the lastcompleted step at image, think about if you want to do this. it does allow manipulation of where workflow picks up
- [] consistencychecks should not be done by calling workflow object, but instead should be done through mediator
- [x] don't check dock mode at iprep_init as this prevents dock swap when dm is offline
- [x] when a dock is no present, iprep_init throws exception and does not fully load
- [x] beam does not blank
- [x] beam does not focus on storedimaging after transfer
- [x] af_mode is set by setup_imaging to 2 so that workflow uses the fixed value. for autofocus, this needs to be 1. 
- [] ability to autofocus every x slices
- [x] when pausing during milling, it pauses, but then when resuming it mills again
- [] do we really want the state machine to throw exceptions when asked to go start milling/ebsd/etc when that is prohibited? think about it. 
- [] when a transfer starts, check for consistency beforehand
- [] home SEM stage to clear as part of workflow to prevent problems after pressing start button
- [] after dock swap, set a flag that does not allow movement until iprep_scribemarkervectorcorrection has been run
- [] do not give warnings for pecs stage in raised or lowered position; only argon
- [] fix pressing resume after pressing pause before it actually pauses. this causes bug
- [] if max slices is reached already and workflow has started, it still gets to running mode; needs a check
- [] order if images in 3D stack is reversed
- [] starting iprep_image from menu increases slice number. it is not supposed to do that

*** UI ***

- [] move long function implementations from iprep_ui; these belong un iprep_main
- [x] add iprep autofocus as a menu item

*** gripper ***

- [] fix bug in open/close once: if gripper does not move, it won't work this way

*** digiscan ***

- [] find way to configure digiscan with parameters from ROI object. can be done both nicely and hacky. 

*** BING Bugs ***

- [] we cannot read argon setpoint, only flow. this causes long term drift when setting it back after transfers. need fix
- [x] go to etch does not work when having stage lowered manually beforehand. then it somehow uses coating parameters and messes up milling time remaining -(needs testing)



*** SW DM IPrep Bugs ***

- [] changing directory where data gets saved does not affect running process
- [] no longer trigger on max slices to stop workflow
- [] make sure to grey out stop/pause after it is pressed so that we cannot resume before the actual pause has happened. this now causes problems since it calls script functions that are not supposed to be called until system is idle. 

*** alignment ***


- all this goes to iprep_alignment.s, a different file
- [] add a function to change ROI alignment by a standard vector (ie StoredImaging) due to crash

- the 'default' values after calibration should be in tags, not hardcoded. now the current value used is stored in tags, but is overridden with what is in the code upon iprep_init runs
(1)- store calibration values for SEM (scribe_pos_ebsd, scribe_pos_planar, reference_ebsd, reference_planar) and parker (pickup_dropoff_ebsd, pickup_dropoff_planar) in (sem position and numeric) tags. these do NOT change except when alignment changes. 
(2)- store vectors for SEM coordinates (ie where is highgridfront with respect to scribe_pos? where is clear with respect to reference?) in (sem position)tags. these get applied when IPrep calibration routines are ran
(3)- store values used by workflow routines in tags. the workflow uses these and does not know of ebsd/planar. these tags do not get changed except by IPrep calibration routines. 
notes:
- no values are hardcoded in code; the vectors (2) can change manually, the calibration values can change (1), but (3) is always found by applying (2) to (1) in a controlled routine that can be ran as often as needed
- the vectors (2) and the calibration values (1) have default values that can be set by running a function. 


general improvements that are scheduled to be done in this branch:
(dock/gripper)-send allmotion configuration
(workflow)-changing tags during transfer creates consistency problems
(workflow)-system assumes that calibrateformode (which sets positions parker) is run before doing an initial transfer, which is different from how the SEM coordinates are set. change this t obe like SEM
(workflow)-iprep_init should not overwrite the parker_positions
(workflow)-calibrateformode: mode is only read after setting parkerpositions, this needs to be switched around
(workflow/sem)-we incorrectly reset focus to value used in nominal_imaging. need to rewrite the stuff with saving workflows in sem class.







