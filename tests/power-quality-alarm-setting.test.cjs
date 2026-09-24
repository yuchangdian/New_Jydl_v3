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
  packetMatchesFields
} = context.exports;

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
