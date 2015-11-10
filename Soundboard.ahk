;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                              ;;
;;         AutoHotKey Soundboard v1.0.2         ;;
;;               by Kyle Herock                 ;;
;;                                              ;;
;;  Use the Numpad plus (+) key in addition to  ;;
;;  any key outside the top row and rightmost   ;;
;;  column to play a sound.                     ;;
;;  Using the Numpad minus (-) with the same    ;;
;;  key will stop the most recent instance of   ;;
;;  that track early.                           ;;
;;                                              ;;
;;  Config     : Numpad (+) and Numpad 0/Ins    ;;
;;  Play sound : Numpad (+) and Numpad 1-9, .   ;;
;;  Alt set    : ^^same, but with Num Lock OFF  ;;
;;  Stop sound : Numpad (-) and associated key  ;;
;;  Stop All   : Numpad (-) and Numpad 0/Ins    ;;
;;                                              ;;
;;  Make sure you have a correctly configured   ;;
;;  PlaySound.ahk in the same directory!        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#SingleInstance, force

global DEBUG := false
global HWND, Sounds, PushToTalk, Settings, AudioPlayer, VlcPath, MplayerPath
global PlayingSounds
Init()

NumpadAdd & Numpad0::Config()
NumpadAdd & NumpadIns::(DEBUG) ? SwitchDebug() : Config()
NumpadSub & Numpad0::CancelAll()
NumpadSub & NumpadIns::CancelAll()
NumpadAdd & NumpadEnter::Reload

NumpadAdd & Numpad1::
NumpadAdd & Numpad2::
NumpadAdd & Numpad3::
NumpadAdd & Numpad4::
NumpadAdd & Numpad5::
NumpadAdd & Numpad6::
NumpadAdd & Numpad7::
NumpadAdd & Numpad8::
NumpadAdd & Numpad9::
NumpadAdd & NumpadDot::
NumpadAdd & NumpadEnd::
NumpadAdd & NumpadDown::
NumpadAdd & NumpadPgDn::
NumpadAdd & NumpadLeft::
NumpadAdd & NumpadClear::
NumpadAdd & NumpadRight::
NumpadAdd & NumpadHome::
NumpadAdd & NumpadUp::
NumpadAdd & NumpadPgUp::
NumpadAdd & NumpadDel::
	PlaySoundbyte(Sounds[SubStr(A_ThisHotkey, 19)])
	return
NumpadSub & Numpad1::
NumpadSub & Numpad2::
NumpadSub & Numpad3::
NumpadSub & Numpad4::
NumpadSub & Numpad5::
NumpadSub & Numpad6::
NumpadSub & Numpad7::
NumpadSub & Numpad8::
NumpadSub & Numpad9::
NumpadSub & NumpadDot::
NumpadSub & NumpadEnd::
NumpadSub & NumpadDown::
NumpadSub & NumpadPgDn::
NumpadSub & NumpadLeft::
NumpadSub & NumpadClear::
NumpadSub & NumpadRight::
NumpadSub & NumpadHome::
NumpadSub & NumpadUp::
NumpadSub & NumpadPgUp::
NumpadSub & NumpadDel::
	CancelSoundbyte(Sounds[SubStr(A_ThisHotkey, 19)])
	return
#If WinActive("ahk_id " HWND)
~Del::RemoveExe()
#If

Init() {
	Sounds := {}
	PushToTalk := {}
	PlayingSounds := {}
	Settings := {}
	OnMessage(0x5555, "RemovePID")
	Loop, Read, %A_ScriptDir%\Soundboard.ini
	{
		if (RegexMatch(A_LoopReadLine, "O)^\[(.*)\]$", newSection))
			section := newSection.Value(1)
		else {
			key := ""
			value := ""
			newLine := true
			Loop, Parse, A_LoopReadLine, =
			{	
				if (newLine)
					key := A_LoopField
				else
					value := value ((value = "") ? "" : "=") A_LoopField
				newLine := false
			}
			if (IsLabel(section))
				Gosub, %section%
		} 
	}
	return
	
	Sounds:
	Sounds[key] := {src: value, pids: []}
	return
	
	PushToTalk:
	PushToTalk[key] := value
	return
 }

Config() {
	static justFocusing, Hotkey
	IfWinExist, ahk_id %HWND%
		Goto, GuiClose
	Gui, +hwndHWND
	Gui, Add, GroupBox, y6 Section w286 h384, Numlock ON
	Gui, Add, Button, gBrowseSound xs+8 ys+16 w90 h90, 7
	Gui, Add, Button, gBrowseSound x+ wp hp, 8
	Gui, Add, Button, gBrowseSound x+ wp hp, 9
	Gui, Add, Button, gBrowseSound xs+8 y+ wp hp, 4
	Gui, Add, Button, gBrowseSound x+ wp hp, 5
	Gui, Add, Button, gBrowseSound x+ wp hp, 6
	Gui, Add, Button, gBrowseSound xs+8 y+ wp hp, 1
	Gui, Add, Button, gBrowseSound x+ wp hp, 2
	Gui, Add, Button, gBrowseSound x+ wp hp, 3
	Gui, Add, Button, gBrowseSound y+ wp hp, .
	Gui, Add, GroupBox, y6 Section w286 h384, Numlock OFF
	Gui, Add, Button, gBrowseSound xs+8 ys+16 w90 h90, Home
	Gui, Add, Button, gBrowseSound x+ wp hp, Up
	Gui, Add, Button, gBrowseSound x+ wp hp, PgUp
	Gui, Add, Button, gBrowseSound xs+8 y+ wp hp, Left
	Gui, Add, Button, gBrowseSound x+ wp hp, Clear
	Gui, Add, Button, gBrowseSound x+ wp hp, Right
	Gui, Add, Button, gBrowseSound xs+8 y+ wp hp, End
	Gui, Add, Button, gBrowseSound x+ wp hp, Down
	Gui, Add, Button, gBrowseSound x+ wp hp, PgDn
	Gui, Add, Button, gBrowseSound y+ wp hp, Del
	Gui, Add, GroupBox, y6 Section w256 h162, Push-to-talk keys
	Gui, Add, Button, gBrowseExe xs+8 ys+16 w75 h23, Add
	Gui, Add, Edit, gSetHotkey xs+188 yp+1 w60 Limit9 WantTab Center ReadOnly
	Gui, Add, ListBox, gFocusExe xs+8 y+7 w240 r8 t91
	Gui, Add, GroupBox, xs y+12 Section w256 h219, Settings
	Gui, Add, Text, xs+12 ys+20, Audio player:
	Gui, Add, Radio, gChangeSetting y+6, VLC
	Gui, Add, Radio, gChangeSetting x+8, mplayer
	Gui, Add, Button, gSave x703 y395 w75 h23, Save
	Gui, Add, Button, gCancel x+6 w75 h23, Cancel
	Gui, Show,, Configure Soundboard
	OnMessage(0x101, "WM_KEYUP")
	OnMessage(0x105, "WM_KEYUP")
	OnMessage(0x200, "WM_MOUSEMOVE")
	OnMessage(0x202, "WM_LBUTTONUP")
	Gosub, PopulateExes
	Gosub, FocusExe
	return

	BrowseSound:
	key := (A_GuiControl = ".") ? "Dot" : A_GuiControl
	Gui, +Disabled
	FileSelectFile, FilePath, 3,, Choose a sound for %key%
	Gui, -Disabled
	WinActivate, ahk_id %HWND%
	Sounds[key] := {src: FilePath, pids: []}
	return
	
	BrowseExe:
	Gui, +Disabled
	FileSelectFile, filePath,,, Choose a game .exe, Programs (*.exe)
	Gui, -Disabled
	WinActivate, ahk_id %HWND%
	SplitPath, % filePath, newExe
	if (newExe) {
		selected := newExe
		PushToTalk[newExe] := ""
	}
	Gosub, PopulateExes
	Gosub, FocusExe
	ControlFocus, Edit1
	return
	
	FocusExe:
	GuiControlGet, selected,, ListBox1
	selected := StrSplit(selected, "`t")[1]
	justFocusing := true
	GuiControl,, Edit1, % PushToTalk[selected]
	if (A_GuiEvent = "DoubleClick") {
		ControlFocus, Edit1
;		SendMessage 0xb1, 0, -1, Edit1, ahk_id %HWND%
	}
	return
	
	PopulateExes:
	exes := "|"
	for Exe, Hotkey in PushToTalk {
		exes := exes Exe "`t" Hotkey ((Exe = selected) ? "||" : "|")
	}
	GuiControl,, ListBox1, % exes
	return
	
	SetHotkey:
	GuiControlGet, selected,, ListBox1
	selected := StrSplit(selected, "`t")[1]
	if (selected) {
		GuiControlGet, hotkey,, Edit1
		PushToTalk[selected] := hotkey
		if (!justFocusing)
			Gosub, PopulateExes
		else
			justFocusing := false
	}
;	SendMessage 0xb1, 0, -1, Edit1, ahk_id %HWND%
	return
	
	ChangeSetting:
	MsgBox, % A_GuiControl
	return
	
	Save:
	Gui, Submit
	FileDelete, % A_ScriptDir "Soundboard.ini"
	FileAppend, [Sounds]`n, % A_ScriptDir "Soundboard.ini"
	for Mapping, Sound in Sounds {
		if (Sound.src)
			FileAppend, % Mapping "=" Sound.src "`n", % A_ScriptDir "Soundboard.ini"
		else
			Sound.Delete(Mapping)
	}
	FileAppend, [PushToTalk]`n, % A_ScriptDir "Soundboard.ini"
	for Exe, Hotkey in PushToTalk {
		if (Hotkey)
			FileAppend, % Exe "=" Hotkey "`n", % A_ScriptDir "Soundboard.ini"
		else
			PushToTalk.Delete(Exe)
	}
	Goto, GuiClose
	
	Cancel:
	Init()
	GuiClose:
	Gui, Destroy
	ToolTip
	OnMessage(0x101, "")
	OnMessage(0x105, "")
	OnMessage(0x200, "")
	OnMessage(0x202, "")
	return

	GuiEscape:
	ControlGetFocus, control
	if (control != "Edit1")
		Goto GuiClose
	return
}
WM_KEYUP() {
	ControlGetFocus, control
	if (control = "Edit1")
		GuiControl,, Edit1, % A_PriorKey
}
WM_MOUSEMOVE() {
	key := (A_GuiControl = ".") ? "Dot" : A_GuiControl
	SplitPath, % Sounds[key].src, Filename
	ToolTip, %Filename%
	return
}
WM_LBUTTONUP() {
	ControlGetFocus, control
;	if (control = "Edit1")
;		SendMessage 0xb1, 0, -1, Edit1, ahk_id %HWND%
}
RemoveExe() {
	ControlGetFocus, control
	if (control = "ListBox1") {
		GuiControlGet, selected,, % control
		selected := StrSplit(selected, "`t")[1]
		if (selected)
			PushToTalk.Delete(selected)
		exes := "|"
		for Exe, Hotkey in PushToTalk {
			exes := exes Exe "`t" Hotkey ((Exe = selected) ? "||" : "|")
		}
		GuiControl,, ListBox1, % exes
	}
	return
}

RemovePID(wParam, lParam, msg) {
	global micKey
	pid = %wParam%
	for Index in PlayingSounds[pid].pids {
		if (pid = PlayingSounds[pid].pids[Index]) {
			PlayingSounds[pid].pids.delete(Index)
			break
		}
	}
	PlayingSounds.Delete(pid)
	if (PlayingSounds.Length() = 0 && micKey)
		Send {%micKey% up}
	Debugger()
	return true
}

PlaySoundbyte(Sound) {
	global micKey
	file := Sound.src
	IfNotExist, %file%
	{
		file = C:\Windows\Media\Windows Hardware Fail.wav
		micKey := ""
	}
	WinGet, ActiveWindowExe, ProcessName, A
	micKey := PushToTalk[ActiveWindowExe]
	Run, AutoHotKey.exe "%A_ScriptDir%\PlaySound.ahk" "%file%" "%micKey%",,, pid
	Sound.pids.Push(pid)
	PlayingSounds[pid] := Sound
	Debugger()
	return
}

CancelSoundbyte(Sound) {
	pid := Sound.pids[Sound.pids.MaxIndex()]
	DetectHiddenWindows On
	PostMessage, 0x10,,,, ahk_pid %pid%
	DetectHiddenWindows Off
	
	Debugger()
	return
}

CancelAll() {
	DetectHiddenWindows On
	for Pid in PlayingSounds
		PostMessage, 0x10,,,, ahk_pid %Pid%
	DetectHiddenWindows Off
	return
}

printPlaying := false
SwitchDebug() {
	global printPlaying
	printPlaying := !printPlaying
	Debugger()
}
Debugger() {
	global printPlaying
	if (DEBUG) {
		if (printPlaying)
			PrintPlaying()
		else
			PrintSounds()
	}
	return
}
PrintSounds() {
	str =
	AutoTrim, Off
	for Index, Object in Sounds {
		str = %str%%Index%: {
		first := true
		for Key, Value in Object {
			if (!first)
				str = %str%,`n
			else
				str = %str%`n
			str = %str%    %Key%:
			if (IsObject(Value)) {
				str = %str% [
				first2 := true
				For Index2, PID in Value {
					if (!first2)
						str = %str%,%A_Space%					
					str = %str%%PID%
					first2 := false
				}
				str = %str%]
			} else {
				str = %str% %Value%
			}
			first := false
		}
		str = %str%`n}`n
	}
	ToolTip, %str%
	AutoTrim, On
}
PrintPlaying() {
	str =
	for Key, Value in PlayingSounds {
		str = % str Key " " Value.src "`n"
	}
	ToolTip, %str%
}