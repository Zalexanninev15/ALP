; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
ID_FONT = 101
section '.data' data readable writeable
def_font db 'Default System Font',0
hWindow dd ?
curs    POINT
font    LOGFONT
section '.code' code readable executable
  start:
        invoke  GetModuleHandle,0
        invoke  DialogBoxParam,eax,37,HWND_DESKTOP,DialogProc,0
        invoke  ExitProcess,0
proc DialogProc hwnddlg,msg,wparam,lparam
        push    ebx esi edi
        cmp     [msg],WM_INITDIALOG
        je      .wminitdialog
        cmp     [msg],WM_COMMAND
        je      .wmcommand
        cmp     [msg],WM_CLOSE
        je      .wmclose
        cmp     [msg],WM_TIMER
        je      .wmtimer
        xor     eax,eax
        jmp     .finish
  .wminitdialog:
        invoke  SetTimer,[hwnddlg],1,100,NULL
        jmp     .processed
  .wmcommand:
        cmp     [wparam],BN_CLICKED shl 16 + IDCANCEL
        je      .wmclose
        jmp     .processed
  .wmtimer:
        invoke  GetCursorPos,curs
        or      eax,eax
        jz      .processed
        invoke  WindowFromPoint,[curs.x],[curs.y]
        or      eax,eax
        jz      .processed
        mov     [hWindow],eax
        invoke  SendMessage,[hWindow],WM_GETFONT,NULL,NULL
        or      eax,eax
        jz      @f
        invoke  GetObject,eax,sizeof.LOGFONT,font
        invoke  SetDlgItemText,[hwnddlg],ID_FONT,font.lfFaceName
        jmp     .processed
@@:
        invoke  SetDlgItemText,[hwnddlg],ID_FONT,def_font
        jmp     .processed
  .wmclose:
        invoke  EndDialog,[hwnddlg],0
  .processed:
        mov     eax,1
  .finish:
        pop     edi esi ebx
        ret
endp
section '.idata' import data readable writeable
  library kernel32,'kernel32.dll',\
          user32,'user32.dll',\
          gdi32,'gdi32.dll'
  include 'includes\api\kernel32.inc'
  include 'includes\api\user32.inc'
  include 'includes\api\gdi32.inc'
section '.rsrc' resource data readable
  directory RT_DIALOG,dialogs
  resource dialogs,\
           37,LANG_ENGLISH+SUBLANG_DEFAULT,demonstration
  dialog demonstration,'GetWindowFont',0,0,190,30,WS_CAPTION+WS_SYSMENU+DS_CENTER+DS_SYSMODAL,0,0,'Arial',12
    dialogitem 'STATIC','', ID_FONT, 5, 11, 180, 14,WS_VISIBLE+SS_CENTER
  enddialog