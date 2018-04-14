; #FUNCTION# ==============================================================================================================
; Название...:  SplashScreen.au3
; Описание...:  Функция создаёт Splash Screen окно.
; Синтаксис..: _CreateSplashScreen($SC_TTITLE, $SC_WIDTH, $SC_HEIGHT, $SC_X, $SC_Y, $SC_BITMAP, $SC_STARTEFFECT, $SC_CLOSEEFFECT, $SC_TIME)
; Параметры..: $SC_TITLE - Заголовок окна.
;                   $SC_WIDTH       - Ширина окна.
;                   $SC_HEIGHT      - Высота окна.
;                   $SC_X           - Координата левого края.
;                   $SC_Y           - Координата верхнего края.
;                   $SC_BITMAP      - Изображение.
;                   $SC_STARTEFFECT - данный параметр задаёт эффект при появлении Splash Screen окна.
;                   $SC_CLOSEEFFECT - данный параметр задаёт эффект при закрытии Splash Screen окна.
;                   $SC_TIME        - длительность показа окна (в миллисекундах).
; Автор......: Zaramot
; =========================================================================================================================

;Эффекты
Global Const $SC_EXPLODE = 0x00040010
Global Const $SC_IMPLODE = 0x00050010
Global Const $SC_FADE_IN = 0x00080000
Global Const $SC_FADE_OUT = 0x00090000
Global Const $SC_SLIDE_IN_LEFT = 0x00040001
Global Const $SC_SLIDE_OUT_LEFT = 0x00050002
Global Const $SC_SLIDE_IN_RIGHT = 0x00040002
Global Const $SC_SLIDE_OUT_RIGHT = 0x00050001
Global Const $SC_SLIDE_IN_TOP = 0x00040004
Global Const $SC_SLIDE_OUT_TOP = 0x00050008
Global Const $SC_SLIDE_IN_BOTTOM = 0x00040008
Global Const $SC_SLIDE_OUT_BOTTOM = 0x00050004
Global Const $SC_DIAG_SLIDE_IN_TL = 0x00040005
Global Const $SC_DIAG_SLIDE_OUT_TL = 0x0005000a
Global Const $SC_DIAG_SLIDE_IN_TR = 0x00040006
Global Const $SC_DIAG_SLIDE_OUT_TR = 0x00050009
Global Const $SC_DIAG_SLIDE_IN_BL = 0x00040009
Global Const $SC_DIAG_SLIDE_OUT_BL = 0x00050006
Global Const $SC_DIAG_SLIDE_IN_BR = 0x0004000a
Global Const $SC_DIAG_SLIDE_OUT_BR = 0x00050005
Global Const $SC_DEFAULT = 0x00000000

;Стили окна
Global Const $WS_POPUP = 0x80000000
Global Const $WS_EX_TOPMOST = 0x00000008

;Переменные
Global $SC_GUI, $SC_TTITLE, $SC_WIDTH, $SC_HEIGHT, $SC_X, $SC_Y, $SC_BITMAP, $SC_STARTEFFECT, $SC_CLOSEEFFECT, $SC_TIME

Func SplashScreen($SC_TTITLE, $SC_WIDTH, $SC_HEIGHT, $SC_X, $SC_Y, $SC_BITMAP, $SC_STARTEFFECT, $SC_CLOSEEFFECT, $SC_TIME)
    $SC_GUI = GUICreate($SC_TTITLE, $SC_WIDTH, $SC_HEIGHT, $SC_X, $SC_Y, $WS_POPUP, $WS_EX_TOPMOST)
    GUICtrlCreatePic($SC_BITMAP, 0, 0, $SC_WIDTH, $SC_HEIGHT)
    DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $SC_GUI, "int", 1000, "long", $SC_STARTEFFECT)
    GUISetState()
    Sleep($SC_TIME)
    DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $SC_GUI, "int", 1000, "long", $SC_CLOSEEFFECT)
    GUIDelete($SC_GUI)
EndFunc