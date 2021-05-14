; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
ID_CPU = 101
section '.data' data readable writeable
mask  db 'Vendor ID: %s',13,10,'CPU: %s',0
buff1 rb 49
buff2 rb 13
buff  rb 100h
section '.code' code readable executable
  start:
        pushfd
        pop     eax
        mov     ebx,eax
        xor     eax, 200000h
        push    eax
        popfd
        pushfd
        pop     eax
        cmp     eax,ebx
        je      cpuid_not_supported
        invoke  GetModuleHandle,0
        invoke  DialogBoxParam,eax,1,HWND_DESKTOP,DialogProc,0
cpuid_not_supported:
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
        mov     edi,buff2
        xor     eax,eax
        cpuid
        mov     eax,ebx
        stosd
        mov     eax,edx
        stosd
        mov     eax,ecx
        stosd
        stdcall GetCPUString,buff1,TRUE
        invoke  wsprintf,buff,mask,buff2,buff1
        add     esp,16
        invoke  SetDlgItemText,[hwnddlg],ID_CPU,buff
        jmp     .processed
  .wmcommand:
        cmp     [wparam],BN_CLICKED shl 16 + IDCANCEL
        je      .wmclose
        jmp     .processed
  .wmclose:
        invoke  EndDialog,[hwnddlg],0
  .processed:
        mov     eax,1
  .finish:
        pop     edi esi ebx
        ret
	endp

proc    GetCPUString lpBuff:DWORD, dFixString:DWORD
        pusha
        mov     esi,[lpBuff]
        mov     edi,esi
        cld
        mov     eax,80000002h
@@:
        push    eax
        cpuid
        stosd
        xchg    eax,ebx
        stosd
        xchg    eax,ecx
        stosd
        xchg    eax,edx
        stosd
        pop     eax
        inc     eax
        cmp     eax,80000004h
        jbe     @b
        xor     eax,eax 
        stosb
        cmp     [dFixString],0
        je      .loc_ret
        mov     edi,esi
@@:
        cmp     byte [esi],' '
        jne     @f
        inc     esi
        jmp     @b
@@:
        xor     ebx,ebx
.loc_clean_string:
        lodsb
        cmp     al,' '
        jnz     @f
        cmp     bl,1
        je      .loc_clean_string
        mov     bl,1
        jmp     .loc_store_char
@@:
        mov     bl,0
        cmp     al,'('
        jne     @f
        cmp     word [esi],'R)'
        jne     @f
        lodsw
        mov     al,0AEh
        jmp     .loc_store_char
@@:
        cmp     dword [esi-1],'(TM)'
        je      @f
        cmp     dword [esi-1],'(tm)'
        jne     .loc_store_char
@@:
        lodsw
        lodsb
        mov     al,099h
.loc_store_char:
        stosb
        or      al,al
        jnz     .loc_clean_string
        cmp     byte [edi-1],' '
        jne     .loc_ret
        mov     byte [edi-1],0
.loc_ret:
        popa
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
           1,LANG_ENGLISH+SUBLANG_DEFAULT,demonstration
  dialog demonstration,'MyCpuName',0,0,180,30,WS_CAPTION+WS_SYSMENU+DS_CENTER+DS_SYSMODAL,0,0,'Arial',12
    dialogitem 'BUTTON','',0, 0, -1, 180, 35,BS_GROUPBOX
    dialogitem 'EDIT','',ID_CPU,0,0,180,50,WS_VISIBLE+ES_CENTER+ES_MULTILINE+ES_READONLY+WS_BORDER
  enddialog