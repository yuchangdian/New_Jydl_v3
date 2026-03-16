$ErrorActionPreference = 'Stop'

[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
chcp 65001 > $null

$hdc = 'C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe'
$bundleName = 'com.example.new_jydl_v3'
$tags = 'JY_TCP_ARK,JY_TCP_NATIVE,JY_ENTRY'
$tagPattern = 'JY_TCP_ARK|JY_TCP_NATIVE|JY_ENTRY'

if (-not (Test-Path $hdc)) {
  Write-Error "hdc.exe not found: $hdc"
}

$targetList = & $hdc list targets
if (-not $targetList) {
  Write-Error 'No connected device found'
}

$processOutput = & $hdc shell "ps -ef | grep $bundleName | grep -v grep"
if (-not $processOutput) {
  Write-Error "Process not found on device: $bundleName. Launch the app first."
}

$processLine = ($processOutput | Select-String -Pattern $bundleName | Select-Object -First 1).Line
if (-not $processLine) {
  Write-Error "Process not found on device: $bundleName. Launch the app first."
}

$appPid = [regex]::Match($processLine, '^\S+\s+(\d+)').Groups[1].Value

if (-not $appPid) {
  Write-Error "Failed to parse PID from: $processLine"
}

$pidPattern = "^\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}\s+$appPid\s+"

Write-Host "Current PID: $appPid"
Write-Host "Filtering tags: $tags"
Write-Host 'Press Ctrl + C to stop'

& $hdc hilog | ForEach-Object {
  if ($_ -match $pidPattern -and $_ -match $tagPattern) {
    $_
  }
}
