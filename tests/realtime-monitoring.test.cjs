const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const ts = require(process.env.REALTIME_TYPESCRIPT_PATH || 'typescript');
const source = fs.readFileSync(path.join(__dirname,
  '../entry/src/main/ets/pages/quality/PowerQualityRealtimeMonitoringPage.ets'), 'utf8');
// 数据函数位于组件声明前；运行实际函数，ArkUI 部分由 Hvigor 编译验证。
const compiled = ts.transpileModule(source.slice(0, source.indexOf('@Component')), {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 },
  reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);
const protocolSource = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/protocol/Jybsmr131.ets'), 'utf8');
const protocolContext = { exports: {}, require: () => ({}) };
vm.runInNewContext(ts.transpileModule(protocolSource, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }
}).outputText, protocolContext);
const protocol = protocolContext.exports;
const timers = new Map();
let timerCount = 0;
let now = 1000;
const context = { exports: {}, require: name => {
  assert.equal(name, '../../protocol/Jybsmr131');
  return protocol;
}, Date: { now: () => now },
setInterval: (callback, interval) => { timers.set(++timerCount, { callback, interval }); return timerCount; },
clearInterval: id => timers.delete(id) };
vm.runInNewContext(compiled.outputText, context);
const { buildRealtimeRows, formatRealtimeValue, hasRealtimeData, RealtimeMonitoringBuffer } = context.exports;
const rowById = (rows, id) => rows.find(row => row.id === id);
const values = row => Array.from(row.cells, cell => cell.value);

function packet(isBase, data = {}, revision = 1, sessionId = 1) {
  return {
    ready: true, revision, sessionId, commonAddress: 0x1311, objectAddress: isBase ? 0x11 : 0x55,
    payloadLength: isBase ? 151 : 435,
    fields: Object.entries(data).map(([name, value]) => ({
      name: (isBase ? '' : 'PowerQuality.') + name, values: Array.isArray(value) ? value : [value]
    }))
  };
}

test('Qt 的 14 行保持顺序，续行标题和不平衡度第三格留空', () => {
  const rows = buildRealtimeRows({}, {});
  assert.deepEqual(Array.from(rows, row => row.id), [
    'Frequency', 'FrequencyDeviation', 'FrequencyRate', 'Voltage', 'VoltageDeviation',
    'LineVoltageDeviation', 'VoltageRate', 'VoltageUnbalance', 'VoltageUnbalanceRate',
    'VoltageShortFlicke', 'VoltageLongFlicke', 'Current', 'CurrentUnbalance', 'CurrentUnbalanceRate'
  ]);
  for (const id of ['LineVoltageDeviation', 'VoltageUnbalanceRate', 'CurrentUnbalanceRate']) {
    assert.equal(rowById(rows, id).title, '');
  }
  for (const id of ['VoltageUnbalanceRate', 'CurrentUnbalanceRate']) {
    assert.deepEqual({ ...rowById(rows, id).cells[2] }, { prefix: '', value: '' });
  }
  assert.equal(rowById(rows, 'Frequency').cells[0].value, '--');
});

test('三相频率读取线路 1，使用四位小数', () => {
  const rows = buildRealtimeRows({ Ua_Frequency: [49.98765, 88], Ub_Frequency: [50], Uc_Frequency: 50.12345 }, {});
  assert.deepEqual(values(rowById(rows, 'Frequency')), ['49.9877Hz', '50.0000Hz', '50.1234Hz']);
});

test('三相电压电流有效值四位、相角三位；保护电流不混用测量电流', () => {
  const rows = buildRealtimeRows({
    Ua_RMS: [220.5], Ub_RMS: [221], Uc_RMS: [219], Ua_Phase: [0], Ub_Phase: [-120], Uc_Phase: [120],
    IA_RMS: [10.25], IB_RMS: [11], IC_RMS: [12], IA_Phase: [-30], IB_Phase: [-150], IC_Phase: [90],
    Ia_RMS: [999], Ib_RMS: [999], Ic_RMS: [999], Ia_Phase: [999]
  }, {});
  assert.deepEqual(values(rowById(rows, 'Voltage')), ['220.5000 V∠0.000°', '221.0000 V∠-120.000°', '219.0000 V∠120.000°']);
  assert.deepEqual(values(rowById(rows, 'Current')), ['10.2500 A∠-30.000°', '11.0000 A∠-150.000°', '12.0000 A∠90.000°']);
  const missing = buildRealtimeRows({ Ia_RMS: [999], Ua_RMS: [220] }, {});
  assert.equal(rowById(missing, 'Current').cells[0].value, '--');
  assert.equal(rowById(missing, 'Voltage').cells[0].value, '220.0000 V∠--°');
});

test('偏差、分相合格率及长短闪变逐相对应，线电压顺序为 AB/BC/CA', () => {
  const data = {
    FreqDeviation_A: [0.01], FreqDeviation_B: [-0.02], FreqDeviation_C: [0.03],
    FreqQualifiRate_A: [97], FreqQualifiRate_B: [98], FreqQualifiRate_C: [99],
    VoltageDeviation_A: [1], VoltageDeviation_B: [2], VoltageDeviation_C: [3],
    VoltageDeviation_AB: [4], VoltageDeviation_BC: [5], VoltageDeviation_CA: [6],
    VoltageQualifiRate_A: [90], VoltageQualifiRate_B: [91], VoltageQualifiRate_C: [92],
    VoltageShortFlicke_A: [0.1], VoltageShortFlicke_B: [0.2], VoltageShortFlicke_C: [0.3],
    VoltageLongFlicke_A: [0.4], VoltageLongFlicke_B: [0.5], VoltageLongFlicke_C: [0.6]
  };
  const rows = buildRealtimeRows({}, data);
  assert.deepEqual(values(rowById(rows, 'FrequencyDeviation')), ['0.0100Hz', '-0.0200Hz', '0.0300Hz']);
  assert.deepEqual(values(rowById(rows, 'FrequencyRate')), ['97.0000%', '98.0000%', '99.0000%']);
  assert.deepEqual(values(rowById(rows, 'VoltageDeviation')), ['1.0000%', '2.0000%', '3.0000%']);
  assert.deepEqual(values(rowById(rows, 'LineVoltageDeviation')), ['4.0000%', '5.0000%', '6.0000%']);
  assert.deepEqual(Array.from(rowById(rows, 'LineVoltageDeviation').cells, cell => cell.prefix), ['ΔUab:', 'ΔUbc:', 'ΔUca:']);
  assert.deepEqual(values(rowById(rows, 'VoltageRate')), ['90.0000%', '91.0000%', '92.0000%']);
  assert.deepEqual(values(rowById(rows, 'VoltageShortFlicke')), ['0.1000', '0.2000', '0.3000']);
  assert.deepEqual(values(rowById(rows, 'VoltageLongFlicke')), ['0.4000', '0.5000', '0.6000']);
});

test('序分量、不平衡度和 Qt/现有接口零序字段对应，合法零值优先', () => {
  const rows = buildRealtimeRows({}, {
    Voltage_U1: [220], Voltage_U2: [2], Voltage_Uo: [0], Voltage_U0: [99],
    Voltage_U2_Unbalance: [1], Voltage_Uo_Unbalance: [2],
    Current_I1: [10], Current_I2: [0.1], Current_Io: [0], Current_I0: [99],
    Current_I2_Unbalance: [3], Current_In_Unbalance: [0], Current_Io_Unbalance: [99]
  });
  assert.deepEqual(values(rowById(rows, 'VoltageUnbalance')), ['220.0000V', '2.0000V', '0.0000V']);
  assert.deepEqual(values(rowById(rows, 'VoltageUnbalanceRate')), ['1.0000%', '2.0000%', '']);
  assert.deepEqual(values(rowById(rows, 'CurrentUnbalance')), ['10.0000A', '0.1000A', '0.0000A']);
  assert.deepEqual(values(rowById(rows, 'CurrentUnbalanceRate')), ['3.0000%', '0.0000%', '']);
  const aliases = buildRealtimeRows({}, { Voltage_U0: [1], Current_I0: [2], Current_Io_Unbalance: [3] });
  assert.equal(rowById(aliases, 'VoltageUnbalance').cells[2].value, '1.0000V');
  assert.equal(rowById(aliases, 'CurrentUnbalance').cells[2].value, '2.0000A');
  assert.equal(rowById(aliases, 'CurrentUnbalanceRate').cells[1].value, '3.0000%');
});

test('总合格率不能冒充三相合格率', () => {
  const rows = buildRealtimeRows({}, { FreqQualified_Rate: [99], VoltageQualified_Rate: [98] });
  assert.deepEqual(values(rowById(rows, 'FrequencyRate')), ['--', '--', '--']);
  assert.deepEqual(values(rowById(rows, 'VoltageRate')), ['--', '--', '--']);
});

test('缺失和非法数字显示 --，合法零值保留，小数负零归零', () => {
  for (const input of [undefined, null, [], [null], [NaN], [Infinity], ['50'], [[50]], '50', {}]) {
    assert.equal(formatRealtimeValue(input, 4, 'Hz'), '--');
  }
  assert.equal(formatRealtimeValue(0, 4, '%'), '0.0000%');
  assert.equal(formatRealtimeValue(-0.000001, 4), '0.0000');
});

test('两类指标各自校验有效字段，合法零值不能丢失', () => {
  assert.equal(hasRealtimeData({}, true), false);
  assert.equal(hasRealtimeData({ Ua_Frequency: [0] }, true), true);
  assert.equal(hasRealtimeData({ Ua_Frequency: [50] }, false), false);
  assert.equal(hasRealtimeData({ FreqDeviation_A: [0] }, false), true);
});

test('两组数据刷新互不混用，单组后续响应能更新已有行', () => {
  const base = { Ua_Frequency: [50] };
  const quality = { FreqDeviation_A: [0.01] };
  const first = buildRealtimeRows(base, quality);
  base.Ua_Frequency[0] = 49.8;
  const second = buildRealtimeRows(base, quality);
  assert.equal(rowById(first, 'Frequency').cells[0].value, '50.0000Hz');
  assert.equal(rowById(second, 'Frequency').cells[0].value, '49.8000Hz');
  assert.equal(rowById(second, 'FrequencyDeviation').cells[0].value, '0.0100Hz');
});

test('真实快照字段分组独立刷新，重复缓存不重建行也不延长有效期', () => {
  const buffer = new RealtimeMonitoringBuffer();
  const base = packet(true, { Ua_Frequency: 50, Ua_RMS: 230, Ua_Phase: -120, IA_RMS: 5, IA_Phase: 30 });
  const quality = packet(false, { FreqDeviation_A: 0, Voltage_Uo: 0, Current_In_Unbalance: 0.75 });
  buffer.accept(base, true, 1000);
  assert.match(buffer.status(1000, false), /等待电能质量/);
  buffer.accept(quality, false, 2000);
  assert.equal(buffer.status(2000, false), '');
  assert.equal(rowById(buffer.rows, 'Frequency').cells[0].value, '50.0000Hz');
  assert.equal(rowById(buffer.rows, 'Current').cells[0].value, '5.0000 A∠30.000°');
  assert.equal(rowById(buffer.rows, 'CurrentUnbalanceRate').cells[1].value, '0.7500%');
  const rows = buffer.rows;
  assert.equal(buffer.accept(base, true, 10500), false);
  assert.equal(buffer.accept(quality, false, 10500), false);
  assert.equal(buffer.rows, rows);
  buffer.accept(packet(false, { FreqDeviation_A: 0.1 }, 2), false, 11000);
  assert.match(buffer.status(11000, false), /^基波数据超过 10 秒/);
  assert.equal(rowById(buffer.rows, 'Frequency').cells[0].value, '50.0000Hz');
  assert.equal(rowById(buffer.rows, 'FrequencyDeviation').cells[0].value, '0.1000Hz');
});

test('Qt 电能质量快照全部 31 个页面字段按 PowerQuality 前缀映射', () => {
  const names = ['FreqDeviation_A', 'FreqDeviation_B', 'FreqDeviation_C',
    'FreqQualifiRate_A', 'FreqQualifiRate_B', 'FreqQualifiRate_C',
    'VoltageDeviation_A', 'VoltageDeviation_B', 'VoltageDeviation_C',
    'VoltageDeviation_AB', 'VoltageDeviation_BC', 'VoltageDeviation_CA',
    'VoltageQualifiRate_A', 'VoltageQualifiRate_B', 'VoltageQualifiRate_C',
    'Voltage_U1', 'Voltage_U2', 'Voltage_Uo', 'Voltage_U2_Unbalance', 'Voltage_Uo_Unbalance',
    'VoltageShortFlicke_A', 'VoltageShortFlicke_B', 'VoltageShortFlicke_C',
    'VoltageLongFlicke_A', 'VoltageLongFlicke_B', 'VoltageLongFlicke_C',
    'Current_I1', 'Current_I2', 'Current_Io', 'Current_I2_Unbalance', 'Current_In_Unbalance'];
  const data = Object.fromEntries(names.map((name, index) => [name, index + 0.125]));
  const buffer = new RealtimeMonitoringBuffer();
  buffer.accept(packet(false, data), false, 1000);
  assert.equal(JSON.stringify(buffer.rows), JSON.stringify(buildRealtimeRows({}, data)));
});

test('错误地址、空数据、非有限数和旧版本不会覆盖有效显示', () => {
  const buffer = new RealtimeMonitoringBuffer();
  buffer.accept(packet(true, { Ua_Frequency: 50 }, 5), true, 1000);
  const rows = buffer.rows;
  const wrong = packet(true, { Ua_Frequency: 99 }, 6);
  wrong.commonAddress = 0x11;
  assert.equal(buffer.accept(wrong, true, 2000), false);
  wrong.commonAddress = 0x1311; wrong.objectAddress = 0x55;
  assert.equal(buffer.accept(wrong, true, 2000), false);
  for (const data of [{}, { Ua_Frequency: NaN }, { Ua_Frequency: Infinity }, { Ua_Frequency: [1, 2] }]) {
    assert.equal(buffer.accept(packet(true, data, 6), true, 2000), false);
  }
  assert.equal(buffer.accept(packet(true, { Ua_Frequency: 99 }, 4), true, 2000), false);
  assert.equal(buffer.rows, rows);
  assert.equal(buffer.isFresh(true, 11000, 10000), false);
  assert.equal(buffer.accept(packet(true, { Ua_Frequency: 0 }, 6), true, 11000), true);
  assert.equal(rowById(buffer.rows, 'Frequency').cells[0].value, '0.0000Hz');
});

test('重连立即清空上一会话，两组读取横跨重连时不会拼接新旧连接数据', () => {
  const buffer = new RealtimeMonitoringBuffer();
  buffer.accept(packet(true, { Ua_Frequency: 50 }, 100, 1), true, 1000);
  buffer.accept(packet(false, { Voltage_U1: 230 }, 101, 1), false, 1000);
  const reset = packet(true, {}, 0, 2); reset.ready = false;
  assert.equal(buffer.accept(reset, true, 2000), true);
  assert.equal(rowById(buffer.rows, 'Frequency').cells[0].value, '--');
  assert.equal(rowById(buffer.rows, 'VoltageUnbalance').cells[0].value, '--');
  buffer.accept(packet(true, { Ua_Frequency: 49 }, 102, 2), true, 2000);
  assert.equal(buffer.accept(packet(false, { Voltage_U1: 230 }, 101, 1), false, 2000), false);
  assert.equal(rowById(buffer.rows, 'Frequency').cells[0].value, '49.0000Hz');
  assert.match(buffer.status(2000, false), /等待电能质量/);
  buffer.accept(packet(false, { Voltage_U1: 220 }, 103, 2), false, 2200);
  assert.equal(buffer.status(2200, false), '');
});

function componentMethod(name) {
  const match = source.match(new RegExp('^  (?:private )?' + name + '\\([^]*?^  }', 'm'));
  assert.ok(match, name);
  return match[0].replace('private ', '');
}
Object.assign(context, protocol, { hilog: { error() {} } });
const controllerSource = `class RealtimeController {
  buffer = new RealtimeMonitoringBuffer(); rows = this.buffer.rows; statusText = '';
  pageActive = true; active = false; timerId = -1; nextRequestAt = 0; requestFailed = false;
  ${['aboutToAppear', 'aboutToDisappear', 'onPageActiveChanged', 'startPolling', 'stopPolling',
    'readPacket', 'requestPacket', 'pollData'].map(componentMethod).join('\n')}
}
exports.RealtimeController = RealtimeController;`;
vm.runInNewContext(ts.transpileModule(controllerSource, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }
}).outputText, context);
const { RealtimeController } = context.exports;

test('实际组件每 200 毫秒读取新快照，仅对缺失组补发查询，每 2 秒重试', () => {
  now = 1000; timers.clear();
  const calls = [];
  let quality = packet(false); quality.ready = false;
  let base = packet(true, { Ua_Frequency: 50 });
  protocol.Jybsmr131Protocol.telemetry = address => address === 0x11 ? base : quality;
  protocol.Jybsmr131Protocol.requestTelemetry = address => { calls.push(address); return false; };
  const page = new RealtimeController();
  page.aboutToAppear(); page.aboutToAppear();
  assert.equal(timers.size, 1);
  assert.equal([...timers.values()][0].interval, 200);
  assert.deepEqual(calls, [0x55]);
  assert.match(page.statusText, /请求未发送成功/);
  now = 1200; page.pollData();
  assert.deepEqual(calls, [0x55]);
  quality = packet(false, { FreqDeviation_A: 0 }, 2);
  page.pollData();
  assert.equal(page.statusText, '');
  assert.equal(rowById(page.rows, 'FrequencyDeviation').cells[0].value, '0.0000Hz');
  now = 3000;
  base = packet(true, { Ua_Frequency: 49.9 }, 3);
  page.pollData();
  assert.deepEqual(calls, [0x55]);
  now = 5000; page.pollData();
  assert.deepEqual(calls, [0x55, 0x11, 0x55]);
  page.aboutToDisappear();
  assert.equal(timers.size, 0);
});

test('实际组件隐藏和销毁时停止轮询，单组读取异常不阻塞另一组，重新显示可恢复', () => {
  now = 1000; timers.clear();
  let reads = 0;
  protocol.Jybsmr131Protocol.telemetry = address => {
    reads++;
    if (address === 0x55) throw new Error('质量读取失败');
    return packet(true, { Ua_Frequency: 50 });
  };
  protocol.Jybsmr131Protocol.requestTelemetry = () => { throw new Error('连接失败'); };
  const page = new RealtimeController();
  page.aboutToAppear();
  assert.equal(rowById(page.rows, 'Frequency').cells[0].value, '50.0000Hz');
  const callback = [...timers.values()][0].callback;
  page.pageActive = false; page.onPageActiveChanged();
  assert.equal(timers.size, 0);
  const stoppedReads = reads;
  callback();
  assert.equal(reads, stoppedReads);
  now = 11000;
  page.pageActive = true; page.onPageActiveChanged();
  assert.equal(timers.size, 1);
  assert.match(page.statusText, /基波数据超过 10 秒/);
  page.aboutToDisappear(); page.aboutToDisappear();
  assert.equal(timers.size, 0);
});
