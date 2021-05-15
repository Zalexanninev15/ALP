; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
ID_TXT = 101
section '.data' data readable writeable
szOn    db 'Drive '
drv1    db 'X: connected!',13,10,0
szOff   db 'Drive '
drv2    db 'X: removed!',13,10,0
DBT_DEVICEARRIVAL        = 0x8000
DBT_DEVICEREMOVECOMPLETE = 0x8004
DBT_DEVTYP_VOLUME        = 0x00000002
struct DEV_BROADCAST
        dbch_size       dd ?
        dbch_devicetype dd ?
        dbch_reserved   dd ?
        dbcv_unitmask   dd ?
        dbcv_flags      dd ?
ends
virtual at 0
event   DEV_BROADCAST
end     virtual
section '.code' code readable executable
start:
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
        cmp     [msg],WM_DEVICECHANGE
        je      update_usb
        xor     eax,eax
        jmp     finish
update_usb:
        cmp     [wparam],DBT_DEVICEARRIVAL
        je      usb_connected
        cmp     [wparam],DBT_DEVICEREMOVECOMPLETE
        je      usb_disconnected
        jmp     processed
usb_connected:
        mov     esi,[lparam]
        cmp     dword [esi+event.dbch_devicetype],DBT_DEVTYP_VOLUME
        jne     processed
        mov     eax,[esi+event.dbcv_unitmask]
        bsr     eax,eax
        add     al,'A'
        mov     byte [drv1],al
        stdcall AddLog,[hwnddlg],ID_TXT,szOn
        jmp     processed
usb_disconnected:
        mov     esi,[lparam]
        cmp     dword [esi+event.dbch_devicetype],DBT_DEVTYP_VOLUME
        jne     processed
        mov     eax,[esi+event.dbcv_unitmask]
        or      eax,eax
        jz      processed
        bsr     eax,eax
        add     al,'A'
        mov     byte [drv2],al
        stdcall AddLog,[hwnddlg],ID_TXT,szOff
        jmp     processed
wminitdialog:
        jmp     processed
wmcommand:
        cmp     [wparam],BN_CLICKED shl 16 + IDCANCEL
        je      wmclose
        jmp     processed
wmclose:
        invoke  EndDialog,[hwnddlg],0
processed:
        mov     eax,1
finish:
        pop     edi esi ebx
        ret
endp
proc    AddLog  hWnd:dword,CtrlID:dword,pStr:dword
        push    eax
        invoke  GetDlgItem,[hWnd],[CtrlID]
        or      eax,eax
        jz      .AddLog_1
        mov     [CtrlID],eax
        invoke  SendMessage,[CtrlID],EM_GETLINECOUNT,0,0
        dec     eax
        invoke  SendMessage,[CtrlID],EM_LINEINDEX,eax,0
        invoke  SendMessage,[CtrlID],EM_SETSEL,eax,eax
        invoke  SendMessage,[CtrlID],EM_REPLACESEL,FALSE,[pStr]
.AddLog_1:
        pop     eax
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
  dialog demonstration,"RemovableUsbStatus",0,0,180,140,WS_CAPTION+DS_CENTER+WS_POPUP+WS_SYSMENU+DS_MODALFRAME+DS_SYSMODAL
    dialogitem 'EDIT','',ID_TXT,5,5,170,130,WS_VISIBLE+WS_BORDER+ES_READONLY+ES_MULTILINE+WS_VSCROLL+WS_HSCROLL
  enddialog