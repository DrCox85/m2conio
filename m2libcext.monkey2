' Extended libc
' By @Hezkore 2018
' https://github.com/Hezkore/m2libcext

' Make sure you build this as the "Console" type
' Ted2Go does not register any of this
' So you'll need to run this from your 'products' folder

#Import "<std>"
#Import "<libc>"
Using std..
Using libc..

Extern
	Function getc:Int( stream:FILE Ptr )
Public

Function Main()
	
	Print "Hello!"
	
	Local usrInput:String
	While usrInput.Length<=0
		Printf("Write something> ")
		usrInput=Input()
	Wend
	
	Printf("You wrote: ")
	Print(usrInput)
	
	WaitKey()
	Printf("Bye!")
	Sleep(1)
End

Function Printf( text:String )
	fputs( text, libc.stdout )
	fflush( libc.stdout )
End

Function WaitKey( text:String="~nPress Return key to continue..." )
	Printf(text)
	Local key:Int
	fread( Varptr key, 1, 1, libc.stdin )
	Return
End

Function Input:String()
	Local inp:Int
	Local result:String
	
	While True
		inp=getc( libc.stdin )
		If inp Then
			If inp=10 Then
				Exit
			Else
				result+=String.FromChar( inp )
			Endif
		Endif
	Wend
	
	Return result
End