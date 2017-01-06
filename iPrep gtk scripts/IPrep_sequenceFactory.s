// $BACKGROUND$
// creates sequences

object createSequence(string type)
{
	if(type == "reseat_default")
		return alloc(reseatSequenceDefault)
	else if (type == "semToPecs_default")
		return alloc(semtopecsSequenceDefault)
	else if (type == "pecsToSem_default")
		return alloc(pecstosemSequenceDefault)
	else if (type == "image_single") // fixed single roi
		return alloc(image_single)
	else if (type == "image_double") // fixed double roi
		return alloc(image_double)		
	else if (type == "mill_default")
		return alloc(mill_default)
	else if (type == "coat_default")
		return alloc(coat_default)
	else if (type == "EBSD_default")
		return alloc(EBSD_default)	
	else if (type == "PECSImageDefault")
		return alloc(PECSImageDefault)
	else if (type == "image_iter")
		return alloc(image_iter)
	else if (type == "simulator")
		return alloc(testSequence)
	else
		// alloc one with this standard name and see if it works
		return alloc(""+type)

	//throw("trying to generate sequence "+type+" that does not exist")
	//return alloc(transferSequence) // simulator

}



