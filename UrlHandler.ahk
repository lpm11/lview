If %0% > 0
{
  url = %1%

  match := RegExMatch(url, "^http://")
  If match > 0
  {
    dir = %A_Temp%\lview
    SplitPath, url, filename
    path = %dir%\%filename%

    FileCreateDir, %dir%
    UrlDownloadToFile, %1%, %path%
  }
  ExitApp
}
