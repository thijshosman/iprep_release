// creates sequences

object createSequence(string type)
{
	if(type == "reseat_default")
		return alloc(reseatSequenceDefault)
	else if (type == "semToPecs_default")
		return alloc(semtopecsSequenceDefault)
	else if (type == "pecsToSem_default")
		return alloc(pecstosemSequenceDefault)
	else if (type == "image_single")
		return alloc(image_single)
	//else if (type == "image_2_ROIs")
	//	return alloc()		
	else if (type == "mill_default")
		return alloc(mill_default)
	else if (type == "coat_default")
		return alloc(coat_default)
	else if (type == "EBSD_default")
		return alloc(EBSD_default)	
	else if (type == "simulator")
		return alloc(testSequence)
	else
		throw("trying to generate sequence "+type+" that does not exist")
		//return alloc(transferSequence) // simulator

}



