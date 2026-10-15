param([string]$CompilerDirectory = 'C:/Program Files/CodeBlocks/MinGW/bin')
$ErrorActionPreference = 'Stop'
$testRoot = Split-Path -Parent $PSScriptRoot
$testOutput = Join-Path $testRoot 'tests/.build/tcp-server'
New-Item -ItemType Directory -Path $testOutput -Force | Out-Null
Push-Location $testOutput
try {
  & (Join-Path $CompilerDirectory 'gcc.exe') -std=c11 -Wall -Wextra -Werror -c (Join-Path $testRoot 'tests/tcp-server-c-api.test.c') -o c-api.o
  if ($LASTEXITCODE -ne 0) { throw 'TCP 服务端 C 接口测试编译失败' }
  & (Join-Path $CompilerDirectory 'g++.exe') -std=c++17 -Wall -Wextra -Werror -D_WIN32_WINNT=0x0600 -DTCP_SERVER_TESTING -static -pthread -o tcp-server-test.exe (Join-Path $testRoot 'tests/tcp-server.test.cpp') (Join-Path $testRoot 'entry/src/main/cpp/tcp_server.cpp') c-api.o -lws2_32
  if ($LASTEXITCODE -ne 0) { throw 'TCP 服务端测试编译失败' }
  & ./tcp-server-test.exe
  if ($LASTEXITCODE -ne 0) { throw 'TCP 服务端回环测试失败' }
} finally {
  Pop-Location
}
