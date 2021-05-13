; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
section '.data' data readable writeable  
title   db 'CdRomStatus',0
status1 db 'X: = Status: Opened',0
status2 db 'X: = Status: Closed',0
tmp     dd ? 
buff    rb 100h 
LogicalDriveStringSize  = 500
LogicalDriveString      rb LogicalDriveStringSize
struct SCSI_PASS_THROUGH_DIRECT
        Length             dw ?
        ScsiStatus         db ?
        PathId             db ?
        TargetId           db ?
        Lun                db ?
        CdbLength          db ?
        SenseInfoLength    db ?
        DataIn             dd ?
        DataTransferLength dd ?
        TimeOutValue       dd ?
        DataBuffer         dd ?
        SenseInfoOffset    dd ?
        Cdb                rb 16
ends
struct SCSI_PASS_THROUGH_DIRECT_BUFFER
        Header          SCSI_PASS_THROUGH_DIRECT
        SenseBuffer     rb 20h
        DataBuffer      rb 0C0h
ends
tscbuff SCSI_PASS_THROUGH_DIRECT_BUFFER
section '.code' code readable executable
SCSI_IOCTL_DATA_IN      = 1
SCSIOP_MECHANISM_STATUS = 0BDh
IOCTL_SCSI_PASS_THROUGH = 4D004h
start:
        invoke  GetLogicalDriveStrings,LogicalDriveStringSize,LogicalDriveString
        mov     esi,LogicalDriveString
        xor     edi,edi
scan_drive_loop:
        cmp     byte [esi],0
        je      scan_drive_end
        push    esi
        invoke  lstrlen,esi
        add     esi,eax
        dec     esi
        mov     byte [esi],0
        pop     esi
        push    esi
        invoke  GetDriveType,esi
        cmp     eax,DRIVE_CDROM
        jne     scan_drive_next
        mov     al,[esi]
        mov     byte [status1],al
        mov     byte [status2],al
        invoke  lstrcpy,buff,path
        invoke  lstrcat,buff,esi
        invoke  CreateFile,buff,GENERIC_WRITE or GENERIC_READ,\
                FILE_SHARE_READ or FILE_SHARE_WRITE,\
                NULL,OPEN_EXISTING,NULL,NULL
        mov     ebx,eax
        mov     [tscbuff.Header.Length],sizeof.SCSI_PASS_THROUGH_DIRECT
        mov     [tscbuff.Header.CdbLength],12
        mov     [tscbuff.Header.DataIn],SCSI_IOCTL_DATA_IN
        mov     [tscbuff.Header.DataTransferLength],192
        mov     [tscbuff.Header.TimeOutValue],10
        lea     eax,[tscbuff.DataBuffer]
        sub     eax,tscbuff
        mov     [tscbuff.Header.DataBuffer],eax
        mov     byte [tscbuff.Header.Cdb+0],SCSIOP_MECHANISM_STATUS
        mov     byte [tscbuff.Header.Cdb+8],8
        invoke  DeviceIoControl,ebx,IOCTL_SCSI_PASS_THROUGH,tscbuff,\
                10Ch,tscbuff,10Ch,tmp,NULL
        mov     al,[tscbuff.DataBuffer+1]
        and     al,10h
        mov     edi,status1
        or      al,al
        jnz     @f
        mov     edi,status2
@@:
        invoke  MessageBox,HWND_DESKTOP,edi,title,MB_OK+MB_ICONINFORMATION
        invoke  CloseHandle,ebx
scan_drive_next:
        pop     esi
        invoke  lstrlen,esi
        add     esi,eax
        lodsw
        jmp     scan_drive_loop
scan_drive_end:
        invoke  ExitProcess,0
path    db '\\.\',0
section '.idata' import data readable writeable
library kernel32,"kernel32.dll",\
        user32,"user32.dll"
 include "includes\api\kernel32.inc"
 include "includes\api\user32.inc"