const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { test } = require('node:test');
const ts = require(process.env.TCP_SERVER_TYPESCRIPT_PATH || 'typescript');

const source = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/entryability/EntryAbility.ets'), 'utf8');
const compiled = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }, reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);

function createAbility(serverMode = 'ok') {
  const calls = [];
  let clientRunning = false;
  const native = {
    startTcpClient: (host, port) => { calls.push(['client-start', host, port]); clientRunning = true; return true; },
    stopTcpClient: () => { calls.push(['client-stop']); clientRunning = false; },
    isTcpClientRunning: () => clientRunning,
    startTcpServer: port => {
      calls.push(['server-start', port]);
      if (serverMode === 'throw') throw new Error('监听失败');
      return serverMode === 'ok';
    },
    stopTcpServer: () => calls.push(['server-stop'])
  };
  if (serverMode === 'missing') delete native.startTcpServer;
  const context = { exports: {}, require: name => {
    if (name === '@kit.AbilityKit') return { UIAbility: class {} };
    if (name === '@kit.PerformanceAnalysisKit') return { hilog: { info() {}, error() {} } };
    if (name === '@kit.ArkUI') return { window: { getLastWindow: async () => ({
      setWindowLayoutFullScreen: async () => {}, setWindowSystemBarEnable: async () => {},
      setSpecificSystemBarEnabled: async () => {}
    }) } };
    assert.equal(name, 'libentry.so');
    return native;
  } };
  vm.runInNewContext(compiled.outputText, context);
  return { ability: new context.exports.default(), calls };
}

test('首页加载成功后启动本机 2404 服务，退出窗口和应用时停止服务', () => {
  const { ability, calls } = createAbility();
  ability.onWindowStageCreate({ loadContent: (page, callback) => {
    assert.equal(page, 'pages/Index'); callback({ code: 0 });
  } });
  assert.deepEqual(calls, [['client-start', '192.168.1.102', 2404], ['server-start', 2404]]);
  ability.onWindowStageDestroy();
  ability.onDestroy();
  assert.equal(calls.filter(call => call[0] === 'server-stop').length, 2);
  assert.equal(calls.filter(call => call[0] === 'client-stop').length, 1);
});

test('首页未加载或服务端接口失败时不破坏原有客户端流程', () => {
  const failedPage = createAbility();
  failedPage.ability.onWindowStageCreate({ loadContent: (_page, callback) => callback({ code: 1 }) });
  assert.equal(failedPage.calls.length, 0);
  for (const mode of ['false', 'throw', 'missing']) {
    const { ability, calls } = createAbility(mode);
    assert.doesNotThrow(() => ability.onWindowStageCreate({ loadContent: (_page, callback) => callback({ code: 0 }) }));
    assert.equal(calls[0][0], 'client-start');
    ability.onDestroy();
  }
});
