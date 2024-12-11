'Rem Time in milliseconds. WScript.Sleep 1000 results in a 1 second sleep.
' https://learnxinyminutes.com/docs/visualbasic/

set WshShell = WScript.CreateObject("WScript.Shell")

endtime = CDate("22:30")
'Rem  MsgBox "Do One Thing And Do It Well.", vbOKOnly, "hei hie !"
MsgBox "Do One Thing And Do It Well." & vbNewLine & "Make sure you leave the place.....", vbOKOnly, "Title of the dialogbox!"

Do Until Time > endtime
    WshShell.SendKeys "%{TAB}"

    WScript.Sleep(10000)

    'Rem  WScript.Sleep(1000 * 60 * 1)
    WshShell.SendKeys "%{TAB}"

Loop