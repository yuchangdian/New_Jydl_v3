const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require(process.env.JYBSMR131_TYPESCRIPT_PATH || 'typescript');

const indexSource = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/pages/Index.ets'), 'utf8');
const helpers = indexSource.slice(0, indexSource.indexOf('// @Entry')).replace(/^import .*$/gm, '');
const compiled = ts.transpileModule(helpers, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }, reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);
const context = {};
vm.runInNewContext(compiled.outputText, context);
function sample(protocolVersion) {
  const data = { ready: true, protocolVersion };
  for (const phase of ['Ua', 'Ub', 'Uc', 'Uo', 'IA', 'IB', 'IC', 'Io', 'Ux', 'Ia', 'Ib', 'Ic']) {
    data[phase + '_Rms'] = 100;
    data[phase + '_Phase'] = 0;
  }
  return data;
}
test('新版缺少旧版独立通道时，已有通道仍可显示', () => {
  const data = sample('jybsmr131');
  for (const phase of ['Ux', 'Ia', 'Ib', 'Ic']) data[phase + '_Rms'] = data[phase + '_Phase'] = NaN;
  assert.equal(context.isUsableBaseFreqDisplayValue(data), true);
  assert.equal(context.formatBaseFreqPhasorText(data.Ua_Rms, data.Ua_Phase, 'V'), '100.00V∠0.00°');
  assert.equal(context.formatBaseFreqPhasorText(data.Ux_Rms, data.Ux_Phase, 'V'), '--V∠--°');
});
test('旧协议仍按完整通道校验，新旧协议都拒绝未就绪或核心通道异常', () => {
  assert.equal(context.isUsableBaseFreqDisplayValue(sample()), true);
  const old = sample(); old.Ux_Rms = NaN;
  assert.equal(context.isUsableBaseFreqDisplayValue(old), false);
  const latest = sample('jybsmr131'); latest.Ua_Rms = NaN;
  assert.equal(context.isUsableBaseFreqDisplayValue(latest), false);
  latest.Ua_Rms = 230; latest.ready = false;
  assert.equal(context.isUsableBaseFreqDisplayValue(latest), false);
});

const calls = [];
const native = {
  getJybsmr131DigitalInputs: () => ({ ready: true, complete: false, validMask: 1, BreakerState_Now: 0, GLKGW: 0 }),
  requestJybsmr131Packet: (...args) => { calls.push(args); return true; },
  getJybsmr131Packet: (commonAddress, objectAddress) => ({ ready: false, commonAddress, objectAddress, payloadLength: 0, fields: [] }),
  updateJybsmr131Setting: (...args) => { calls.push(args); return false; }
};
const protocolSource = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/protocol/Jybsmr131.ets'), 'utf8');
const protocol = ts.transpileModule(protocolSource, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021, esModuleInterop: true }, reportDiagnostics: true
});
assert.equal(protocol.diagnostics.length, 0);
const protocolContext = { exports: {}, require: name => { assert.equal(name, 'libentry.so'); return native; } };
vm.runInNewContext(protocol.outputText, protocolContext);
const { Jybsmr131Protocol: api, Jybsmr131TelemetryAddress: telemetry, Jybsmr131SettingAddress: setting } = protocolContext.exports;
test('ArkTS 封装使用新版公共地址，写入结果保持 native 语义', () => {
  assert.equal(api.requestTelemetry(telemetry.BaseValue), true);
  assert.deepEqual(calls.pop(), [0x1311, 0x11]);
  assert.equal(api.requestSetting(setting.System), true);
  assert.deepEqual(calls.pop(), [0x1344, 0x11]);
  assert.equal(api.telemetry(telemetry.BaseValue).ready, false);
  assert.equal(api.updateSetting(setting.System, [{ name: 'PTp_Primary', values: [100] }]), false);
  assert.equal(calls.pop()[0], 0x11);
});
test('缺失字段返回 undefined，数组读取不改变快照', () => {
  const packet = { ready: true, fields: [{ name: 'Ua_RMS', values: [230] }, { name: 'Value', values: [-1, 2] }] };
  assert.equal(api.value(packet, 'Ua_RMS'), 230);
  assert.equal(api.value(packet, 'RatedCurrent_Primary'), undefined);
  assert.equal(api.value(packet, 'Value'), undefined);
  const values = api.values(packet, 'Value'); values[0] = 999;
  assert.equal(packet.fields[1].values[0], -1);
  packet.ready = false;
  assert.equal(api.value(packet, 'Ua_RMS'), undefined);
});

test('整组遥信使用 0x1333，11 路开入区分未收到与真实零值', () => {
  assert.equal(api.requestAllSignals(), true);
  assert.deepEqual(calls.pop(), [0x1333, 0x11]);
  const packet = api.signal(protocolContext.exports.Jybsmr131SignalAddress.All);
  assert.equal(packet.commonAddress, 0x1333);
  assert.equal(packet.objectAddress, 0x11);
  const state = api.digitalInputs();
  assert.equal(state.GLKGW, 0);
  assert.equal(state.JDKGW, undefined);
  assert.equal(state.ready, true);
  assert.equal(state.complete, false);
  assert.equal(state.SwitchState, undefined);
  assert.equal(state.BreakerState_Now, protocolContext.exports.Jybsmr131SwitchState.Uncertain);
});
