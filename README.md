# Simple-Icon-Picker
This small [AutoHotkey](https://www.autohotkey.com/) v2 utility provides a simple way to browse and inspect icons stored inside Windows resource files such as `shell32.dll`, `imageres.dll`, or any other DLL/EXE containing icon resources. It uses the native Windows `PickIconDlg` dialog, then displays the selected icon together with the file path, the raw `PickIconDlg` index, and the AutoHotkey-compatible icon number.

The tool also generates ready-to-copy AutoHotkey snippets for common use cases, including` Menu.SetIcon()` and `TraySetIcon()`. Each output field has its own `Copy` button, and the selected icon is shown both in the window preview and as the script’s tray/window icon. This is useful when testing icon indexes for menus, tray icons, or small GUI utilities.

<img width="292" height="357" alt="image" src="https://github.com/user-attachments/assets/04c8e01f-7b88-4116-918d-008054eccc74" />
<img width="602" height="466" alt="image" src="https://github.com/user-attachments/assets/e93829ec-845f-4c35-b140-3055b3c915f5" />

