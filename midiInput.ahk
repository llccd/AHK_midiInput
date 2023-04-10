#Persistent
#SingleInstance force
SendMode Input
SetWorkingDir %A_ScriptDir%
Menu, tray, add, MidiSet

NumPorts := DllCall("winmm\midiInGetNumDevs")

IfExist, midiInput.ini
	IniRead, MidiInDevice, midiInput.ini, Settings, MidiInDevice, %MidiInDevice%
Else {
	MsgBox, 1, No ini file found, Select midi ports?
	IfMsgBox, Cancel
		ExitApp
	Gosub, MidiSet
}

If (midiInDevice = "" or midiInDevice >= NumPorts) {
	MsgBox, 49, Midi Port Error, Midi In Port Invalid.`nSelect midi ports?
	IfMsgBox, Cancel
		ExitApp
	Gosub, MidiSet
}

Gui, +LastFound
VarSetCapacity(hMidiIn, 4, 0)
result := DllCall("winmm\midiInOpen", "Ptr", &hMidiIn, "UInt", MidiInDevice, "Ptr", WinExist(), "Ptr", 0, "UInt", 0x10000)
If result
	MsgBox, Error, midiInOpen Returned %result%
result := DllCall("winmm\midiInStart", "Ptr", NumGet(hMidiIn))
If result
	MsgBox, Error, midiInStart Returned %result%`nRight Click on the Tray Icon - Left click on MidiSet to select valid midi_in port.
; MM_MIM_OPEN 0x3C1
; MM_MIM_CLOSE 0x3C2
; MM_MIM_LONGDATA 0x3C4
; MM_MIM_LONGERROR 0x3C6
OnMessage(0x3C3, "MidiMsgDetect", 10) ;MM_MIM_DATA
OnMessage(0x3C5, "MidiMsgDetect", 10) ;MM_MIM_ERROR
Return

MidiSet:
  MiList := MidiInsList(NumPorts)
  Gui, 4: Destroy
  Gui, 4: +LastFound +AlwaysOnTop +Caption +ToolWindow
  Gui, 4: Font, s12
  Gui, 4: Add, text, x10 y10 w200 cmaroon, Select Midi Ports.
  Gui, 4: Font, s8
  Gui, 4: Add, Text, x10 y+10 w180 Center, Midi In Port
  Gui, 4: Add, ListBox, x10 w210 h100 Choose1 vMidiInDevice AltSubmit, %MiList%
  Gui, 4: Add, Button, x10 w105 gDone, Done
  Gui, 4: Add, Button, xp+105 w105 gCancel, Cancel
  Gui, 4: Show, , Midi Port Selection
Return

Done:
    Gui, 4: Submit
    MidiInDevice := MidiInDevice - 1
    IfNotExist, midiInput.ini
        FileAppend,, midiInput.ini
    IniWrite, %MidiInDevice%, midiInput.ini, Settings, MidiInDevice
    Reload
Return

Cancel:
    Gui, 4: Destroy
Return

MidiMsgDetect(hInput, midiMsg, wMsg) {
    global statusbyte, chan, data1, data2, stb, pitchb
    statusbyte :=  midiMsg & 0xFF
    chan := (statusbyte & 0x0f) + 1
    data1 := (midiMsg >> 8) & 0xFF
    data2 := (midiMsg >> 16) & 0xFF
    pitchb := (data2 << 7) | data1

    if statusbyte between 0x80 and 0x8F
      stb := "NoteOff"
    else if statusbyte between 0x90 and 0x9F
      stb := "NoteOn"
    else if statusbyte between 0xA0 and 0xAF
      stb := "PolyAT"
    else if statusbyte between 0xB0 and 0xBF
      stb := "CC"
    else if statusbyte between 0xC0 and 0xCF
      stb := "PC"
    else if statusbyte between 0xD0 and 0xDF
      stb := "ChanAT"
    else if statusbyte between 0xE0 and 0xEF
      stb := "PitchB"
    else if statusbyte between 0xF0 and 0xFF
      stb := "System"
    else
      stb := "??"

    Gosub, MidiRules
}

MidiInsList(ByRef NumPorts) {
    local List, MidiInCaps, PortName, result, midisize
    (A_IsUnicode)? offsetWordStr := 64: offsetWordStr := 32
    midisize := offsetWordStr + 18
    VarSetCapacity(MidiInCaps, midisize, 0)
    VarSetCapacity(PortName, offsetWordStr)

    NumPorts := DllCall("winmm\midiInGetNumDevs")

    Loop %NumPorts% {
        result := DllCall("winmm\midiInGetDevCaps", "UInt", A_Index - 1, "Ptr", &MidiInCaps, "UInt", midisize)
    
        If (result OR ErrorLevel)
            PortName := "-Error-"
        Else
            PortName := StrGet(&MidiInCaps + 8, offsetWordStr)
        List .= "|" PortName
    }
    Return SubStr(List,2)
}

#Include midiRules.ahk