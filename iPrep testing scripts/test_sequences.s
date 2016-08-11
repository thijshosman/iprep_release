// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

result("starting execution" + "\n")

try
{

	// testsequence generated directly
	//object aTestSequence = alloc(testSequence)
	//aTestSequence.init("myTest",myWorkflow)
	//aTestSequence.do()

	// *** generating a sequence ***
	
	// testsequence generated with factory
	object aTestSequence = createSequence("simulator")
	
	// init it and give it a name
	aTestSequence.init("test",myWorkflow)
	
	// run it
	aTestSequence.do()

	// *** test generating all sequences
	object seq1 = createSequence("semToPecs_default")
	seq1.init("sequence1",myWorkflow)
	object seq2 = createSequence("pecsToSem_default")
	seq1.init("sequence1",myWorkflow)

}

catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")

