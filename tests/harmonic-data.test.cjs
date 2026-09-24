const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

// 复用 DevEco 自带 TypeScript，只加载不依赖 ArkUI 的实际数据逻辑。
const ts = require(process.env.HARMONIC_TYPESCRIPT_PATH || 'typescript');
const source = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/pages/quality/HarmonicData.ets'), 'utf8');
const compiled = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 },
  reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);
const context = { exports: {} };
vm.runInNewContext(compiled.outputText, context);
const { buildHarmonicRows, buildHarmonicSummary, harmonicAxisMaximum, formatHarmonicValue } = context.exports;

test('1～63 次保持固定位置，含有率来自有效值，保留小于 0.1% 的谐波', () => {
  const rms = Array(70).fill(0);
  rms[0] = 220;
  rms[1] = 0.11;
  rms[62] = 22;
  const rows = buildHarmonicRows({ Ua_RMS: [rms], Ua_HarmonicRatio: [[7, 7, 7]] }, {}, 0);
  assert.equal(rows.length, 63);
  assert.equal(rows[0].contentRate, '100.00 %');
  assert.equal(rows[1].contentRate, '0.05 %');
  assert.equal(rows[2].contentRate, '0.00 %');
  assert.equal(rows[62].order, 63);
  assert.equal(rows[62].contentRate, '10.00 %');
});

test('基波为零或不超过阈值时不除零，含有率限制在 0～100%', () => {
  for (const base of [0, 0.0001, -0.0001]) {
    assert.equal(buildHarmonicRows({ Ua_RMS: [[base, 2]] }, {}, 0)[1].ratio, 0);
  }
  const rows = buildHarmonicRows({ Ua_RMS: [[2, 3, -1]] }, {}, 0);
  assert.equal(rows[1].ratio, 100);
  assert.equal(rows[2].ratio, 0);
});

test('六通道分别读取本相数据和线路 1，电压电流使用正确单位', () => {
  const voltage = {};
  const current = {};
  ['Ua', 'Ub', 'Uc', 'Ia', 'Ib', 'Ic'].forEach((name, index) => {
    const target = index < 3 ? voltage : current;
    target[name + '_RMS'] = [[100 + index, index + 1], [999, 999]];
    target[name + '_Angle'] = [[index, 10 + index]];
  });
  for (let index = 0; index < 6; index++) {
    const rows = buildHarmonicRows(voltage, current, index);
    assert.equal(rows[1].rmsValue, (index + 1).toFixed(3) + (index < 3 ? ' V' : ' A'));
    assert.equal(rows[1].phaseAngle, (10 + index).toFixed(3) + ' °');
  }
});

test('同相 U × I 得到视在功率，功率因数取相角差余弦并随另一通道更新', () => {
  const voltage = { Ua_RMS: [[220, 20]], Ua_Angle: [[30, 180]], Ub_RMS: [[9999]] };
  const current = { Ia_RMS: [[10, 2]], Ia_Angle: [[-30, 0]], Ib_RMS: [[9999]] };
  for (const channel of [0, 3]) {
    const rows = buildHarmonicRows(voltage, current, channel);
    assert.equal(rows[0].apparentPower, '2.200 kVA');
    assert.equal(rows[0].powerFactor, '0.50');
    assert.equal(rows[1].apparentPower, '0.040 kVA');
    assert.equal(rows[1].powerFactor, '-1.00');
  }
  current.Ia_RMS[0][0] = 20;
  assert.equal(buildHarmonicRows(voltage, current, 0)[0].apparentPower, '4.400 kVA');
  assert.equal(buildHarmonicRows({ Ua_RMS: [[0]] }, { Ia_RMS: [[10]] }, 0)[0].powerFactor, '0.00');
});

test('缺失、短数组和非有限数显示 --，未知相角不会被当作零角度', () => {
  const rows = buildHarmonicRows({ Ua_RMS: [[220, NaN, Infinity]], Ua_Angle: [[null]] }, { Ia_RMS: [[10]] }, 0);
  assert.equal(rows.length, 63);
  assert.equal(rows[0].phaseAngle, '--');
  assert.equal(rows[0].powerFactor, '--');
  assert.equal(rows[1].contentRate, '--');
  assert.equal(rows[2].rmsValue, '--');
  assert.equal(rows[62].apparentPower, '--');
  assert.equal(buildHarmonicRows({ Ua_RMS: null }, {}, 0)[0].rmsValue, '--');
});

test('单位在 Qt 的阈值处切换，数值保留对应小数位', () => {
  const voltage = { Ua_RMS: [[1000, 2000]], Ua_Angle: [[0, 0]] };
  const current = { Ia_RMS: [[1000, 2000]], Ia_Angle: [[0, 0]] };
  const rows = buildHarmonicRows(voltage, current, 0);
  assert.equal(rows[0].rmsValue, '1000.000 V');
  assert.equal(rows[1].rmsValue, '2.000 kV');
  assert.equal(rows[0].apparentPower, '1000.000 kVA');
  assert.equal(rows[1].apparentPower, '4.000 MVA');
  assert.equal(buildHarmonicRows(voltage, current, 3)[1].rmsValue, '2.000 kA');
  assert.equal(formatHarmonicValue(-0.00001, 2), '0.00');
});

test('三相电流汇总读取 CurrentTHD，功率共享相别且峰值因子区分电压电流', () => {
  const data = {};
  ['A', 'B', 'C'].forEach((phase, index) => {
    data['VoltageTHD_' + phase] = [index + 1];
    data['CurrentTHD_' + phase] = [index + 11];
    data['VoltageOddTHD_' + phase] = [index + 2];
    data['CurrentOddTHD_' + phase] = [index + 12];
    data['VoltageEvenTHD_' + phase] = [index + 3];
    data['CurrentEvenTHD_' + phase] = [index + 13];
    data['PowerP_THD_' + phase] = [index + 100];
    data['PowerQ_THD_' + phase] = [index + 200];
    data['PowerS_THD_' + phase] = [index + 300];
    data['PowerF_THD_' + phase] = [0.9];
    data['PeakFactor_U' + phase.toLowerCase()] = [index + 1.4];
    data['PeakFactor_I' + phase.toLowerCase()] = [index + 2.4];
  });
  for (let channel = 0; channel < 6; channel++) {
    const summary = buildHarmonicSummary(data, channel);
    const phase = channel % 3;
    const offset = channel < 3 ? 0 : 10;
    assert.equal(summary.length, 8);
    assert.equal(summary[0].value, (phase + offset + 1).toFixed(2) + ' %');
    assert.equal(summary[3].value, (phase + offset + 2).toFixed(2) + ' %');
    assert.equal(summary[6].value, (phase + offset + 3).toFixed(2) + ' %');
    assert.equal(summary[1].value, (phase + 100).toFixed(2) + ' W');
    assert.equal(summary[4].value, (phase + 200).toFixed(2) + ' Var');
    assert.equal(summary[7].value, (phase + 300).toFixed(2) + ' VA');
    assert.equal(summary[2].value, '0.90');
    assert.equal(summary[5].value, (phase + (channel < 3 ? 1.4 : 2.4)).toFixed(2));
  }
  assert.equal(buildHarmonicSummary({}, 3)[0].value, '--');
});

test('柱状图纵轴最低 10，按 10 向上取整且最高 100', () => {
  assert.equal(harmonicAxisMaximum([]), 10);
  assert.equal(harmonicAxisMaximum([0, NaN, 0.05]), 10);
  assert.equal(harmonicAxisMaximum([10.01]), 20);
  assert.equal(harmonicAxisMaximum([82]), 90);
  assert.equal(harmonicAxisMaximum([100, 250]), 100);
});
