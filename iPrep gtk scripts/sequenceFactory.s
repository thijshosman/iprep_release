// creates sequences

object createSequence(string type)
{
	if(type == "reseat_default")
		return alloc(reseatSequenceDefault)
	else if (type == "semToPecs_default")
		return alloc(semtopecsSequenceDefault)
	else if (type == "pecsToSem_default")
		return alloc(pecstosemSequenceDefault)
	else
		return alloc(transferSequence) // simulator

}



