[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon

$objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$objNotifyIcon.BalloonTipIcon = "Info" 
$objNotifyIcon.BalloonTipText = "Testing" 
$objNotifyIcon.BalloonTipTitle = "cracked catastrophe?"
$objNotifyIcon.Visible = $True

$objNotifyIcon.ShowBalloonTip(10000)
Start-Sleep 500