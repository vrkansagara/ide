Option Explicit

' Sleep interval in milliseconds (10 seconds)
Const SLEEP_INTERVAL = 10000

' Function to get end time from user, with basic validation
Function GetEndTime(defaultTime)
    Dim input, dt
    Do
        input = InputBox("Enter end time in 24-hour format (e.g., 22:30):", "Set End Time", defaultTime)
        If input = "" Then
            WScript.Quit  ' User cancelled
        End If
        On Error Resume Next
        dt = CDate(input)
        On Error GoTo 0
        If IsDate(dt) Then
            GetEndTime = dt
            Exit Function
        Else
            MsgBox "Invalid time format. Please enter as HH:MM (e.g., 22:30).", vbExclamation
        End If
    Loop
End Function

' Get end time from user, default to 22:30
Dim endtime
endtime = GetEndTime("22:30")

' Create WScript.Shell object
Dim WshShell
Set WshShell = WScript.CreateObject("WScript.Shell")

' Show initial message
MsgBox "Do One Thing, And Do It Well." & vbNewLine & _
       "The script will keep switching windows until " & FormatDateTime(endtime, vbShortTime) & "." & vbNewLine & _
       "To stop early, click OK in the next dialog.", _
       vbInformation, "Window Switcher"

' Ask user if they want to start (optionally allow user to cancel)
Dim start
start = MsgBox("Ready to start window switching until " & FormatDateTime(endtime, vbShortTime) & "?" & vbNewLine & _
               "Click Cancel to exit.", vbOKCancel + vbQuestion, "Start?")

If start = vbCancel Then
    WScript.Quit
End If

' Minimize this script's window (optional, for less disruption)
WshShell.AppActivate WScript.ScriptName
WshShell.SendKeys "% {ESC}" ' Alt+Space, then 'n' for minimize may not always work in WScript host

' Main loop: keep switching windows until the end time or user interrupts
Dim response
Do Until Time > endtime
    WshShell.SendKeys "%{TAB}"
    WScript.Sleep SLEEP_INTERVAL
    ' Optionally, notify user and allow early exit every 5 minutes
    If Minute(Now) Mod 5 = 0 And Second(Now) < 10 Then
        response = MsgBox("Still running. Stop now?", vbYesNo + vbQuestion, "Continue?")
        If response = vbYes Then
            Exit Do
        End If
    End If
Loop

MsgBox "Window switching complete! Time is " & FormatDateTime(Now, vbShortTime), vbInformation, "Done"
