
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
	
	Enum Key
		Any=-1
	
		Backspace=8,Tab
		Enter=13
		Escape=27
		Space=32
		Apostrophe=39
		Comma=44,Minus,Period,Slash
		Key0=48,Key1,Key2,Key3,Key4,Key5,Key6,Key7,Key8,Key9
		Semicolon=59
		Equals=61
		A=65,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
		LeftBracket=91,Backslash,RightBracket
		Backquote=96
		a=97,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
		KeyDelete=127
		
		CapsLock=185,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12
		PrintScreen,ScrollLock,Pause,Insert,Home,PageUp,nop,KeyEnd,PageDown
		Right,Left,Down,Up
		KeypadNumLock,KeypadDivide,KeypadMultiply,KeypadMinus,KeypadPlus,KeypadEnter
		Keypad1,Keypad2,Keypad3,Keypad4,Keypad5,Keypad6,Keypad7,Keypad8,Keypad9,Keypad0
		KeypadPeriod
		
		LeftControl=$e0+$80,LeftShift,LeftAlt,LeftGui,RightControl,RightShift,RightAlt,RightGui
		
		Mode=$101+$80,AudioNext,AudioPrev,AudioStop,AudioPlay,AudioMute,MediaSelect,WWW,Mail,Calculator,Computer
		ACSearch,ACHome,ACBack,ACForward,ACStop,ACRefresh,ACBookmarks
		BrightnessDown,BrightnessUp,DisplaySwitch,IllumToggle,IllumDown,IllumUp,Eject,Sleep
	End
	
	#rem monkeydoc Text foreground color.
	Uses Ansi codes.
	#end
	Property Foreground:Color()
		Return _foreground
	Setter( color:Color )
		If _foreground=color Then Return
		_foreground=color
		
		ApplyForeground()
	End
	
	#rem monkeydoc Use bold/bright foreground colors.
	Uses Ansi codes.
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
	Uses Ansi codes.
	#end
	Property Background:Color()
		Return _background
	Setter( color:Color )
		If _background=color Then Return
		_background=color
		
		ApplyBackground()
	End
	
	#rem monkeydoc Use bold/bright background colors.
	Uses Ansi codes.
	#end
	Property BackgroundBold:Bool()
		Return _boldBackground
	Setter( bold:Bool )
		If _boldBackground=bold Then Return
		_boldBackground=bold
		
		ApplyBackground()
	End
	
	#rem Check for Ansi code support
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
	Use 'nl' parameter for appending new line.
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
	Can be used with KeyHit() to remove pause.
	#end
	Method GetKey:Int()
		
		Return getch()
	End
	
	#rem monkeydoc Pause application and let the user input a line of text.
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
	Play system warning sound.
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