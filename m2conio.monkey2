
' Monkey2 Console I/O module
' By @Hezkore 2018
' https://github.com/Hezkore/m2libcext

Namespace m2conio

#Import "<std>"
#Import "<libc>"
Using libc..
Using std.filesystem

Global Console:ConsoleHandler

#If __TARGET__="windows"
	#Import "<windows.h>"
	#Import "<conio.h>"
	
	Extern
		Alias HANDLE:Void Ptr
		Function SetConsoleMode( hConsoleHandle:HANDLE, dwMode:UInt )
		Function GetStdHandle:HANDLE( nStdHandle:UInt )
		Function GetLastError:UInt()
	Public
#Else
	#Import "native/posix_input.h"
	#Import "native/posix_input.cpp"
#End

Extern
	Function kbhit:Int()
	Function getch:Int()
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
	
	#rem monkeydoc Text foreground color.
	Uses Ansi coles.
	#end
	Property Foreground:Color()
		Return _foreground
	Setter( color:Color )
		If _foreground=color Then Return
		_foreground=color
		
		ApplyForeground()
	End
	
	#rem monkeydoc Use bold/bright foreground colors.
	#end
	Property ForegroundBold:Bool()
		Return _boldForeground
	Setter( bold:Bool )
		If _boldForeground=bold Then Return
		_boldForeground=bold
		
		ApplyForeground()
	End
	
	#rem Not often properly supported
	Property ForegroundUnderline:Bool()
		Return _underlineForeground
	Setter( underline:Bool )
		If _underlineForeground=underline Then Return
		_underlineForeground=underline
		
		ApplyForeground()
	End
	#end
	
	#rem monkeydoc Text background color.
	Uses Ansi coles.
	#end
	Property Background:Color()
		Return _background
	Setter( color:Color )
		If _background=color Then Return
		_background=color
		
		ApplyBackground()
	End
	
	#rem monkeydoc Use bold/bright background colors.
	#end
	Property BackgroundBold:Bool()
		Return _boldBackground
	Setter( bold:Bool )
		If _boldBackground=bold Then Return
		_boldBackground=bold
		
		ApplyBackground()
	End
	
	#rem Are Ansi codes supported?
	#end
	Property SupportsAnsi:Bool()
		
		CheckAnsiSupport( False )
		Return _supportsAnsi
	End
	
	#Rem Hardly ever supported properly
	Method Negative()
		
		CheckColorSupport()
		
		If _supportsColor Then AnsiColor( 7 )
	End
	
	Method Positive()
		
		CheckColorSupport()
		
		If _supportsColor Then AnsiColor( 27 )
	End
	#end
	
	#rem monkeydoc Send raw Ansi color code.
	ESC[<color>m
	#end
	Method AnsiColor( color:UByte )
		
		Ansi( "["+color+"m")
	End
	
	#rem monkeydoc Send raw Ansi code.
	#end
	Method Ansi( code:String )
		
		fputs( String.FromChar(27)+code, libc.stdout )
	End
	
	#rem monkeydoc Reset foreground and background color.
	#end
	Method ResetColors()
		
		ResetForeground()
		ResetBackground()
	End
	
	#rem monkeydoc Reset foreground color.
	#end
	Method ResetForeground()
		
		_foreground.id=39
		_boldForeground=False
		_underlineForeground=False
		
		ApplyForeground()
	End
	
	#rem monkeydoc Reset background color.
	#end
	Method ResetBackground()
		
		_background.id=39
		_boldBackground=False
		
		ApplyBackground()
	End
	
	#rem monkeydoc Write to the console.
	'nl' parameter is for appending new line.
	#end
	Method Write( text:String, nl:Bool=False )
		
		If nl Then text=text+"~n"
		
		fputs( text, libc.stdout )
		fflush( libc.stdout )
	End
	
	#rem monkeydoc Pause application until <Key> has been pressed.
	Any key if key:int is -1
	#end
	Method WaitKey( text:String="~nPress any key to continue...~n", key:Int=-1 )
		
		Write(text)
		
		If key>=0 Then
			Repeat 
			Until GetKey()=key
		Else
			GetKey()
		Endif
		
		Return
	End
	
	#rem monkeydoc Returns true if a key was hit.
	Use with GetKey() to determine what key was hit.
	#end
	Method KeyHit:Bool()
		
		Return kbhit()
	End
	
	#rem monkeydoc Pause application and let the user input a key.
	Can be used
	#end
	Method GetKey:Int()
		
		Return getch()
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
	Plays system warning sound.
	#end
	Method Bell()
		fputs( String.FromChar(7), libc.stdout )
	End
	
	Private
		Method CheckAnsiSupport:Bool( verbose:Bool=True )
			If _ansiChecked Then Return _supportsAnsi
			_ansiChecked=True
			
			Local printErrorCode:Bool
			
			' Force/Disable Ansi support?
			For Local s:=Eachin AppArgs()
				
				' Force Ansi support
				If s.ToLower()="-fa" Then
					_supportsAnsi=True
				Endif
				
				' Disable Ansi support
				If s.ToLower()="-da" Then
					_supportsAnsi=False
				Endif
				
				' Print any Ansi error code
				If s.ToLower()="-pae" Then
					printErrorCode=True
				Endif
				
			Next
			
			' Attempt to get the STD handle...
			Local hOut:=GetStdHandle( -11 )
			
			If Int(hOut)=-1 Or GetLastError() Then
				If verbose Then Print "Unable to get handle for this console"
			Else
				' Attempt to set the console mode...
				SetConsoleMode( hOut, 5 )
			Endif
			
			If GetLastError() Then
				
				Select GetLastError()
					Case 6 ' Wasn't able to get the handle for Std Handle
						If verbose Print "Unable to use the console handle. Ansi will not be supported"
					Case 87 ' Usually happens on older Windows CMD
						If verbose Print "This console is too old to support Ansi escape codes"
					Case 1150 ' Seems to happen on things like ConEmu
						' It still usually works, so force support
						_supportsAnsi=True
					Default ' No idea what happened
						If verbose Print "Unable to enable Ansi escape codes on this console"
				End
				
				' Do we print error code?
				If Not _supportsAnsi And printErrorCode Then
					Print "Error Code: "+GetLastError()
				Endif
				
			Else
				' Ansi supported!
				_supportsAnsi=True
				ResetColors()
			Endif
			
			Return _supportsAnsi
		End
		
		Method ApplyForeground()
			
			CheckAnsiSupport()
			
			If _supportsAnsi Then
				
				If _underlineForeground Then
					AnsiColor( 4 )
				Else
					AnsiColor( 24 )
				Endif
				
				If _boldForeground And _foreground.id>=30 And _foreground.id<38 Then
					AnsiColor( _foreground.id+60 )
				Else
					AnsiColor( _foreground.id )
				Endif
				
			Endif
		End
		
		Method ApplyBackground()
			
			CheckAnsiSupport()
			
			If _supportsAnsi Then
				If _boldBackground And _background.id>=30 And _background.id<38 Then
					AnsiColor( _background.id+70 )
				Else
					AnsiColor( _background.id+10 )
				Endif
			Endif
		End
		
		Field _foreground:Color
		Field _boldForeground:Bool
		Field _underlineForeground:Bool
		Field _background:Color
		Field _boldBackground:Bool
		
		Field _supportsAnsi:Bool
		Field _ansiChecked:Bool
		
	Public
End