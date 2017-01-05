
This file describes what all the todos are for the demounit master development branch. 

### for manchester ###
* [] finish alignment steps

* [x] implement new EBSD methods
	* [x] need tags under iprep:EBSD for: type (ebsd or eds or electron), sitename as setup in OI, data prefix (to be used as prefix). all under IPrep:EBSD:

* [] allow mediator to print out a list of common states for later use in UI dialog that reflects state of subsystems
* [x] consistencychecks should not put system in dead/unsafe state; you are just checking for issues that prevent a run. when something goes wrong during workflow, system gets put in unsafe state, and user can figure out what to do. we just check for the unsafe flag before starting/resuming and we ensure that the big check and little check pass
	* [x] big check checks consistencies when resuming/starting
	* [x] little check checks common problems (tmp, argon etc) every iteration
	* [] consistencychecks should not be done by calling workflow object, but instead should be done through mediator, perhaps.

* [] main: ensure that sem is in clear and move it there if not. may not be needed
* [] main: start/resume should reinit sequences used to reflect changes (and possibly re-init the 3D volumes)
* [] main: checks when resuming/starting need cleaning up 
* [] main: home SEM stage to clear as part of workflow to prevent problems after pressing start button, but only if not imaging
* [] main: if max slices is reached already and workflow has started, it still gets to running mode; needs a check
* [] main: NB: all dead/unsafe setting happens in main, not state machine. the state machine just returns values (0,1,-1). the main functions need some proper sculpting to now put the system in a dead/unsafe state needlessly
* [] main: when a 'soft' error happens (ie return 0) in workflow (ie milling precondition not met) system should pause workflow. may require change to how DM handles pause/start/stop events
* [] main: we want to make sure that an error during the workflow, ie something that puts system in dead state, generates a popup dialog that user sees
* [] main: right now iprep_image puts the lastcompleted step at image, think about if you want to do this. it does allow manipulation of where workflow picks up

* [] 3D stack: it always opens one for after milling and before milling. this should only happen if they are actually enabled
* [] 3D stack: when workflow starts (but not resumes), check that all 3D stacks are correctly based on the current acquisition data. right now, they 		are initialized (but not shown) when the workflow initializes because that is easy, but that is wrong. create a function init_3d_stacks() based on 		what is enabled, infer image sizes from digiscan tags/capture settings and init some 3d volumes. call this function when iprep_start() is executed
	ROIManager will be able to return all enabled ROIs and signals. This is known when IPrep_startrun is called (this function inits the statemachine (again, already happened in iprepinit, but just in case something changed)), so we can at this moment create a list of all ROIs and signals (format TBD). iprepstart will (re-)init the 3d volumes and show them. iprepresume will only show them. 3d volume init happens in sequence config. so all we need is a way for the sequence to know, at config time, which 3d volumes to enable and how to find them. best is probably to use a list with objects that only contain a string. this means: 3dvolumemanager looks at roimanager and infers this object list. we use a hash to combine roiname and signalname
* [] 3D stack: now init all rois clears list, pecs images/sequence init has to be executed AFTER sem images init. fix this

* [] UI: list all current SEM positions
* [] UI: in order to ensure everything does not run in the main DM thread, fire a thread for each UI menu call

* [] have an IPrep taggroup for default digiscan parameters. use this instead of the global one since that one does not exist on systems without digiscan isntalled (which needs to work as simulator, on ie my laptop)

* [] rewrite all file names in gtk dir to have proper name space etc

*** bugs ***
- [] when PECS has rebooted, check connection before starting workflow. now it still sort of runs but pops up messages in the meantime with that it failed to talk to PECS. can be dangerous
- [] image sequence turns top illuminators off. this is probably wrong. 
- [] rethink locking out the PECS UI at the end of milling vs at the beginning of transfer
- [] when changing capture settings in DM, you have to press 'capture' button before this becomes the capture setting returned by DSGetWidth( paramID ). iprep image sequence does not need initialization when settings change
- [] when PECS reboots, we have a strange situation in which somehow the workflow still communications but still throws an exception somewhere that prevents it from continuing the workflow
- [] some commands lock the UI thread in DM (gripper etc), no logic behind it that is oberservable. needs to be fixed
- [] when pausing during a long acquisition, acquisition (sometimes?) aborts and system pauses. this should not happen
- [] for some reason, the quantamagbugfix does not like it when it is being used when the mag is already very low
- [] starting iprep_image from menu increases slice number. it is not supposed to do that

*** general/helper ***
- [x] the persistance classes need to throw a readable exception when a tag is not found to facilitate easy fixes on systems that do not have all the tags. 

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
- [] migrate imaging position check so that you don't go there twice to sem class itself

*** dock ***:
- [x] set holding torque during transfer when opens so that we don't have the thing close as it is picked up or the arm comes in (planar only for now)
- [] allow chamberscope camera on/off -> needs hardware fix? 

*** general linearworkflow/state machine/device transfer sequences ***
- [x] make a class for 'transfers' and make an object for each transfer that defines it instead of hardcoding it in 
- [x] linearworkflow class. linearworkflow would invoke the 'do' method in this command-like pattern. this is more flexible than what we have now. we can lateron even go to a script-like 
- [x] migrate transfer stuff over to this class and create factory to create sequences
- [x] also migrate imaging/ebsd/eds to sequence class
- [x] migrate coating and etching to transfer sequence class
- [x] use return 0/1/-1 instead of throwing exceptions from state machine. rewrite corresponding iprep_main methods. update ui to use dead/unsafe checks
- [x] make sure that non-irrecoverable errors from state machine get processed in main in a different way than true irrecoverable errors. now they are treated the same
- [x] migrate 2 ROI example to a proper sequence
- [x] create a way to manually/dynamically load sequences in state machine. right now state machine loads default sequences and menu items can change them. it would be better if there were a way to dynamically load a sequence defined by a tag when the state machine initializes and a menu item that loads the tag and reinits the state machine
- [x] after dock swap, set a flag that does not allow movement until iprep_scribemarkervectorcorrection has been run
- [] how can we run custom methods on a particular sequence to set it up? pecs imaging is going to use the name of the object as initialized as the folder to save pecs images in

*** setup ***
- [x] stop using IPrep_Setup_Imaging(), is now redundant

*** multi ROI ***
- [x] we need a way to iterate over ROIs. the most logical thing would be to use the subtag for all ROIs that labels them as 'enabled'. the sequence method would then just iterate over all of them. use example robin. 
- [x] update roimanager to return all enabled rois
- [x] put a little more thought into autofocusing. every ROI needs a 'autofocus every n slices' number and query the active slice number to see if it needs to trigger that. if so, for now it is the image sequences responsibility to visit this ROI to actually do it. add this subtag to the ROI/ROImanager class
- [x] replace ROImanager convertTagToROI with initROIFromTag in ROI object. much cleaner
- [x] find a way to put order in ROI and have ROI manager order them when returning them
- [x] ability to autofocus every x slices, and always autofocus when start is pressed
- [x] allow AF on separate ROI every n slices without imaging any of the other times


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
- [x] issue stop_milling command before starting workflow just to be safe. 
- [x] add method to dynamically load an image sequence and init it (in state machine). the others do not change as often so they can use the regular init if needed
- [x] add a tag to each image with iprep information (roi name, sem position name, milling time, voltage, angle (if possible))
- [x] run restoregasflow when safetyflags get reset
- [x] allow skipping of everything, including transfers, in workflow with tags


*** imaging ***
- [] order of images in 3D stack is reversed
- [x] create factory class for image sequence for multiple ROIs
- [x] find a way to make sure that image step does not cause dead state when that is not really needed
- [x] create a 3D volume stack manager that can be properly initialized and resumed
- [x] 3D stack: every ROI needs a stack. a manager returns a handle to the right stack by name. name of stack is name of ROI. these all need to be initialized. when they are closed they remain closed until re-initialized manually (for now). size of each stack is the same and is set by a global tag
- [x] 3D stack: init 3D stack as part of init method of device sequences. the sequence will init the right sequence. 
- [x] 3D stack: when initting a stack, don't open a new one every time system resumes. check if it is already open and if it is, use it if the details fit. this can be handled by VolumeManager. 
- [x] 3D stack: all init methods to factory, not volume class. class should know nothing of rois
- [x] 3D stack: open a different stack for each signal if 2 signals are acquired in digiscan. 
- [x] IPrep tag on each image. contains information on: entire ROI tag, focus, slice number
- [x] exhaustively test 3d volume manager with multiple rois and signals
- [x] make sure 3dvolumemanager initializes all rois for all signals
- [] make EBSD a special condition of imaging, not a separate step. allow only 1 EBSD ROI. details to follow
- [] name all EBSD functions to new ones from Mingkai


*** UI ***
- [x] add iprep autofocus as a menu item
- [] move long function implementations from iprep_ui; these belong un iprep_main
- [x] add function that gives a string popup and asks user to save current SEM position under given name
- [x] list all current ROIs
- [x] no more quanta bug fix when just moving in x and y in sem alignment functions
- [] switching image mode (ie single ROI, multi ROI) needs to update newest added tags in ROI elements and put them in the right place (ie enabled, af, etc). just check, may already work well because of how roifactory works


*** SEM ***
- [x] when sem stage is already at a location, don't go there again
- [] add internal checks in moving between SEM states that allows us to go to different imaging states directly from Clear, not first to nominal_imaging

*** gripper ***
- [] fix bug in open/close once: if gripper does not move, it won't work this way

*** digiscan ***
- [x] find way to configure digiscan with parameters from ROI object. can be done both nicely and hacky. 
- [x] make class compatible with acquiring 2 signals simultaneously by doing the parameter configuration in config method. keep in mind: same settings for each ROI. digiscan class looks at capture settings to get names/signals enabled/disabled and uses it for EACH ROI, not just storedimaging in single image mode

*** BING Bugs ***
- [x] we cannot read argon setpoint, only flow. this causes long term drift when setting it back after transfers. need fix
- [x] go to etch does not work when having stage lowered manually beforehand. then it somehow uses coating parameters and messes up milling time remaining -(needs testing)
- [] there are still problems with go to etch/go to coat. stage does not always move and guns do not always go to right angle
- [] millingtimeremaining() is not working in coat mode


*** SW DM IPrep Bugs ***
- [] changing directory where data gets saved does not affect running process
- [] we no longer want to trigger on max slices to stop workflow
- [] make sure to grey out stop/pause after it is pressed so that we cannot resume before the actual pause has happened. this now causes problems since it calls script functions that are not supposed to be called until system is idle. 

*** alignment 2.0 ***

Overview:

(1)- store calibration_coordinates for SEM (scribe_pos_ebsd, scribe_pos_planar, reference_ebsd, reference_planar) and parker (pickup_dropoff_ebsd, pickup_dropoff_planar) in (sem position and numeric) tags. these do NOT change except when alignment changes. these coordinates are determined upon initial alignment (manually moving parker in, figuring out on planar dock what the sem coordinates are to get the scribe mark in the center of the FOV)
(2)- store mode_vectors for SEM coordinates (ie where is highgridfront with respect to scribe_pos? where is clear with respect to reference?) in (sem position) tags. these are used to reference all workflow coordinates to calibration coordinates. there will be one vector for each workflow coordinate for each mode (so a vector for nominal_imaging for both planar and ebsd mode, for example). these vectors generally don't change. 
(3)- workflow coordinates are used by sequences. the workflow uses these and does not know of ebsd/planar. these tags do not get changed except by IPrep calibration routines. 

functions: 
apply_mode_vectors_EBSD() // apply mode_vectors for EBSD dock to calibration_coords (1). overwrites all workflow coordinates (3). parker coordinates get set directly to alignment vectors. 



apply_mode_vectors_Planar() // apply mode_vectors for Planar dock to calibration_coords (1). overwrites all workflow coordinates (3) and parker coordinates. 

determine_reinsertion_vector() // determine vector (x,y) of shift based on moving scribe mark. right now it will simply be a result of a shift in x and y of one scribe mark, but later this can be more complicated and use 2 points to also take care of rotation. 
apply_reinsertion_vector() // apply the resinsertion_vector directly to the workflow coordiantes (3)



use cases:

initial alignment: 
(1) gets set manually, then (3) gets calculated by applying (2)

dock put on stage again after being removed:
(1) gets determined by dock/user queries. go to scribe mark calibration_coord. user gets asked to locate scribe mark in image and reinsertion_vector gets calculated. this vector is applied to (3) directly

dock swap from EBSD to Planar:
dock is removed (or is already removed). new dock is put in system. (1) is determined by dock/user queries. (1) gets set to correct values based on dock. user gets asked to locate scribe mark and reinsertion_vector gets calculated. (2) gets applied to (1) to find (3). reinsertion_vector gets applied to (3)


additional notes:
- no values are hardcoded in code; the vectors (2) can change manually, the calibration values can change (1), but (3) is always found by applying (2) to (1) in a controlled routine that can be ran as often as needed. 
- the vectors (2) and the calibration values (1) have default values that can be set by running a function. 
- nothing is applied automatically when something inits or dm starts. (3) only changes when:
	-dock removal/reinsertion (reinsertion_vector)
	-dock swap (changes back to (2) applied to (1) for correct mode plus reinsertion_vector)
	-set back to default ( (2) applied to (1) for correct mode)




*** legacy ***
general improvements that are scheduled to be done in this branch:
(dock/gripper)-send allmotion configuration
(workflow)-changing tags during transfer creates consistency problems
(workflow)-system assumes that calibrateformode (which sets positions parker) is run before doing an initial transfer, which is different from how the SEM coordinates are set. change this t obe like SEM
(workflow)-iprep_init should not overwrite the parker_positions
(workflow)-calibrateformode: mode is only read after setting parkerpositions, this needs to be switched around
(workflow/sem)-we incorrectly reset focus to value used in nominal_imaging. need to rewrite the stuff with saving workflows in sem class.








