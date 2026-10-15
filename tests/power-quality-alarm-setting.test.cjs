const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require(process.env.POWER_QUALITY_TYPESCRIPT_PATH || 'typescript');

const file = path.join(__dirname, '../entry/src/main/ets/models/PowerQualityAlarmSetting.ets');
const source = fs.readFileSync(file, 'utf8').replace(/^import .*$/gm, '').replace(/^@Observed\s*$/gm, '');
const compiled = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 },
  reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);
const context = { exports: {} };
vm.runInNewContext(compiled.outputText, context);
const {
  createPowerQualityAlarmRows,
  validatePowerQualitySetting,
  buildPowerQualitySettingFields,
  packetMatchesFields,
  readPowerQualityAlarmSetting
} = context.exports;

function settingPacket(revision = 5, sessionId = 2) {
  const rows = createPowerQualityAlarmRows();
  rows.forEach((row, index) => { row.enabled = index % 2 === 1 ? '投入' : '退出'; row.value = String(index + 0.125); });
  return {
    ready: true, commonAddress: 0x1344, objectAddress: 0x33, payloadLength: 200, revision, sessionId,
    fields: buildPowerQualitySettingFields(1, '123', '456', rows)
  };
}

test('Qt 的 23 个告警项按结构体顺序生成', () => {
  const rows = createPowerQualityAlarmRows();
  assert.equal(rows.length, 23);
  assert.deepEqual(Array.from(rows, row => row.key), [
    'VoltageUnbalance', 'VoltageDeviation', 'FreqDeviation', 'VoltageShortFlicke',
    'VoltageLongFlicke', 'VoltageFluct', 'VoltageSeg', 'VoltageSwell', 'VoltageTHD',
    'VoltageOddTHD', 'VoltageEvenTHD', 'VoltageOddHAR', 'VoltageEvenHAR',
    'VoltageInterTHD', 'VoltageInterHAR', 'CurrentUnbalance', 'CurrentTHD',
    'CurrentOddTHD', 'CurrentEvenTHD', 'CurrentOddHAR', 'CurrentEvenHAR',
    'CurrentInterTHD', 'CurrentInterHAR'
  ]);
});

test('录波长度、频率和百分比采用 Qt 范围校验，闪变只限制非负', () => {
  const rows = createPowerQualityAlarmRows();
  assert.equal(validatePowerQualitySetting('0', '600', rows).length, 0);
  rows.find(row => row.key === 'FreqDeviation').value = '50.01';
  rows.find(row => row.key === 'VoltageTHD').value = '101';
  rows.find(row => row.key === 'VoltageLongFlicke').value = '500';
  const errors = validatePowerQualitySetting('-1', '601', rows);
  assert.equal(errors.length, 4);
  assert.ok(errors.some(error => error.includes('频率偏差')));
  assert.ok(errors.some(error => error.includes('电压总谐波')));
  rows[0].value = '';
  assert.ok(validatePowerQualitySetting('', '0', rows).some(error => error.includes('请输入有效数字')));
});

test('写入字段包含三个基础参数和 23 组投入、动作值', () => {
  const rows = createPowerQualityAlarmRows();
  rows[0].enabled = '投入';
  rows[0].value = '2.5';
  const fields = buildPowerQualitySettingFields(1, '128.9', '256', rows);
  assert.equal(fields.length, 49);
  assert.equal(fields[0].name, 'VoltageRef_SegSwell');
  assert.equal(fields[0].values[0], 1);
  assert.equal(fields[1].values[0], 128);
  assert.equal(fields.find(field => field.name === 'VoltageUnbalance.Enable').values[0], 1);
  assert.equal(fields.find(field => field.name === 'VoltageUnbalance.ActValue').values[0], 2.5);
  const packetFields = fields.map(field => ({ name: field.name, values: Array.from(field.values) }));
  const packet = { ready: true, fields: packetFields, revision: 2, sessionId: 0, commonAddress: 0x1344,
    objectAddress: 0x33, payloadLength: 200 };
  assert.equal(packetMatchesFields(packet, fields), true);
  packet.fields[4].values[0] = 9;
  assert.equal(packetMatchesFields(packet, fields), false);
});

test('设备确认必须是有效回包，不能把 NaN 或缺失字段当成写入成功', () => {
  const fields = buildPowerQualitySettingFields(0, '0', '0', createPowerQualityAlarmRows());
  const packet = { ready: true, fields: fields.map(field => ({
    name: field.name, values: Array.from(field.values)
  })) };
  packet.ready = false;
  assert.equal(packetMatchesFields(packet, fields), false);
  packet.ready = true;
  packet.fields[4].values[0] = NaN;
  assert.equal(packetMatchesFields(packet, fields), false);
  packet.fields[4].values[0] = Infinity;
  assert.equal(packetMatchesFields(packet, fields), false);
  packet.fields.splice(4, 1);
  assert.equal(packetMatchesFields(packet, fields), false);
});

test('按 Qt set_setting 为全部 49 个控件值赋值，录波两位、动作值六位有效数字', () => {
  const packet = settingPacket();
  const value = readPowerQualityAlarmSetting(packet);
  assert.ok(value);
  assert.equal(value.voltageReferenceIndex, 1);
  assert.equal(value.normalRecordLength, '123.00');
  assert.equal(value.violationRecordLength, '456.00');
  value.rows.forEach((row, index) => {
    assert.equal(row.enabled, index % 2 === 1 ? '投入' : '退出');
    assert.equal(row.value, String(index + 0.125));
  });
  packet.fields.find(field => field.name === 'VoltageUnbalance.ActValue').values[0] = 0.10000000149011612;
  assert.equal(readPowerQualityAlarmSetting(packet).rows[0].value, '0.1');
  packet.fields[0].values[0] = 3;
  assert.equal(readPowerQualityAlarmSetting(packet).voltageReferenceIndex, 1);
  packet.fields[0].values[0] = 0;
  packet.fields[1].values[0] = 0;
  assert.equal(readPowerQualityAlarmSetting(packet).voltageReferenceIndex, 0);
  assert.equal(readPowerQualityAlarmSetting(packet).normalRecordLength, '0.00');
});

test('任何控件字段缺失、非有限数或非法投退都拒绝整份赋值', () => {
  const packet = settingPacket();
  for (let index = 0; index < 49; index++) {
    const incomplete = { ...packet, fields: packet.fields.filter((_field, item) => item !== index) };
    assert.equal(readPowerQualityAlarmSetting(incomplete), undefined);
  }
  for (const invalid of [NaN, Infinity, -Infinity]) {
    const bad = settingPacket(); bad.fields[4].values[0] = invalid;
    assert.equal(readPowerQualityAlarmSetting(bad), undefined);
  }
  for (const overrides of [{ ready: false }, { commonAddress: 0x44 }, { objectAddress: 0x55 },
    { payloadLength: 100 }, { revision: 0 }, { sessionId: -1 }]) {
    assert.equal(readPowerQualityAlarmSetting({ ...packet, ...overrides }), undefined);
  }
  const badEnable = settingPacket(); badEnable.fields[3].values[0] = 2;
  assert.equal(readPowerQualityAlarmSetting(badEnable), undefined);
});

// 执行页面实际读取/赋值方法，并通过真实协议封装核对 NAPI 方法和地址。
const protocolSource = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/protocol/Jybsmr131.ets'), 'utf8');
let nativePacket;
let nativeReadThrows = false;
let nativeRequestThrows = false;
let sendResult = true;
const nativeCalls = [];
const native = { default: {
  getJybsmr131Packet: (common, object) => {
    nativeCalls.push(['read', common, object]);
    if (nativeReadThrows) throw new Error('native 读取失败');
    return nativePacket;
  },
  requestJybsmr131Packet: (common, object) => {
    nativeCalls.push(['request', common, object]);
    if (nativeRequestThrows) throw new Error('native 请求失败');
    return sendResult;
  }
} };
const protocolContext = { exports: {}, require: () => native };
vm.runInNewContext(ts.transpileModule(protocolSource, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }
}).outputText, protocolContext);
const timers = new Map();
let nextTimer = 0;
Object.assign(context, protocolContext.exports, {
  setInterval: (callback, interval) => { timers.set(++nextTimer, { callback, interval }); return nextTimer; },
  clearInterval: id => timers.delete(id)
});
const pageSource = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/pages/CommonSetting_PowerQuality_Set.ets'), 'utf8');
function pageMethod(name) {
  const match = pageSource.match(new RegExp('^  (?:private )?' + name + '\\([^]*?^  }', 'm'));
  assert.ok(match, name);
  return match[0].replace('private ', '');
}
const pageClass = `class AlarmPage {
  rows = createPowerQualityAlarmRows(); voltageReferenceIndex = 0; normalRecordLength = '0.00'; violationRecordLength = '0.00';
  statusText = ''; noticeText = ''; readingSetting = false; settingLoaded = false; active = false;
  clockTimer = -1; loadTimer = -1; confirmTimer = -1; readGeneration = 0; applyingSetting = false;
  baselineRevision = 0; baselineSessionId = 0; updateClock() {}
  ${['aboutToAppear', 'aboutToDisappear', 'stopTimer', 'requestSetting', 'finishReading', 'applyPacket', 'markChanged'].map(pageMethod).join('\n')}
}
exports.AlarmPage = AlarmPage;`;
vm.runInNewContext(ts.transpileModule(pageClass, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }
}).outputText, context);
const { AlarmPage } = context.exports;
function resetNative(packet) {
  nativePacket = packet; nativeReadThrows = false; nativeRequestThrows = false; sendResult = true;
  nativeCalls.length = 0; timers.clear();
}

test('进入页面立即读取 C++ 已缓存定值，无需新回包，不启动定值刷新', () => {
  resetNative(settingPacket());
  const page = new AlarmPage();
  const row = page.rows[0];
  page.aboutToAppear();
  assert.deepEqual(nativeCalls, [['read', 0x1344, 0x33]]);
  assert.equal(page.rows[0], row);
  assert.equal(page.rows[0].value, '0.125');
  assert.equal(page.rows[1].enabled, '投入');
  assert.equal(page.normalRecordLength, '123.00');
  assert.equal(page.settingLoaded, true);
  assert.equal(page.baselineRevision, 5);
  assert.equal(page.baselineSessionId, 2);
  assert.equal(page.noticeText, '');
  assert.equal(page.loadTimer, -1);
  assert.equal(timers.size, 1); // 仅保留原有日期时间时钟。
  page.rows[0].value = '9'; page.markChanged();
  nativePacket = settingPacket(6);
  [...timers.values()][0].callback();
  assert.equal(page.rows[0].value, '9');
  assert.equal(nativeCalls.length, 1);
  page.aboutToDisappear();
  assert.equal(timers.size, 0);
});

test('缓存为空仅发送一次查询，有效回包赋值后停止等待', () => {
  resetNative({ ...settingPacket(0), ready: false });
  const page = new AlarmPage(); page.aboutToAppear();
  assert.deepEqual(nativeCalls, [['read', 0x1344, 0x33], ['request', 0x1344, 0x33]]);
  assert.equal(page.readingSetting, true);
  const wait = timers.get(page.loadTimer).callback;
  wait();
  assert.equal(page.settingLoaded, false);
  nativePacket = settingPacket(1);
  wait();
  assert.equal(page.statusText, '已读取装置定值');
  assert.equal(page.rows[22].value, '22.125');
  assert.equal(page.loadTimer, -1);
  assert.equal(page.readingSetting, false);
  assert.equal(nativeCalls.filter(call => call[0] === 'request').length, 1);
  page.rows[0].value = '9';
  nativePacket = settingPacket(2);
  const readCount = nativeCalls.length;
  wait();
  assert.equal(nativeCalls.length, readCount);
  assert.equal(page.rows[0].value, '9');
  page.aboutToDisappear();
});

test('不完整回包不部分覆盖界面，等待超时停止，销毁后不再读取 native', () => {
  resetNative({ ...settingPacket(0), ready: false });
  const page = new AlarmPage(); page.aboutToAppear();
  const wait = timers.get(page.loadTimer).callback;
  nativePacket = settingPacket(1); nativePacket.fields.pop();
  for (let index = 0; index < 10; index++) wait();
  assert.equal(page.settingLoaded, false);
  assert.equal(page.normalRecordLength, '0.00');
  assert.equal(page.rows[0].value, '0');
  assert.equal(page.loadTimer, -1);
  assert.equal(page.readingSetting, false);
  assert.match(page.statusText, /未收到完整/);
  page.aboutToDisappear();
  const reads = nativeCalls.length;
  wait();
  assert.equal(nativeCalls.length, reads);
  assert.equal(timers.size, 0);
});

test('native 读取、请求异常不使页面崩溃，程序赋值不触发修改提示', () => {
  resetNative(settingPacket()); nativeReadThrows = true;
  const page = new AlarmPage();
  assert.doesNotThrow(() => page.aboutToAppear());
  assert.equal(page.settingLoaded, false);
  assert.match(page.statusText, /读取装置定值失败/);
  page.aboutToDisappear();
  resetNative({ ...settingPacket(0), ready: false }); nativeRequestThrows = true;
  const failed = new AlarmPage(); failed.aboutToAppear();
  assert.equal(failed.loadTimer, -1);
  assert.equal(failed.readingSetting, false);
  assert.match(failed.statusText, /读取装置定值失败/);
  failed.applyingSetting = true; failed.markChanged();
  assert.equal(failed.noticeText, '');
  failed.applyingSetting = false; failed.markChanged();
  assert.match(failed.noticeText, /定值已被改动/);
  failed.aboutToDisappear();
});
