; =============================================
;   FASM 1.73.09
;   FASM 1.73.35, tested
;   CPUID demo (32-bit Windows)
;   xiao_laba_cn@yahoo.com
;   2019-03-24
; =============================================


format PE console          ; �� 32-bit
; or format ELF
use32                      ; or default in 32-bit formats



entry start

include 'win32a.inc'

; =============================================================

section '.text' code readable executable

start:

    push    msg_xiao
    call    [printf]
    add     esp, 4

    ; ────────────────
    ;  CPUID 0 - Vendor
    ; ────────────────
    xor     eax,eax
    cpuid

    ; CPU's manufacturer ID string �V a twelve-character ASCII string stored in EBX, EDX, ECX (in that order).
    mov     dword [vendor+0],ebx
    mov     dword [vendor+4],edx
    mov     dword [vendor+8],ecx
    mov     byte [vendor+12],0

    ; Print vendor string
    push    vendor
    push    msg_vendor
    call    [printf]
    add     esp, 8

    call dump_registers



    ; ───────────────────────────────
    ;  CPUID 1 - Version & Features
    ; ───────────────────────────────
    ;mov     eax,80000000h
    mov     eax,1
    cpuid

    call dump_registers

    mov     [cpu_features],edx
    mov     [cpu_features+4],ecx

    ; Print stepping / model / family
    mov     eax,1
    cpuid

    push    eax
    push    msg_version
    call    [printf]
    add     esp, 8

    ; Some popular feature flags (EDX)
    test    edx, 1 shl 4            ; TSC
    jz      @f
    push    str_tsc
    call    print_feature
@@:
    test    edx, 1 shl 23           ; MMX
    jz      @f
    push    str_mmx
    call    print_feature
@@:
    test    edx, 1 shl 25           ; SSE
    jz      @f
    push    str_sse
    call    print_feature
@@:
    test    edx, 1 shl 26           ; SSE2
    jz      @f
    push    str_sse2
    call    print_feature
@@:

    ; Some popular ECX flags
    test    ecx, 1 shl 0            ; SSE3
    jz      @f
    push    str_sse3
    call    print_feature
@@:
    test    ecx, 1 shl 9            ; SSSE3
    jz      @f
    push    str_ssse3
    call    print_feature
@@:
    test    ecx, 1 shl 19           ; SSE4.1
    jz      @f
    push    str_sse41
    call    print_feature
@@:
    test    ecx, 1 shl 20           ; SSE4.2
    jz      @f
    push    str_sse42
    call    print_feature
@@:
    test    ecx, 1 shl 28           ; AVX
    jz      @f
    push    str_avx
    call    print_feature
@@:
    test    ecx, 1 shl 5            ; AES-NI
    jz      @f
    push    str_aesni
    call    print_feature
@@:

    ; Exit
    push    0
    call    [ExitProcess]


dump_registers:
    push eax
    push eax_dump
    call    [printf]
    add     esp, 8

    push ebx
    push ebx_dump
    call    [printf]
    add     esp, 8

    push ecx
    push ecx_dump
    call    [printf]
    add     esp, 8

    push edx
    push edx_dump
    call    [printf]
    add     esp, 8

    ret     4



; ────────────────────────────────────────────────
;  Helpers
; ────────────────────────────────────────────────

print_feature:
    push    dword [esp+4]           ; string
    push    msg_feature
    call    [printf]
    add     esp, 8
    ret     4


; =============================================================

section '.data' data readable writeable

msg_xiao        db "by xiao_laba_cn@yahoo.com",13,10,0

msg_vendor      db "CPU Vendor : %s",13,10,0
msg_version     db "CPUID.1 EAX = %08Xh  (Family/Model/Stepping)",13,10,0
msg_feature     db "  %s",13,10,0

eax_dump     db "EAX = %08Xh, ",0
ebx_dump     db "EBX = %08Xh, ",0
ecx_dump     db "ECX = %08Xh, ",0
edx_dump     db "EDX = %08Xh",13,10,13,10,0


str_tsc         db "TSC",0
str_mmx         db "MMX",0
str_sse         db "SSE",0
str_sse2        db "SSE2",0
str_sse3        db "SSE3",0
str_ssse3       db "SSSE3",0
str_sse41       db "SSE4.1",0
str_sse42       db "SSE4.2",0
str_avx         db "AVX",0
str_aesni       db "AES-NI",0

vendor          db 13 dup (0)

cpu_features    dd 0,0

; =============================================================

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
          msvcrt, 'MSVCRT.DLL'

  import kernel32,\
         ExitProcess,'ExitProcess'

  import msvcrt,\
         printf,'printf'