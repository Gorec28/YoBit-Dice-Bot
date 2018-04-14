#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <FontConstants.au3>
#include <File.au3>
#include <IE.au3>
#include "SplashScreenFunction.au3"



FileInstall("SplashScreen.jpg", @TempDir & "SplashScreen.jpg")
$temp_img = @TempDir & "SplashScreen.jpg"
SplashScreen('', 320, 56, -1, -1, $temp_img, $SC_FADE_IN, $SC_FADE_OUT, 1000)
FileDelete(@TempDir & "SplashScreen.jpg")



#AutoIt3Wrapper_Icon = icon.ico
TraySetIcon("icon.ico")


Local $coin, $balance, $bet, $StopLoss, $DiceRoll, $profit, $hidden = 1
$title = 'YoBit Dice Bot'
$domen = 'yobit.net'
$lang = 'ru'


Global $Paused
HotKeySet("{PAUSE}", "TogglePause")
HotKeySet("{ESC}", "Terminate")

Func TogglePause()
	$Paused = NOT $Paused
	If $Paused Then
		SplashTextOn('', $title & ' is Paused ', 400, 60, -1, -1, 1, '', 24)
	EndIf
	While $Paused
		sleep(100)
	WEnd
	SplashOff()
EndFunc

Func Terminate()
	Exit 0
EndFunc




func GetBalance($coin)
	$oBalance = _IEPropertyGet($oInputCurrency, "innertext")
	$aRes = StringRegExpReplace($oBalance, '\S+ \(\D+\) - (\d+\.\d+) (\w+)', '$2|$1')
	$aResArr = StringSplit($aRes, ' ', 1)
	For $i = 1 To $aResArr[0]
		$aArr = StringSplit($aResArr[$i], '|', 1)
		If $aArr[1] = $coin Then
			$coinBalance = $aArr[2]
			Return $coinBalance
		EndIf
	Next
endfunc


func InputBet($bet)	;	Human emulation delay in entering a bet
	MouseMove($iBetX + $iBetW/2, $iBetY + $iBetH/2)
	MouseClick("", Default, Default, 3)
	Sleep(Random(100, 250))
	$betArr = StringSplit($bet, '', 1)
	For $i = 1 To $betArr[0]
		Opt("SendKeyDelay", Random(100, 250, 1))
		Send($betArr[$i])
	Next
endfunc


func Roll_48()
	MouseMove($iBetPosX + Random(230, 280), $iBetPosY + Random(-12, 12), Random(200, 350))
	Sleep(Random(50, 200))
	MouseClick("left")
endfunc


func Roll_52()
	MouseMove($iBetPosX + Random(320, 370), $iBetPosY + Random(-12, 12), Random(200, 350))
	Sleep(Random(50, 200))
	MouseClick("left")
endfunc


func SaveLogHTML($balance, $initialCoinBalance, $DiceRollLeft)
	$profit = Round($balance - $initialCoinBalance, 10)
	_IEPropertySet($oDivInfo, "innerhtml", "<div><span>Coin: " & $coin & " </span><span>Bet: " & $bet & " </span><span'>Profit: " & $profit & " </span><span'>Throws left: " & $DiceRollLeft & "</span></div>")
endfunc


func msg($text)
	MsgBox(0, $title, $text)
endfunc


func SaveLogFile($text)
	$hFile = FileOpen("statistics.txt", 1)
	_FileWriteLog($hFile, $text)
	FileClose($hFile)
endfunc



func StartRoll()
	$balanceBefore = GetBalance($coin)
	$betBefore = 0
	$rollBefore = 0
;	$DiceRoll = 500

	For $i = 1 To $DiceRoll

		;;;	Waiting for balance changes when server response is delayed
		If GetBalance($coin) == $balanceBefore AND $i > 1 Then
			SplashTextOn('', 'Wait', 400, 60, -1, -1, 1, '', 24)
		EndIf
		While GetBalance($coin) == $balanceBefore AND $i > 1
			sleep(100)
		WEnd
		SplashOff()
		;;;

		$DiceRollLeft = $DiceRoll - $i
		SaveLogHTML($balanceBefore, $initialCoinBalance, $DiceRollLeft)

		If GetBalance($coin) < $balanceBefore Then	;;;	Lose
			$balanceBefore = GetBalance($coin)
			$betBefore *= 2

			;;; Stop Lose checking
			$balanceIfLose = $initialCoinBalance - $balanceBefore - $betBefore
			If $balanceIfLose > $StopLoss Then
				$confirm = MsgBox(4, "Confirmation", "If you are not lucky the overall loss will be:" & $balanceIfLose & @CRLF & "This message will be shown again if you lose" & @CRLF & "Are you sure you want to Stop and exit from the YoBit Dice Bot?")
				If $confirm == 6 Then
					Exit
				EndIf
			EndIf
			;;;

			InputBet($betBefore)
			If $rollBefore == 0 Then
				Roll_48()
				$rollBefore = 0
			Else
				Roll_52()
				$rollBefore = 1
			EndIf
		Else	;;;	Win or Start
			$balanceBefore = GetBalance($coin)
			If $betBefore <> $bet Then
				$betBefore = $bet
				InputBet($bet)
			EndIf
			If $rollBefore == 0 Then
				Roll_52()
				$rollBefore = 1
			Else
				Roll_48()
				$rollBefore = 0
			EndIf
		EndIf
		SaveLogFile("Balance:	" & GetBalance($coin) & "	Bet:	" & $betBefore)
		--$DiceRollLeft
		Sleep(1000)
	Next
endfunc



















Local $oIE = _IECreate("https://" & $domen & "/" & $lang & "/dice/", 0, 1, 0, 1)
_IELoadWait($oIE)
$oInputCurrency = _IEGetObjByName($oIE, "currency")
$oBalance = _IEPropertyGet($oInputCurrency, "innertext")
;	$oBalance = "LIZA (Bitcoin Liza) - 12.93237493 LIZA GT (GTcoin) - 7.6820213 GT RUR (RUR) - 5.23294004 RUR"
;	$CoinList = "LIZA: 12.93237493|GT: 7.6820213|RUR: 5.23294004|BTC: 5.23294004|LTC: 700.25489618|DOGE: 1054.12345678|GT: 7.6820213|RUR: 5.23294004|BTC: 5.23294004|LTC: 700.25489618|DOGE: 1054.12345678|GT: 7.6820213|RUR: 5.23294004|BTC: 5.23294004|LTC: 700.25489618|DOGE: 1054.12345678"
$CoinList = StringRegExpReplace($oBalance, '\S+ \(\D+\) - (\d+\.\d+) (\w+) ?', '$2: $1|')
$CoinList = StringTrimRight($CoinList, 1)
SaveLogFile($CoinList)





;Exit



#Region GUI

$hGUI = GUICreate($title, 480, 250)
GUISetFont(10)


GUICtrlCreateLabel('Select a coin:', 10, 13)
;$CoinList = "LIZA: 123456789.93237493|GT: 7.6820213|RUR: 5.23294004|BTC: 5.23294004|LTC: 700.25489618|DOGE: 1054.12345678|GT: 7.6820213|RUR: 5.23294004|BTC: 5.23294004|LTC: 700.25489618|DOGE: 1054.12345678|GT: 7.6820213|RUR: 5.23294004|BTC: 5.23294004|LTC: 700.25489618|DOGE: 1054.12345678"
$CoinChoice = GUICtrlCreateCombo("", 95, 10, 150, 550, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_NOINTEGRALHEIGHT))
GUICtrlSetData(-1, $CoinList, "")
GUICtrlSendMsg(-1, $CB_SETDROPPEDWIDTH, 150, 0)


GUICtrlCreateLabel('Select a bet:', 10, 44)
$BetList = "0.00000001|0.0000001|0.000001|0.00001|0.0001|0.001|0.01|0.1|1|10|100|1000"
$BetChoice = GUICtrlCreateCombo("", 95, 40, 150, 550, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_NOINTEGRALHEIGHT))
GUICtrlSetData(-1, $BetList, "")
GUICtrlSendMsg(-1, $CB_SETDROPPEDWIDTH, 150, 0)


GUICtrlCreateLabel(	"This software is supplied AS IS without any warranties and support." & @CRLF & @CRLF & _
					"1: Bot only works with IE." & @CRLF & _
					"2: You must be logged in to IE on the site " & $domen & "." & @CRLF & _
					"3: Bot works on the strategy of Martingale" & @CRLF & _
					"4: PAUSE - pause the script. ESC - terminate script", 10, 80)


GUICtrlCreateLabel('Stop Loss:*', 260, 13)
GUICtrlSetTip(-1, "How much are you willing to lose?" & @CRLF & "If it's bad luck")
Local $StopLossChoice = GUICtrlCreateInput('', 330, 10, 140, 20)


GUICtrlCreateLabel('Dice rolls:*', 260, 44)
GUICtrlSetTip(-1, 'Number of dice rolls.' & @CRLF & 'Recommended at least 10.')
$NumberDiceRoll = "|100|500|1000|5000|10000"
$DiceRollChoice = GUICtrlCreateCombo("", 330, 40, 50, 550, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_NOINTEGRALHEIGHT))
GUICtrlSetData(-1, $NumberDiceRoll, "")
GUICtrlSendMsg(-1, $CB_SETDROPPEDWIDTH, 50, 0)


$RunBot	= GUICtrlCreateButton("Run Bot", 370, 200, 70, 30)
$Exit	= GUICtrlCreateButton("Exit", 250, 200, 70, 30)
GUICtrlSetState($RunBot, $GUI_DISABLE)

GUISetState()

While 1

	If $coin <> '' And $DiceRoll <> '' And $bet > 0 And $hidden == 1 Then
		GUICtrlSetState($RunBot, $GUI_ENABLE)
		$hidden = 0
	EndIf

	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop

		Case $CoinChoice
			$coinTemp = GUICtrlRead($CoinChoice)
			$coinTemp = StringRegExp($coinTemp, '(.*): (\d+.\d+)', 2)
			$coin = $coinTemp[1]
			$balance = $coinTemp[2]

			GUICtrlSetData($StopLossChoice, '' & $balance)

		Case $BetChoice
			$bet = GUICtrlRead($BetChoice)

		Case $StopLossChoice
			$StopLoss = GUICtrlRead($StopLossChoice)

		Case $DiceRollChoice
			$DiceRoll = GUICtrlRead($DiceRollChoice)

		Case $RunBot
			; Save to log file initial data
			SaveLogFile(@CRLF & @TAB & 'Coin: ' & $coin & ': ' & $balance & @CRLF & @TAB & 'Stop Loss: ' & $StopLoss & @CRLF & @TAB & 'Bet: ' & $bet & @CRLF & @TAB & 'Dice Roll: ' & $DiceRoll)

			SplashTextOn('', "Please wait. Reload page to:" & @CRLF & "https://" & $domen & "/" & $lang & "/dice/" & $coin, 400, 60, -1, -1, 1, '', 12)
			_IENavigate($oIE, "https://" & $domen & "/" & $lang & "/dice/" & $coin)
			_IELoadWait($oIE)
			SplashOff()

			$oDiv = _IEGetObjById($oIE, "DataTables_Table_0_wrapper")
			_IEDocInsertHTML($oDiv, "<div id='writeInfo' style='font-size:1.5em;color:red'><div>", "beforebegin")
			$oDivInfo = _IEGetObjById($oIE, "writeInfo")
			$oInputCurrency = _IEGetObjByName($oIE, "currency")

			ExitLoop

		Case $Exit
			Exit 0

	EndSwitch
WEnd
GUIDelete()
#EndRegion GUI





; Получает координаты и размеры области для ввода ставки
;
$oInputBet = _IEGetObjByName($oIE, "bet")
$iBetX = _IEPropertyGet($oInputBet, "screenx")
$iBetY = _IEPropertyGet($oInputBet, "screeny")
$iBetW = _IEPropertyGet($oInputBet, "width")
$iBetH = _IEPropertyGet($oInputBet, "height")
$iBetPosX = $iBetX + $iBetW/2
$iBetPosY = $iBetY + $iBetH/2



; Save to log file initial data
$initialCoinBalance = GetBalance($coin)
;$text = @CRLF & "	Coin:	" & $coin & @CRLF & "	Balance:	" & $initialCoinBalance & @CRLF & "	Bet:		" & $bet
;SaveLogFile($text)

;IniWrite("Settings.ini", "Coin", $coin, $initialCoinBalance)
;IniWrite("Settings.ini", "Bet", "Bet", $bet)




Sleep(2000)

StartRoll()



; Save to log file finally data
$CurrentCoinBalance = GetBalance($coin)
$text = @CRLF & "	Coin:	 " & $coin & _
		@CRLF & "	Balance: " & $CurrentCoinBalance & _
		@CRLF & "	Bet:	 " & $bet & _
		@CRLF & "	Profit:	 " & $CurrentCoinBalance - $initialCoinBalance
SaveLogFile($text)

Exit