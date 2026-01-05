dim objShell
dim rootDir = "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
set objShell = Wscript.CreateObject("Wscript.Shell")

if msgbox("Do you want to turn proxy on?", vbQuestion or vbYesNo) = vbYes then
objShell.RegWrite rootDir . "\ProxyEnable", 1, "REG_DWORD"
objShell.RegWrite rootDir . "\ProxyServer", "proxy:8080", "REG_SZ"
else
objShell.RegWrite rootDir . "\ProxyEnable", 0, "REG_DWORD"
end if

Set objShell = Nothing
