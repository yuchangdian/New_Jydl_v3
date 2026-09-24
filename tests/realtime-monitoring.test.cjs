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
const context = { exports: {} };
vm.runInNewContext(compiled.outputText, context);
const { buildRealtimeRows, formatRealtimeValue, parseRealtimeData, hasRealtimeData } = context.exports;
const rowById = (rows, id) => rows.find(row => row.id === id);
const values = row => Array.from(row.cells, cell => cell.value);

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

test('支持带 data 及直接字段响应，失败和错误结构不会覆盖有效数据', () => {
  const wrapped = parseRealtimeData('{"code":200,"success":true,"data":{"Ua_Frequency":[50]}}');
  assert.equal(wrapped.Ua_Frequency[0], 50);
  const direct = parseRealtimeData('{"Ua_Frequency":50}');
  assert.equal(direct.Ua_Frequency, 50);
  for (const input of ['null', '[]', '"text"', '{"data":null}', '{"data":[]}', '{"data":5}',
    '{"code":500,"data":{"Ua_Frequency":50}}', '{"success":false,"data":{"Ua_Frequency":50}}', 'bad json']) {
    assert.throws(() => parseRealtimeData(input));
  }
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
