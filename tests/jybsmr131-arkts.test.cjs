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
  assert.equal(context.formatBaseFreqPhasorText(data.Ua_Rms, data.Ua_Phase, 'V'), '100.000V∠0.000°');
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

test('首页格式遵循 Qt 的 RMS 分段精度、角度范围和三位频率/百分比', () => {
  for (const [value, expected] of [[0, '00.00'], [0.0009, '00.00'], [0.001, '0.001'],
    [0.125, '0.125'], [1, '1.0000'], [9.25, '9.2500'], [10, '10.000'],
    [9999, '9999.000'], [10000, '00.00']]) {
    assert.equal(context.formatRMS(value), expected);
  }
  assert.equal(context.formatAngle(-360), '-360.000');
  assert.equal(context.formatAngle(360), '360.000');
  assert.equal(context.formatAngle(360.01), '00.00');
  assert.equal(context.formatAngle(-360.01), '00.00');
  assert.equal(context.frequencyText(50.1234), '50.123Hz');
  assert.equal(context.frequencyText(undefined), '--Hz');
  assert.equal(context.percentText(0), '0.000%');
  assert.equal(context.percentText(2.1234), '2.123%');
  assert.equal(context.percentText(Infinity), '--%');
});

// 执行页面本身的方法，检查 native 快照到状态的真实映射和页面生命周期。
function homeMethod(name) {
  const match = indexSource.match(new RegExp('^  (?:private )?' + name + '\\([^]*?^  }', 'm'));
  assert.ok(match, name);
  return match[0].replace('private ', '');
}
const homeCompiled = ts.transpileModule('class Home {\n' + [
  'aboutToAppear', 'aboutToDisappear', 'startBaseFreqRefreshTimer', 'stopBaseFreqRefreshTimer',
  'resetBaseFreqDisplay', 'refreshBaseFreqDisplay', 'update_baseFreq_data',
  'refreshPowerQualityDisplay', 'updateVoltageMonitoringPage'
].map(homeMethod).join('\n') + '\n}\nglobalThis.createHome = () => new Home();', {
  compilerOptions: { target: ts.ScriptTarget.ES2021 }, reportDiagnostics: true
});
assert.equal(homeCompiled.diagnostics.length, 0);
let scheduledRefresh;
const clearedTimers = [];
context.setInterval = (callback, delay) => { assert.equal(delay, 500); scheduledRefresh = callback; return 12; };
context.clearInterval = timer => clearedTimers.push(timer);
context.console = { error() {} };
vm.runInNewContext(homeCompiled.outputText, context);
const qualityMapping = {
  voltage_unbalance_0: 'Voltage_Uo_Unbalance', voltage_unbalance_2: 'Voltage_U2_Unbalance',
  THD_Ua: 'VoltageTHD_A', THD_Ub: 'VoltageTHD_B', THD_Uc: 'VoltageTHD_C',
  current_unbalance_0: 'Current_In_Unbalance', current_unbalance_2: 'Current_I2_Unbalance',
  THD_Ia: 'CurrentTHD_A', THD_Ib: 'CurrentTHD_B', THD_Ic: 'CurrentTHD_C'
};
function qualitySample() {
  const data = { ready: true };
  Object.values(qualityMapping).forEach((name, index) => data[name] = index + 0.125);
  return data;
}
test('首页按 Qt 分别刷新三相频率、保护电流和十项电能质量，不混用字段', () => {
  const home = context.createHome();
  const base = { ...sample('jybsmr131'), Ua_Frequency: 49.125, Ub_Frequency: 50.25, Uc_Frequency: 51.5,
    IA_Rms: 5.25, IA_Phase: -120 };
  home.update_baseFreq_data(base);
  assert.equal(home.frequency, '49.125Hz');
  assert.equal(home.frequencyB, '50.250Hz');
  assert.equal(home.frequencyC, '51.500Hz');
  assert.equal(home.ia, '5.2500A∠-120.000°');
  const quality = qualitySample();
  home.updateVoltageMonitoringPage(quality);
  for (const [state, field] of Object.entries(qualityMapping)) {
    assert.equal(home[state], quality[field].toFixed(3) + '%');
  }
  quality.VoltageTHD_B = NaN;
  home.updateVoltageMonitoringPage(quality);
  assert.equal(home.THD_Ub, '--%');
  assert.equal(home.THD_Ua, '2.125%');
});
test('基波和电能质量独立就绪，断连/接口异常清除旧显示，离开页面清理定时器', () => {
  const home = context.createHome();
  const base = { ...sample('jybsmr131'), Ua_Frequency: 50 };
  const quality = qualitySample();
  const nativeModule = { getBaseFreqDisplayData: () => base, getPowerQualityDisplayData: () => quality };
  home.baseFreqRefreshTimer = -1;
  home.loadBaseFreqNativeModule = () => nativeModule;
  home.aboutToAppear();
  assert.equal(home.frequency, '50.000Hz');
  assert.equal(home.THD_Ic, '9.125%');
  base.ready = false;
  scheduledRefresh();
  assert.equal(home.frequency, '--Hz');
  assert.equal(home.THD_Ic, '9.125%');
  base.ready = true;
  quality.ready = false;
  scheduledRefresh();
  assert.equal(home.frequency, '50.000Hz');
  for (const state of Object.keys(qualityMapping)) assert.equal(home[state], '--%');
  nativeModule.getPowerQualityDisplayData = () => { throw new Error('读取失败'); };
  scheduledRefresh();
  assert.equal(home.frequency, '50.000Hz');
  assert.equal(home.THD_Ic, '--%');
  nativeModule.getPowerQualityDisplayData = undefined;
  scheduledRefresh();
  assert.equal(home.THD_Ic, '--%');
  home.aboutToDisappear();
  assert.equal(home.baseFreqRefreshTimer, -1);
  assert.equal(clearedTimers.pop(), 12);
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
