param (
    [IO.FileInfo] $MSIFile
)

try {
  $windowsInstaller = New-Object -com WindowsInstaller.Installer
  $database = $windowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $Null,$windowsInstaller, @($MSIFile.FullName, 0))
  $query = "SELECT Value FROM Property WHERE Property = 'ProductCode'"
  $View = $database.GetType().InvokeMember("OpenView", "InvokeMethod", $Null, $database, ($query))
  $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)

  $record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $Null, $View, $Null)
  $productCode = $record.GetType().InvokeMember("StringData", "GetProperty", $Null, $record, 1)
  return $productCode

} catch {
    throw "Failed to get MSI Product Code. Uninstall will need to specify this explicitly" -f $_
}

