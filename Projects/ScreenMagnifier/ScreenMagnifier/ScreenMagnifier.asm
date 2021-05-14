; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
ID_ZOOM  = 104
section '.data' data readable writeable
curs     POINT
coord    RECT 
hDesktop dd ? 
dDC      dd ? 
wDC      dd ? 
dWidth   dd ?
dHeight  dd ?
section '.code' code readable executable
start:
        invoke  GetModuleHandle,0
        invoke  DialogBoxParam,eax,1,HWND_DESKTOP,DialogProc,0
        invoke  ExitProcess,0
proc DialogProc hwnddlg,msg,wparam,lparam
        push    ebx esi edi
        mov     eax,[msg]
        cmp     eax,WM_INITDIALOG
        je      wminitdialog
        cmp     eax,WM_CLOSE
        je      wmclose
        cmp     [msg],WM_LBUTTONDOWN
        je      drag_window
        xor     eax,eax
        jmp     finish
drag_window:
        invoke  ReleaseCapture
        invoke  SendMessage,[hwnddlg],WM_SYSCOMMAND,61458,0
        jmp     processed
wminitdialog:
        invoke  GetDlgItem,[hwnddlg],ID_ZOOM
        mov     ebx,eax
        invoke  GetDC,eax
        mov     [wDC],eax
        invoke  GetClientRect,ebx,coord
        mov     eax,[coord.right]
        sub     eax,[coord.left]
        mov     [dWidth],eax
        mov     eax,[coord.bottom]
        sub     eax,[coord.top]
        mov     [dHeight],eax
        invoke  GetDesktopWindow
        mov     [hDesktop],eax
        invoke  GetDC,eax
        mov     [dDC],eax
        invoke  SetTimer,[hwnddlg],1,50,ZoomProc
        jmp     processed
wmclose:
        invoke  KillTimer,[hwnddlg],1
        invoke  ReleaseDC,[hDesktop],[dDC]
        invoke  ReleaseDC,[hwnddlg],[wDC]
        invoke  EndDialog,[hwnddlg],0
processed:
        mov     eax,1
finish:
        pop     edi esi ebx
        ret
endp
proc ZoomProc hwnd:DWORD,uMsg:DWORD,idEv:DWORD,dwTime:DWORD
        invoke  GetCursorPos,curs
        mov     edx,[dWidth]
        shr     edx,2
        mov     eax,edx
        shr     eax,1
        sub     [curs.x],eax 
        mov     ecx,[dHeight]
        shr     ecx,2
        mov     eax,ecx
        shr     eax,1
        sub     [curs.y],eax
        CAPTUREBLT = 0x40000000
        invoke  StretchBlt, [wDC], 0, 0, [dWidth], [dHeight],\
                            [dDC], [curs.x], [curs.y], edx, ecx,\
                            CAPTUREBLT+MERGECOPY
        ret
endp
section '.idata' import data readable writeable
  library kernel32,'kernel32.dll',\
          user32,'user32.dll',\
          gdi32,'gdi32.dll'
  include 'includes\api\kernel32.inc'
  include 'includes\api\gdi32.inc'
  include 'includes\api\user32.inc'
section '.rsrc' resource data readable
  directory RT_DIALOG,dialogs
  resource dialogs,\
           1,LANG_ENGLISH+SUBLANG_DEFAULT,demonstration
  dialog demonstration,'ScreenMagnifier',0,0,150,150,WS_CAPTION+WS_SYSMENU+DS_CENTER+DS_SYSMODAL
    dialogitem 'STATIC','',ID_ZOOM,0,0, 150, 150, WS_VISIBLE
  enddialog