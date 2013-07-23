$timer = 5
$i = 1

Do {
  Write-host -ForeGroundColor green -noNewLine "Press any key in $($timer-$i) seconds to manual enter something"
  $pos = $host.UI.RawUI.get_cursorPosition()
  $pos.X = 0
  $host.UI.RawUI.set_cursorPosition($Pos)
  if($host.UI.RawUI.KeyAvailable) {
    $Host.UI.RawUI.FlushInputBuffer()
    write-output ""
    $something= Read-Host "Please enter the manually entered something"
    $timer=-1
  }
start-Sleep -Seconds 1

$i++
}While ($i -le $timer)



write-host $something