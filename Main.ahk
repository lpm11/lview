#Include Gdip.ahk

version := "0.01a"

DecideImageSize(ImageFullPath, mw, mh) {
  ; Modified from:
  ; http://www.autohotkey.com/board/topic/55305-read-the-image-size-solved/
  GDIPToken := Gdip_Startup()
	pBM := Gdip_CreateBitmapFromFile(ImageFullPath)
	w := Gdip_GetImageWidth(pBM), h := Gdip_GetImageHeight(pBM)
	Gdip_DisposeImage(pBM)
  Gdip_Shutdown(GDIPToken)

  If (w > mw || h > mh)
  {
    ; Image size over the screen
    sw := mw / w
    sh := mh / h
    scale := sw < sh ? sw : sh

    w := Floor(w * scale)
    h := Floor(h * scale)
  }
  return "w" w " h" h
}

; Modified from:
; https://sites.google.com/site/ahkref/custom-functions/sortarray
SortArray(Array, KeyArray, Order="A") {
    ;Order A: Ascending, D: Descending, R: Reverse
    MaxIndex := ObjMaxIndex(Array)
    If (Order = "R") {
        count := 0
        Loop, % MaxIndex
            ObjInsert(Array, ObjRemove(Array, MaxIndex - count++))
        Return
    }
    Partitions := "|" ObjMinIndex(Array) "," MaxIndex
    Loop {
        comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
        spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)
        if (Order = "A") {
            Loop, % epos - spos {
                if (KeyArray[pivot] > KeyArray[A_Index+spos]) {
                  ObjInsert(KeyArray, pivot, ObjRemove(KeyArray, A_Index+spos))
                  ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))
                }
            }
        } else {
            Loop, % epos - spos {
                if (KeyArray[pivot] < KeyArray[A_Index+spos]) {
                  ObjInsert(KeyArray, pivot, ObjRemove(KeyArray, A_Index+spos))
                  ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))
                }
            }
        }
        Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
        if (pivot - spos) > 1    ;if more than one elements
            Partitions .= "|" spos "," pivot-1        ;the left partition
        if (epos - pivot) > 1    ;if more than one elements
            Partitions .= "|" pivot+1 "," epos        ;the right partition
    } Until !Partitions
}

#Persistent
#SingleInstance

IniRead, activator, lview.ini, lview, activator, %A_Space%
If activator !=
{
  Hotkey, %activator%, OnPreview, On
}
IniRead, mw, lview.ini, lview, width, %A_Space%
IniRead, mh, lview.ini, lview, height, %A_Space%
If mw =
{
  mw := Floor(A_ScreenWidth * 0.4)
}
If mh =
{
  mh := Floor(A_ScreenHeight * 0.4)
}
IniRead, viewer_path, lview.ini, lview, viewer, %A_Space%

Menu, TRAY, NoStandard
Menu, TRAY, Add, "Config (&C)", OnConfig
Menu, TRAY, Add
Menu, TRAY, Add, "About (&A)", OnAbout
Menu, TRAY, Add, "Exit (&X)", OnExitMenu
return

OnConfig:
  ; disable while config
  If activator !=
  {
    Hotkey, %activator%,, Off
  }

  Gui, Add, Text,, Activate hotkey:
  Gui, Add, Hotkey, vActivator w140, %activator%
  Gui, Add, Text,, Width:
  Gui, Add, Edit, vmw w60, %mw%
  Gui, Add, Text,, Height:
  Gui, Add, Edit, vmh w60, %mh%
  Gui, Add, Text,, Viewer (blank for internal viewer)
  Gui, Add, Edit, vviewer_path w160, %viewer_path%
  Gui, Add, Button, gButtonSelectViewer w45, Select...
  Gui, Add, Button, gButtonOK w65, OK
  Gui, Add, Button, gButtonCancel w65 x85 yp-0, Cancel
  Gui, Show
  return

ButtonSelectViewer:
  FileSelectFile, viewer_path_selected, 3,,, Executable (*.exe)
  if viewer_path_selected !=
  {
    GuiControl,, viewer_path, %viewer_path_selected%
  }
  return

ButtonOK:
  Gui, Submit
  Gui, Destroy

  IniWrite, %activator%, lview.ini, lview, activator
  IniWrite, %mw%, lview.ini, lview, width
  IniWrite, %mh%, lview.ini, lview, height
  IniWrite, %viewer_path%, lview.ini, lview, viewer
  Hotkey, %activator%, OnPreview, On
  return

ButtonCancel:
  Gui, Cancel
  Gui, Destroy

  If activator !=
  {
    Hotkey, %activator%, OnPreview, On
  }
  return

OnPreview:
  dir = %A_Temp%\lview
  files := Object()
  filetimes := Object()
  Loop, %dir%\*
  {
    files.Insert(A_LoopFileFullPath)
    FileGetTime, t, %A_LoopFileFullPath%, M
    filetimes.Insert(t)
  }

  ; Sort by time
  SortArray(files, filetimes, "D")
  file_index = 1
  max_file_index = files.MaxIndex()
  file := files[file_index]

  If file =
  {
    TrayTip, lview, No displayable image found at this time.
    return
  }

  If viewer_path !=
  {
    ; Open with external viewer
    Run, %viewer_path% %file%
    return
  }

  size := DecideImageSize(file, mw, mh)

  Gui, Margin, 0, 0
  Gui, -MaximizeBox
  Gui, Add, Picture, %size% vMyPicture, %file%
  Gui, Show, xCenter yCenter AutoSize, lview - %file%
  return

GuiClose:
GuiEscape:
  Gui, Destroy
  return

OnAbout:
  MsgBox lview version %version%.
  return

OnExitMenu:
  ExitApp
  return

SwitchImage(file, mw, mh) {
  size := DecideImageSize(file, mw, mh)

  GuiControl, Move, MyPicture, %size%
  GuiControl,, MyPicture, %file%
  Gui, Show, xCenter yCenter AutoSize, lview - %file%
}

#IfWinActive, lview -
Left::
  If file_index < max_file_index
  {
    file_index++
    SwitchImage(files[file_index], mw, mh)
  }
  return

Right::
  If file_index > 1
  {
    file_index--
    SwitchImage(files[file_index], mw, mh)
  }
  return
#IfWinActive

; Debug purpose
; ^!q::Gosub, OnConfig
; ^!a::Reload
