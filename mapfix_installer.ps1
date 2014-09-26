$version="1.8"
$offset=0x923
$newvalue=0xFF
$classfile="bue.class"
$postfix="_mapfix"

Set-Location -Path $env:APPDATA\.minecraft\versions

if (Test-Path $version) {
  if (Test-Path $version$postfix)
  {
    Write-Host Folder $version$postfix already exists!
  }
  else
  {
    New-Item $version$postfix -type directory
    Copy-Item $version\* $version$postfix -Recurse
    Set-Location -Path $version$postfix
    jar xf $version".jar" $classfile
    $bytes = [System.IO.File]::ReadAllBytes($env:APPDATA + "\.minecraft\versions\" + $version + $postfix + "\" + $classfile);
    $bytes[$offset] = $newvalue;
    [System.IO.File]::WriteAllBytes($env:APPDATA + "\.minecraft\versions\" + $version + $postfix + "\" + $classfile, $bytes);
    Move-Item $version".jar" $version$postfix".jar"
    jar Muf $version$postfix".jar" $classfile
    Remove-Item $classfile
    $in='^\s*"id":\s*"' + $version + '",.*$'
    $out='  "id": "' + $version + $postfix + '",'
    (Get-Content $version".json") -replace $in, $out | Set-Content $version$postfix".json"
    Remove-Item $version".json"
    Write-Host Done!
  }
}
else
{
  Write-Host Folder $version not found
}
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

