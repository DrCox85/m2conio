
' Monkey2 Terminal console
' By @Hezkore 2018
' https://github.com/Hezkore/m2libcext

Namespace m2libcext

#Import "<libc>"
Using libc..

Global Console:ConsoleHandler

#If __TARGET__="windows"
	#Import "<windows.h>"
	Extern
		Alias HANDLE:Void Ptr
		Function SetConsoleMode( hConsoleHandle:HANDLE, dwMode:UInt )
		Function GetStdHandle:HANDLE( nStdHandle:UInt )
		Function GetLastError:UInt()
	Public
#End

Extern
	Function getc:Int( stream:FILE Ptr )
Public

Struct ConsoleHandler
	
	Struct Color
		
		Const Black:=New Color( 30 )
		
		Const Red:=New Color( 31 )
		
		Const Green:=New Color( 32 )
		
		Const Yellow:=New Color( 33 )
		
		Const Blue:=New Color( 34 )
		
		Const Magenta:=New Color( 35 )
		
		Const Cyan:=New Color( 36 )
		
		Const White:=New Color( 37 )
		
		Field id:UByte
		
		Method New( id:UByte )
			Self.id=id
		End
		
	End
	
	Property Foreground:Color()
		Return _foreground
	Setter( color:Color )
		If _foreground=color Then Return
		_foreground=color
		
		ApplyForeground()
	End
	
	Property ForegroundBold:Bool()
		Return _boldForeground
	Setter( bold:Bool )
		If _boldForeground=bold Then Return
		_boldForeground=bold
		
		ApplyForeground()
	End
	
	Property ForegroundUnderline:Bool()
		Return _underlineForeground
	Setter( underline:Bool )
		If _underlineForeground=underline Then Return
		_underlineForeground=underline
		
		ApplyForeground()
	End
	
	Property Background:Color()
		Return _background
	Setter( color:Color )
		If _background=color Then Return
		_background=color
		
		ApplyBackground()
	End
	
	Property BackgroundBold:Bool()
		Return _boldBackground
	Setter( bold:Bool )
		If _boldBackground=bold Then Return
		_boldBackground=bold
		
		ApplyBackground()
	End
	
	Property SupportsColor:Bool()
		
		CheckColorSupport( False )
		Return _supportsColor
	End
	
	Method Negative()
		
		CheckColorSupport()
		
		If _supportsColor Then Write(String.FromChar(27)+"[7m")
	End
	
	Method Positive()
		
		CheckColorSupport()
		
		If _supportsColor Then Write(String.FromChar(27)+"[27m")
	End
	
	#rem monkeydoc Resets foreground and background color.
	#end
	Method ResetColors()
		
		ResetForeground()
		ResetBackground()
	End
	
	#rem monkeydoc Resets foreground color.
	#end
	Method ResetForeground()
		
		_foreground.id=39
		_boldForeground=False
		_underlineForeground=False
		
		ApplyForeground()
	End
	
	#rem monkeydoc Resets background color.
	#end
	Method ResetBackground()
		
		_background.id=39
		_boldBackground=False
		
		ApplyBackground()
	End
	
	#rem monkeydoc Print without a new line at the end.
	#end
	Method Write( text:String, nl:Bool=False )
		If nl Then text=text+"~n"
		fputs( text, libc.stdout )
		fflush( libc.stdout )
	End
	
	#rem monkeydoc Pause application until <Key> has been pressed.
	#end
	Method WaitKey( text:String="~nPress Return key to continue..." )
		
		Write(text)
		
		Local key:Int
		fread( Varptr key, 1, 1, libc.stdin )
		
		Return
	End
	
	#rem monkeydoc Pause application and let the user input text.
	#end
	Method Input:String()
		
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
	
	#rem monkeydoc Make a bell sound.
	#end
	Method Bell()
		fputs( String.FromChar(7), libc.stdout )
	End
	
	Private
		Method CheckColorSupport:Bool( verbose:Bool=True )
			If _doneSupportColorTest Then Return _supportsColor
			_doneSupportColorTest=True
			
			' Attempt to get the STD handle...
			Local hOut:=GetStdHandle( -11 )
			If Int(hOut)=-1 Or GetLastError() Then
				If verbose Then Print "Unable to get handle for this console"
				_supportsColor=False
				Return _supportsColor
			Endif
			
			' Attempt to set the console mode...
			SetConsoleMode( hOut, 5 )
			If GetLastError() Then
				If GetLastError()=6 Then
					If verbose Then Print "This console does not support color"
					_supportsColor=False
					Return _supportsColor
				Else
					If verbose Then Print "Unable to enable color on this console"
					_supportsColor=False
					Return _supportsColor
				Endif
			Endif
			
			' Colors are supported!
			ResetColors()
			
			_supportsColor=True
			Return _supportsColor
		End
		
		Method ApplyForeground()
			
			CheckColorSupport()
			
			If _supportsColor Then
				If _boldForeground And _foreground.id>=30 And _foreground.id<38 Then
					Write(String.FromChar(27)+"["+(_foreground.id+60)+"m")
				Else
					Write(String.FromChar(27)+"["+_foreground.id+"m")
				Endif
				
				If _underlineForeground Then
					Write(String.FromChar(27)+"[4m")
				Else
					Write(String.FromChar(27)+"[24m")
				Endif
				
			Endif
		End
		
		Method ApplyBackground()
			
			CheckColorSupport()
			
			If _supportsColor Then
				If _boldBackground And _background.id>=30 And _background.id<38 Then
					Write(String.FromChar(27)+"["+(_background.id+70)+"m")
				Else
					Write(String.FromChar(27)+"["+(_background.id+10)+"m")
				Endif
			Endif
		End
		
		Field _foreground:Color
		Field _boldForeground:Bool
		Field _underlineForeground:Bool
		Field _background:Color
		Field _boldBackground:Bool
		
		Field _supportsColor:Bool
		Field _doneSupportColorTest:Bool
		
	Public
End