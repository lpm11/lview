#Include Gdip.ahk

version := "0.01a"

DecideImageSize(ImageFullPath, mw, mh) {
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
  Gui, Add, Button, gButtonOK w65, OK
  Gui, Add, Button, gButtonCancel w65 x85 yp-0, Cancel
  Gui, Show
  return

ButtonOK:
  Gui, Submit
  Gui, Destroy

  IniWrite, %activator%, lview.ini, lview, activator
  IniWrite, %mw%, lview.ini, lview, width
  IniWrite, %mh%, lview.ini, lview, height
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
  Loop, %dir%\*
  {
    FileGetTime, t, %A_LoopFileFullPath%, C
    If (t > t_latest)
    {
      t_latest := t
      filename := A_LoopFileName
    }
  }

  If filename =
  {
    TrayTip, lview, No displayable image found at this time.
    return
  }
  path = %dir%\%filename%
  size := DecideImageSize(path, mw, mh)

  Gui, Margin, 0, 0
  Gui, -MaximizeBox
  Gui, Add, Picture, %size%, %path%
  Gui, Show, xCenter yCenter AutoSize, lview - %filename%
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
