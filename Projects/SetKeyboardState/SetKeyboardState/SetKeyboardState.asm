; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
ID_NUM          = 100
ID_CAPS         = 101
ID_SCROLL       = 102
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
        xor     eax,eax
        jmp     .finish
  .wminitdialog:
        invoke  GetKeyState,VK_CAPITAL
        invoke  CheckDlgButton,[hwnddlg],ID_CAPS,eax
        invoke  GetKeyState,VK_NUMLOCK
        invoke  CheckDlgButton,[hwnddlg],ID_NUM,eax
        invoke  GetKeyState,VK_SCROLL
        invoke  CheckDlgButton,[hwnddlg],ID_SCROLL,eax
        jmp     .processed
  .wmcommand:
        cmp     [wparam],BN_CLICKED shl 16 + IDCANCEL
        je      .wmclose
        cmp     [wparam],BN_CLICKED shl 16 + ID_CAPS
        je      .wm_caps
        cmp     [wparam],BN_CLICKED shl 16 + ID_NUM
        je      .wm_num
        cmp     [wparam],BN_CLICKED shl 16 + ID_SCROLL
        je      .wm_scroll
        jmp     .processed
  .wm_caps:
        invoke  IsDlgButtonChecked,[hwnddlg],ID_CAPS
        stdcall SetLockState,VK_CAPITAL,eax
        jmp     .processed
  .wm_num:
        invoke  IsDlgButtonChecked,[hwnddlg],ID_NUM
        stdcall SetLockState,VK_NUMLOCK,eax
        jmp     .processed
  .wm_scroll:
        invoke  IsDlgButtonChecked,[hwnddlg],ID_SCROLL
        stdcall SetLockState,VK_SCROLL,eax
        jmp     .processed
  .wmclose:
        invoke  EndDialog,[hwnddlg],0
  .processed:
        mov     eax,1
  .finish:
        pop     edi esi ebx
        ret
endp
proc SetLockState dKey:DWORD, dState:DWORD
        pusha
        invoke  GetKeyState,[dKey]
        cmp     eax,[dState]
        je      @f
        invoke  keybd_event,[dKey],0,0,NULL
        invoke  keybd_event,[dKey],0,KEYEVENTF_KEYUP,NULL
@@:
        popa
        ret
endp
section '.idata' import data readable writeable
  library kernel32,'KERNEL32.DLL',\
          user32,'USER32.DLL'
  include 'includes\api\kernel32.inc'
  include 'includes\api\user32.inc'
section '.rsrc' resource data readable
  directory RT_DIALOG,dialogs
  resource dialogs,\
           37,LANG_ENGLISH+SUBLANG_DEFAULT,demonstration
  dialog demonstration,'SetKeyboardState',0,0,180,30,WS_CAPTION+WS_SYSMENU+DS_CENTER+DS_SYSMODAL
    dialogitem 'BUTTON','NumLock',ID_NUM,15,12,45,8,WS_VISIBLE+BS_AUTOCHECKBOX+BS_FLAT
    dialogitem 'BUTTON','CapsLock',ID_CAPS,65,12,45,8,WS_VISIBLE+BS_AUTOCHECKBOX+BS_FLAT
    dialogitem 'BUTTON','ScrollLock',ID_SCROLL,115,12,45,8,WS_VISIBLE+BS_AUTOCHECKBOX+BS_FLAT
  enddialog