
' Make sure you build this as the "Console" type
' Ted2Go does not register any of this
' So you'll need to run this from your 'products' folder

#Import "<std>"
Using std..

#Import "../m2libcext"
Using m2libcext..

Function Main()
	
	Print "Hello!"
	
	Local usrInput:String
	While usrInput.Length<=0
		PrintNO("Write something> ")
		usrInput=Input()
	Wend
	
	PrintNO("You wrote: ")
	Print(usrInput)
	
	WaitKey()
	PrintNO("Bye!")
	Sleep(1)
End