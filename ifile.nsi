!define PROGNAME "iFileHandler"
!define PROGVERSION "1.20.00.0001"
!define PRODVERSION "1.2.0.1"

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  
;--------------------------------
;General

  ;Name and file
  Name ${PROGNAME}
  Caption "${PROGNAME} Version ${PROGVERSION}"
  OutFile "${PROGNAME}.exe"

  ;Default installation folder
  InstallDir "$WINDIR"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\${PROGNAME}" ""

  SetCompressor lzma
  BrandingText " "
  CRCCheck force
  InstallColors /windows
  ShowInstDetails nevershow
  ShowUninstDetails nevershow
  XPStyle on
  
  VIProductVersion ${PRODVERSION} 
  VIAddVersionKey "FileDescription" "iFile Handler Helper Application"
  VIAddVersionKey "FileVersion" ${PROGVERSION}
  VIAddVersionKey "LegalCopyright" ""
  VIAddVersionKey "ProductName" ${PROGNAME}
  VIAddVersionKey "ProductVersion" ${PRODVERSION}

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Install"
  ; Store installation folder
  WriteRegStr HKCU "Software\${PROGNAME}" "" $INSTDIR

  SetOutPath $INSTDIR

  ; Install the helper to Windows directory
  File release\ifile.exe

  ; Register the helper
  WriteRegStr HKCR "ifile" "" "URL:IFile Protocol"
  WriteRegStr HKCR "ifile" "URL Protocol" ""
  WriteRegStr HKCR "ifile\shell" "" ""
  WriteRegStr HKCR "ifile\shell\open" "" ""
  WriteRegStr HKCR 'ifile\shell\open\command' '' '"C:\windows\ifile.exe" "%1"'
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGNAME}" "DisplayName" ${PROGNAME}
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGNAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGNAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGNAME}" "DisplayVersion" ${PROGVERSION}
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGNAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGNAME}" "NoRepair" 1

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGNAME}"

  Delete "$INSTDIR\Uninstall.exe"
  Delete "$INSTDIR\ifile.exe"

  DeleteRegKey HKCU "Software\${PROGNAME}"

SectionEnd

;--------------------------------
;Helper Functions

Function .onInit
  BringToFront
  ; Check if already running
  ; If so don't open another but bring to front
  System::Call "kernel32::CreateMutexA(i 0, i 0, t '$(^Name)') i .r0 ?e"
  Pop $0
  StrCmp $0 0 launch
  StrLen $0 "$(^Name)"
  IntOp $0 $0 + 1
  loop:
    FindWindow $1 '#32770' '' 0 $1
    IntCmp $1 0 +5
    System::Call "user32::GetWindowText(i r1, t .r2, i r0) i."
    StrCmp $2 "$(^Name)" 0 loop
    System::Call "user32::ShowWindow(i r1,i 9) i."         ; If minimized then maximize
    System::Call "user32::SetForegroundWindow(i r1) i."    ; Bring to front
    Abort
  launch:
FunctionEnd
