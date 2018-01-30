
' Monkey2 Libc extension
' By @Hezkore 2018
' https://github.com/Hezkore/m2libcext

Namespace m2libcext

#Import "<libc>"
Using libc..

Extern
	Function getc:Int( stream:FILE Ptr )
Public

#rem monkeydoc Print but without a new line at the end.
#end
Function PrintNO( text:String )
	
	fputs( text, libc.stdout )
	fflush( libc.stdout )
End

#rem monkeydoc Pause application until <Key> has been pressed.
#end
Function WaitKey( text:String="~nPress Return key to continue..." )
	
	PrintNO(text)
	
	Local key:Int
	fread( Varptr key, 1, 1, libc.stdin )
	
	Return
End

#rem monkeydoc Pause application and let the user input text.
#end
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