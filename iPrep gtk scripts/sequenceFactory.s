// creates sequences

object createSequence(string type)
{
	if(type == "reseat_default")
		return alloc(reseatSequenceDefault)
	else if (type == "semToPecs_default")
		return alloc(semtopecsSequenceDefault)
	else if (type == "pecsToSem_default")
		return alloc(pecstosemSequenceDefault)
	//else if (type == "image_single")
	//	return alloc()
	//else if (type == "image_2_ROIs")
	//	return alloc()		
	//else if (type == "mill_default")
	//	return alloc()
	//else if (type == "mill_coat")
	//	return alloc()
	//else if (type == "EBSD_default")
	//	return alloc()	
	//else if (type == "simulator")
	//	return alloc(testSequence)
	else
		throw("trying to generate sequence that does not exist")
		//return alloc(transferSequence) // simulator

}



