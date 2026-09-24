param([string]$Compiler = 'C:/Program Files/CodeBlocks/MinGW/bin/g++.exe')
$ErrorActionPreference = 'Stop'
$testRoot = Split-Path -Parent $PSScriptRoot
$testOutput = Join-Path $testRoot 'tests/.build/jybsmr131'
New-Item -ItemType Directory -Path $testOutput -Force | Out-Null
Push-Location $testOutput
try {
  & $Compiler -std=c++17 -Wall -Wextra -Werror -static -pthread -o jybsmr131-test.exe (Join-Path $testRoot 'tests/jybsmr131-codec.test.cpp') (Join-Path $testRoot 'entry/src/main/cpp/protocol/jybsmr131/codec.cpp') (Join-Path $testRoot 'entry/src/main/cpp/protocol/jybsmr131/data.cpp')
  if ($LASTEXITCODE -ne 0) { throw '协议测试编译失败' }
  & ./jybsmr131-test.exe
  if ($LASTEXITCODE -ne 0) { throw '协议测试失败' }
} finally {
  Pop-Location
}
