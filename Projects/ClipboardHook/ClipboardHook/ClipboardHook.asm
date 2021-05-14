; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
ID_TXT = 101
section '.data' code readable writeable
hNextW  dd ?
section '.code' code readable executable
  start:
        mov     [hNextW],0
        invoke  GetModuleHandle,0
        invoke  DialogBoxParam,eax,37,HWND_DESKTOP,DialogProc,0
        invoke  ExitProcess,0
proc DialogProc hwnddlg,msg,wparam,lparam
        push    ebx esi edi
        cmp     [msg],WM_INITDIALOG
        je      wminitdialog
        cmp     [msg],WM_COMMAND
        je      wmcommand
        cmp     [msg],WM_CLOSE
        je      wmclose
        cmp     [msg],WM_DRAWCLIPBOARD
        je      update_cb
        cmp     [msg],WM_CHANGECBCHAIN
        je      update_chain
        xor     eax,eax
        jmp     finish
update_chain:
        cmp     [hNextW],0
        je      processed
        mov     eax,[wparam]
        cmp     eax,[hNextW]
        jne     @f
        mov     eax,[lparam]
        mov     [hNextW],eax
        jmp     processed
@@:
        invoke  SendMessage,[hNextW],WM_CHANGECBCHAIN, [wparam], [lparam]
        jmp     processed
update_cb:
        invoke  IsClipboardFormatAvailable,CF_TEXT
        or      eax,eax
        jz      @f
        invoke  OpenClipboard,[hwnddlg]
        invoke  GetClipboardData, CF_TEXT
        invoke  SetDlgItemText,[hwnddlg],ID_TXT,eax
        invoke  CloseClipboard
@@:
        invoke  SendMessage, [hNextW], WM_DRAWCLIPBOARD, 0, 0
        jmp     processed
wminitdialog:
        invoke  SetClipboardViewer,[hwnddlg]
        mov     [hNextW],eax
        jmp     processed
wmcommand:
        cmp     [wparam],BN_CLICKED shl 16 + IDCANCEL
        je      wmclose
        jmp     processed
wmclose:
        invoke  ChangeClipboardChain,[hwnddlg],[hNextW]
        invoke  EndDialog,[hwnddlg],0
processed:
        mov     eax,1
finish:
        pop     edi esi ebx
        ret
endp
section '.idata' import data readable writeable
  library kernel32,'kernel32.dll',\
          user32,'user32.dll'
  include 'includes\api\kernel32.inc'
  include 'includes\api\user32.inc'
section '.rsrc' resource data readable
  directory RT_DIALOG,dialogs
  resource dialogs,\
           37,LANG_ENGLISH+SUBLANG_DEFAULT,demonstration
  dialog demonstration,"ClipboardHook",0,0,180,160,WS_CAPTION+DS_CENTER+WS_POPUP+WS_SYSMENU+DS_MODALFRAME+DS_SYSMODAL
    dialogitem 'EDIT','',ID_TXT,5,5,170,130,WS_VISIBLE+WS_BORDER+ES_READONLY+ES_MULTILINE+WS_VSCROLL
  enddialog