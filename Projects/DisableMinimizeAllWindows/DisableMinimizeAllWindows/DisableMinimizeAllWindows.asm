; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
section '.code' code readable executable
  start:
        invoke  FindWindow,stw,NULL
        or      eax,eax
        jz      loc_exit
        invoke  FindWindowEx,eax,NULL,tnw,NULL
        or      eax,eax
        jz      loc_exit
        invoke  FindWindowEx,eax,NULL,tsc,NULL
        or      eax,eax
        jz      loc_exit
        invoke  ShowWindow,eax,SW_HIDE
loc_exit:
        invoke  ExitProcess,0
stw     db      'Shell_TrayWnd',0
tnw     db      'TrayNotifyWnd',0
tsc     db      'TrayShowDesktopButtonWClass',0
section '.idata' import data readable writeable
  library kernel32,'kernel32.dll',\
          user32,'user32.dll'
  include 'includes\api\kernel32.inc'
  include 'includes\api\user32.inc'