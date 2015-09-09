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

}





