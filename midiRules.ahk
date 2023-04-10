MidiRules:
; These following global variables are available:
;  statusbyte: status byte
;  stb: parsed message type (NoteOff NoteOn PolyAT CC PC ChanAT PitchB System)
;  chan: parsed MIDI channel (1-16, only valid when stb!="System")
;  data1: data byte 1
;  data2: data byte 2
;  pitchb: parsed pitch bend value (only valid when stb="PitchB")
; You can use MsgBox to troubleshoot:
;MsgBox, 0, ,%stb% %chan% %data1% %data2%

; example: Simple Numpad emulation
if (stb = "NoteOn" and data2 != 0) {
	if (GetKeyState("NumLock", "T")) {
		switch data1 {
		case 0: Send, {Numpad7}
		case 1: Send, {Numpad8}
		case 2: Send, {Numpad9}
		case 3: Send, {NumpadDiv}
		case 4: Send, {Numpad4}
		case 5: Send, {Numpad5}
		case 6: Send, {Numpad6}
		case 7: Send, {NumpadMult}
		case 8: Send, {Numpad1}
		case 9: Send, {Numpad2}
		case 10: Send, {Numpad3}
		case 11: Send, {NumpadSub}
		case 12: Send, {Numpad0}
		case 13: Send, {NumpadDot}
		case 14: Send, {NumpadEnter}
		case 15: Send, {NumpadAdd}
		case 127: Send, {NumLock}
		}
	}
	else {
		switch data1 {
		case 0: Send, {NumpadHome}
		case 1: Send, {NumpadUp}
		case 2: Send, {NumpadPgUp}
		case 3: Send, {NumpadDiv}
		case 4: Send, {NumpadLeft}
		case 5: Send, {NumpadClear}
		case 6: Send, {NumpadRight}
		case 7: Send, {NumpadMult}
		case 8: Send, {NumpadEnd}
		case 9: Send, {NumpadDown}
		case 10: Send, {NumpadPgDn}
		case 11: Send, {NumpadSub}
		case 12: Send, {NumpadIns}
		case 13: Send, {NumpadDel}
		case 14: Send, {NumpadEnter}
		case 15: Send, {NumpadAdd}
		case 127: Send, {NumLock}
		}
	}
}
Return