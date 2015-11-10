;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                              ;;
;;          AutoHotKey Soundboard v1.0          ;;
;;               by Kyle Herock                 ;;
;;                                              ;;
;;  You need Soundboard.ahk for this file to    ;;
;;  do anything. Make sure you've enabled       ;;
;;  "Stereo Mix" in the Recording devices tab.  ;;
;;  The settings below should work for most     ;;
;;  assuming you have VLC and you're using your ;;
;;  Mobo's audio out as your default device.    ;;
;;                                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#SingleInstance, off
#NoTrayIcon

;;;;;;;;;;;;;;;;;; Audio Config ;;;;;;;;;;;;;;;;;;
;; VLC is preferred, set "Show change media popup"
;; to "Never". MPlayer's dsound driver cuts off
;; the last half second or so, so be wary of that.

PLAYER = MPLAYER	; Valid options are MPLAYER or VLC
VLC_PATH = C:\Program Files\VideoLAN\VLC\vlc.exe
MPLAYER_PATH = C:\Program Files\mplayer\mplayer.exe
AUDIO_IN = Mic 1

;;;;;;;;;;;;;; Audio Output Device ;;;;;;;;;;;;;;;
;; - For mplayer, try incremental values starting at 1 until you get the right device. 0 is default.
;; - For VLC, go to Preferences, All-->Audio-->Output modules-->WaveOut to get the name.

VLC_AUDIO_OUT = Line 1 (Virtual Audio Cable) ($1,$64)
MPLAYER_AUDIO_OUT = 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OnExit("Cleanup")
OnMessage(0x10, "Cleanup")
DetectHiddenWindows On
SetTitleMatchMode 2
file = %1%
micKey = %2%

Run, nircmd setdefaultsounddevice "%AUDIO_IN%" 1
Run, nircmd setdefaultsounddevice "%AUDIO_IN%" 2
if (PLAYER = "VLC")
	Run, "%VLC_PATH%" --aout=waveout --waveout-audio-device="%VLC_AUDIO_OUT%" --intf qt --play-and-exit --qt-start-minimized --qt-system-tray "%file%",,, pid
else if (PLAYER = "MPLAYER")
	Run, "%MPLAYER_PATH%" -ao dsound:device="%MPLAYER_AUDIO_OUT%" "%file%",, Hide, pid
else {
	MsgBox, %PLAYER% is not valid, set PLAYER to either MPLAYER or VLC
	Cleanup()
}
	
WinWait, ahk_pid %pid%
if (micKey)
	Send {%micKey% down}
WinWaitClose, ahk_pid %pid%

ExitApp
return

Cleanup() {
	global pid
	Process, Close, %pid%
	Run, nircmd setdefaultsounddevice "Microphone"
	Run, nircmd setdefaultsounddevice "Microphone" 2
	
	ErrorLevel = 0
	while (!ErrorLevel)
		SendMessage, 0x5555, DllCall("GetCurrentProcessId"),,, Soundboard.ahk ahk_class AutoHotkey

	ExitApp
	return
}

