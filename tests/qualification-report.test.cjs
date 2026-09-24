const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const ts = require(process.env.REPORT_TYPESCRIPT_PATH || 'typescript');
const source = fs.readFileSync(path.join(__dirname,
  '../entry/src/main/ets/pages/quality/PowerQualityReportPage.ets'), 'utf8');
const compiled = ts.transpileModule(source.slice(0, source.indexOf('@Component')), {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 },
  reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);
const context = { exports: {} };
vm.runInNewContext(compiled.outputText, context);
const { buildDailyQualificationRows, parseQualificationReport, qualificationRateText } = context.exports;
const filled = rows => rows.filter(row => row.date !== '--');

test('选择最近九个有记录的自然日，跳过日期空档，按日期正序显示', () => {
  const records = [1, 2, 3, 6, 9, 11, 12, 15, 18, 21, 24, 28].map(day => ({
    DataDate: '2026-04-' + String(day).padStart(2, '0'), VoltageQualifiedRate: day
  }));
  const rows = buildDailyQualificationRows(records.reverse());
  assert.equal(rows.length, 9);
  assert.deepEqual(Array.from(rows, row => row.date), [
    '2026/04/06', '2026/04/09', '2026/04/11', '2026/04/12', '2026/04/15',
    '2026/04/18', '2026/04/21', '2026/04/24', '2026/04/28'
  ]);
});

test('Qt 原始记录同日按 CreatedAtMs 和 Id 取最后一条，不能求平均', () => {
  const morning = new Date(2026, 3, 1, 8).getTime();
  const evening = new Date(2026, 3, 1, 20).getTime();
  const records = [
    { CreatedAtMs: evening, Id: 2, PowerQuality: { VoltageQualifiRate_All: 98, FreqQualifiRate_All: 97.125 } },
    { CreatedAtMs: morning, Id: 9, PowerQuality: { VoltageQualifiRate_All: 10, FreqQualifiRate_All: 20 } },
    { CreatedAtMs: evening, Id: 1, PowerQuality: { VoltageQualifiRate_All: 50, FreqQualifiRate_All: 60 } }
  ];
  const rows = buildDailyQualificationRows(records);
  assert.equal(filled(rows).length, 1);
  assert.equal(rows[0].date, '2026/04/01');
  assert.equal(rows[0].voltage, '98.00 %');
  assert.equal(rows[0].frequency, '97.125 %');
});

test('最新记录缺失数值时显示 --，不使用旧记录的正常值冒充最新值', () => {
  const rows = buildDailyQualificationRows([
    { DataDate: '2026-04-01', CreateTime: '2026-04-01 08:00:00', VoltageQualifiedRate: 99, FrequencyQualifiedRate: 99 },
    { DataDate: '2026-04-01', CreateTime: '2026-04-01 23:59:59', VoltageQualifiedRate: NaN }
  ]);
  assert.equal(rows[0].voltage, '--');
  assert.equal(rows[0].frequency, '--');
});

test('现有日报按 DataDate 分日，以 CreateTime/Id 解决重复，次日入库不改变统计日期', () => {
  const rows = buildDailyQualificationRows([
    { DataDate: '2026/04/01', CreateTime: '2026-04-02 01:00:00', Id: 3, VoltageQualifiedRate: 80 },
    { DataDate: '2026-04-01', CreateTime: '2026-04-02 01:00:00', Id: 4, VoltageQualifiedRate: 90 },
    { DataDate: '2026-04-01', CreateTime: '2026-04-01 23:00:00', Id: 5, VoltageQualifiedRate: 50 }
  ]);
  assert.equal(filled(rows).length, 1);
  assert.equal(rows[0].date, '2026/04/01');
  assert.equal(rows[0].voltage, '90.00 %');
});

test('CreatedAtMs 按本地自然日分组，午夜两侧分开，优先于附带 DataDate', () => {
  const records = [
    { CreatedAtMs: new Date(2026, 3, 2, 0, 1).getTime(), DataDate: '2026-03-31', VoltageQualifiRate_All: 92 },
    { CreatedAtMs: new Date(2026, 3, 1, 23, 59).getTime(), DataDate: '2026-03-31', VoltageQualifiRate_All: 91 }
  ];
  const rows = filled(buildDailyQualificationRows(records));
  assert.deepEqual(Array.from(rows, row => row.date), ['2026/04/01', '2026/04/02']);
  assert.deepEqual(Array.from(rows, row => row.voltage), ['91.00 %', '92.00 %']);
  const utcTime = new Date(2026, 3, 2, 0, 1).toISOString();
  assert.equal(buildDailyQualificationRows([{ CreateTime: utcTime }])[0].date, '2026/04/02');
});

test('非法日期、无记录与不足九日均不伪造日期，空行保持 --', () => {
  const rows = buildDailyQualificationRows([
    null, {}, 7, [], { DataDate: '2026-02-29' }, { DataDate: '2026-04-31' }, { DataDate: '2026-13-01' },
    { CreateTime: '2026-04-01 25:00:00' }, { CreateTime: '2026-04-01 12:60:00' },
    { DataDate: '2024/2/29', VoltageQualifiedRate: 95 }
  ]);
  assert.equal(rows.length, 9);
  assert.equal(filled(rows).length, 1);
  assert.equal(rows[0].date, '2024/02/29');
  for (const row of rows.slice(1)) {
    assert.equal(row.date, '--');
    assert.equal(row.voltage, '--');
    assert.equal(row.frequency, '--');
    assert.equal(row.flicker, '--');
  }
  assert.equal(filled(buildDailyQualificationRows([])).length, 0);
});

test('电压两位小数、频率三位，接受当前线路数组并保留合法零值', () => {
  const rows = buildDailyQualificationRows([
    { DataDate: '2026-04-01', VoltageQualifiedRate: [98.125, 12], FrequencyQualifiedRate: [99.1234, 23] },
    { DataDate: '2026-04-02', VoltageQualifiRate_All: 0, VoltageQualifiedRate: 99, FreqQualifiRate_All: 0, FrequencyQualifiedRate: 99 }
  ]);
  assert.equal(rows[0].voltage, '98.13 %');
  assert.equal(rows[0].frequency, '99.123 %');
  assert.equal(rows[1].voltage, '0.00 %');
  assert.equal(rows[1].frequency, '0.000 %');
  assert.equal(qualificationRateText(-0.00001, 2), '0.00 %');
});

test('非法数字和未绑定的闪变显示 --，不由越限次数或固定 100% 推算', () => {
  for (const value of [undefined, null, NaN, Infinity, [], [null], ['99'], '99', {}]) {
    assert.equal(qualificationRateText(value, 2), '--');
  }
  const rows = buildDailyQualificationRows([{ DataDate: '2026-04-01', FlickerOverageCount: 0 }]);
  assert.equal(rows[0].flicker, '--');
  assert.equal(rows[0].voltage, '--');
});

test('终端过滤排除其他设备记录，服务已过滤但省略 TerminalId 的记录仍可显示', () => {
  const rows = buildDailyQualificationRows([
    { DataDate: '2026-04-01', TerminalId: 'device-a', VoltageQualifiedRate: 90 },
    { DataDate: '2026-04-02', TerminalId: 'device-b', VoltageQualifiedRate: 99 },
    { DataDate: '2026-04-03', VoltageQualifiedRate: 95 }
  ], 'device-a');
  assert.deepEqual(Array.from(filled(rows), row => row.date), ['2026/04/01', '2026/04/03']);
});

test('响应支持数组和 data 外层，区分空结果与服务错误', () => {
  assert.equal(parseQualificationReport('[]').length, 0);
  assert.equal(parseQualificationReport('{"code":200,"success":true,"data":[]}').length, 0);
  assert.equal(parseQualificationReport('[{"DataDate":"2026-04-01"}]')[0].DataDate, '2026-04-01');
  for (const value of ['null', '5', '"text"', '{}', '{"data":{}}', '{"data":null}',
    '{"success":false,"data":[]}', '{"code":500,"data":[]}', 'bad json']) {
    assert.throws(() => parseQualificationReport(value));
  }
});
