; Simple Icon Picker for AHK
;---------------------------
; 14/05/2026
; Mesut Akcan
; github.com/akcansoft
;---------------------
#Requires AutoHotkey v2.0

defaultPath := A_WinDir "\System32\shell32.dll" ; Default path for the icon picker dialog
MAX_PATH := 260
pathBuffer := Buffer(MAX_PATH * 2, 0) ; Buffer for the selected icon path (UTF-16, hence *2)
StrPut(defaultPath, pathBuffer, MAX_PATH, "UTF-16") ; Copy default path to buffer
index := 0 ; Variable to receive the selected icon index

; Call the PickIconDlg function to show the icon picker dialog
try {
	if !DllCall("Shell32\PickIconDlg", "Ptr", 0, "Ptr", pathBuffer, "UInt", MAX_PATH, "Int*", &index)
		ExitApp()
} catch as err {
	MsgBox("PickIconDlg call failed.`n`n" err.Message, "Error", "Icon! 4096")
	ExitApp()
}

iconPath := StrGet(pathBuffer, "UTF-16") ; Convert the selected path from UTF-16 to a string
pickerIndex := index ; The index returned by PickIconDlg is zero-based, but AHK's icon numbering starts at 1
ahkIconNumber := pickerIndex + 1 ; Create references for the selected icon in different formats
iconRef := iconPath "," ahkIconNumber ; Format for AHK functions that take a file path and icon index
ahkMenuRef := 'MyMenu.SetIcon(MenuItemName, "' iconPath '", ' ahkIconNumber ')' ; Example code for setting a menu icon in AHK
ahkTrayRef := 'TraySetIcon("' iconPath '", ' ahkIconNumber ')' ; Example code for setting a tray icon in AHK using the selected icon

TraySetIcon(iconPath, ahkIconNumber) ; Set the tray icon to the selected icon as a demonstration

resultGui := Gui("+AlwaysOnTop", "Selected Icon") ; Create a GUI to display the selected icon and its details
resultGui.SetFont("s9", "Segoe UI") ; Set gui font
resultGui.OnEvent("Close", (*) => ExitApp()) ; Exit the app when the GUI is closed
SetGuiIcon(resultGui, iconPath, ahkIconNumber) ; Set the GUI icon to the selected icon as well

resultGui.AddPicture("xm ym w32 h32 Icon" ahkIconNumber, iconPath) ; Display the selected icon in the GUI
resultGui.AddText("x+10 yp+7", "Selected icon") ; Label for the icon

AddOutputRow(resultGui, "File", iconPath, true) ; Display the selected file path in the GUI
AddOutputRow(resultGui, "PickIconDlg index", pickerIndex) ; Display the zero-based index returned by PickIconDlg
AddOutputRow(resultGui, "AHK IconNumber", ahkIconNumber) ; Display the AHK icon number (which is index + 1)
AddOutputRow(resultGui, "Path,index", iconRef) ; Display the combined path and index format used by some AHK functions
AddOutputRow(resultGui, "AHK menu format:`nMyMenu.SetIcon(MenuItemName, FileName [, IconNumber, IconWidth])", ahkMenuRef) ; Display example code for setting a menu icon in AHK using the selected icon
AddOutputRow(resultGui, "AHK tray icon code:`nTraySetIcon [FileName, IconNumber, Freeze]", ahkTrayRef) ; Display example code for setting a tray icon in AHK using the selected icon

pickAgain := resultGui.AddButton("xm y+14 w100 Default", "Pick again") ; Button to pick another icon, which reloads the script when clicked
exitButton := resultGui.AddButton("x+8 yp w80", "Exit") ; Button to exit the application
pickAgain.OnEvent("Click", (*) => Reload()) ; Reload the script when the "Pick again" button is clicked
exitButton.OnEvent("Click", (*) => ExitApp()) ; Exit the application when the "Exit" button is clicked

resultGui.Show() ; Show the GUI

; Function to set the GUI icon using the selected file and icon index
SetGuiIcon(guiObj, fileName, iconNumber) {
	static iconHandles := [] ; Array to store icon handles for cleanup

	smallIcon := LoadPicture(fileName, "Icon" iconNumber " w16 h16", &smallType) ; Load the small icon (16x16) from the file and index
	largeIcon := LoadPicture(fileName, "Icon" iconNumber " w32 h32", &largeType) ; Load the large icon (32x32) from the file and index

	; Set the small and large icons for the GUI using SendMessageW with the WM_SETICON message (0x80)
	if smallIcon { ; If the small icon was loaded successfully, set it as the small icon for the GUI
		DllCall("User32\SendMessageW", "Ptr", guiObj.Hwnd, "UInt", 0x80, "UPtr", 0, "Ptr", smallIcon)
		iconHandles.Push(smallIcon) ; Store the small icon handle for cleanup later
	}
	if largeIcon { ; If the large icon was loaded successfully, set it as the large icon for the GUI
		DllCall("User32\SendMessageW", "Ptr", guiObj.Hwnd, "UInt", 0x80, "UPtr", 1, "Ptr", largeIcon)
		iconHandles.Push(largeIcon) ; Store the large icon handle for cleanup later
	}
}

; Function to add a row of output (label and value) to the GUI, with an optional "Copy" button
AddOutputRow(guiObj, label, value, firstRow := false) {
	yOpt := firstRow ? "y+14" : "y+10" ; Positioning for the first row is slightly different to add some extra space at the top

	guiObj.AddText("xm " yOpt, label) ; Add the label text to the GUI
	guiObj.AddEdit("xm y+4 w500 ReadOnly BackgroundFFFFDD", value) ; Add a read-only edit control to display the value, with a light yellow background for better visibility
	copyButton := guiObj.AddButton("x+8 yp-1 w70", "Copy") ; Add a "Copy" button next to the edit control to allow copying the value to the clipboard
	copyButton.OnEvent("Click", (*) => CopyText(value)) ; Set the click event for the "Copy" button to call the CopyText function with the value to be copied
}

; Function to copy text to the clipboard and show a temporary tooltip confirming the action
CopyText(text) {
	A_Clipboard := text
	ToolTip("Copied")
	SetTimer(() => ToolTip(), -900)
}
