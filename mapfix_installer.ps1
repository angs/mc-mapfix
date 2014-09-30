$version="1.8"
$offset=0x923
$newvalue=0xFF
$classfile="bue.class"
$postfix="_mapfix"
if (Get-Command "jar" -ErrorAction SilentlyContinue) {
  Write-Host Using jar
  $haveJar = 1
}
else {
  $haveJar = 0
  if (Get-Command "./7za.exe" -ErrorAction SilentlyContinue){
    Write-Host Using 7-zip
    $7zip = (Get-Item "./7za.exe").fullname
  }
  else {
    if (Get-Command "7za.exe" -ErrorAction SilentlyContinue){
      Write-Host Using 7-zip
      $7zip = "7za"
    }
    else {
      Write-Host Program jar or 7za not found. Please install the java JDK or the 7-zip Command Line Version.
      Write-Host "Press any key to continue..."
      $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
      exit
    }
  }
}

Set-Location -Path $env:APPDATA\.minecraft\versions

if (Test-Path $version) {
  if (Test-Path $version$postfix){
    Write-Host Folder $version$postfix already exists!
  }
  else
  {
    $null = New-Item $version$postfix -type directory
    Copy-Item $version\* $version$postfix
    Set-Location -Path $version$postfix
    if ($haveJar){
      & jar xf $version".jar" $classfile
    }
    else {
      & $7zip e $version".jar" $classfile
    }
    $bytes = [System.IO.File]::ReadAllBytes($env:APPDATA + "\.minecraft\versions\" + $version + $postfix + "\" + $classfile);
    $bytes[$offset] = $newvalue;
    [System.IO.File]::WriteAllBytes($env:APPDATA + "\.minecraft\versions\" + $version + $postfix + "\" + $classfile, $bytes);
    Move-Item $version".jar" $version$postfix".jar"
    if ($haveJar){
      & jar Muf $version$postfix".jar" $classfile
    }
    else {
      & $7zip a $version$postfix".jar" $classfile
      & $7zip d $version$postfix".jar" "META-INF\MANIFEST.MF"
    }
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
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")