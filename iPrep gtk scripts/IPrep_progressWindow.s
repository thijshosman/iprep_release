// no background
// $BACKGROUND$

class progressWindow: object
{

	string A, B, C

	void flip(object self)
	{
		OpenAndSetProgressWindow(A,B,C)
	}

	void progressWindow(object self)
	{
		A = ""
		B = ""
		C = ""
		self.flip()
	
	}
	
	void updateA(object self, string update)
	{
		A = update
		self.flip()
	}

	void updateB(object self, string update)
	{
		B = update
		self.flip()
	}

	void updateC(object self, string update)
	{
		C = update
		self.flip()
	}

	void updatePW(object self, string update)
	{
		// for mediator
		self.updateC(update)
	}

}

// convention for use progress window:

// A: where is sample

// B: what is current state of active device

// C: what is slice number


