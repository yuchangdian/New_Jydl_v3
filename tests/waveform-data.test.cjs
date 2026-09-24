const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require(process.env.WAVEFORM_TYPESCRIPT_PATH || 'typescript');
const source = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/pages/pqInsight/WaveformData.ets'), 'utf8');
const compiled = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 },
  reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);
const context = { exports: {} };
vm.runInNewContext(compiled.outputText, context);
const { WaveformBuffer, waveformRms, waveformRange, waveformY, emptyWaveformFrame } = context.exports;
const allVisible = Array(6).fill(true);
const samples = value => Array(400).fill(value);
const packet = (index, revision = 1, value = index + 1, sessionId = 0) => ({
  ready: true, revision, sessionId, commonAddress: 0x1311, objectAddress: 0xB1 + index,
  payloadLength: 807, fields: [{ name: 'Value', values: samples(value) }]
});
const batch = (revision = 1, value = 2, sessionId = 0) =>
  Array.from({ length: 6 }, (_, index) => packet(index, revision, value, sessionId));

test('初始无演示数据；400 点整段 RMS 包含直流与负数，电压一位、电流两位', () => {
  const buffer = new WaveformBuffer();
  assert.equal(buffer.hasCompleteFrame, false);
  assert.ok(buffer.displayed.samples.every(values => values.length === 0));
  assert.ok(buffer.displayed.rms.every(value => value === '--'));
  const sine = Array.from({ length: 400 }, (_, i) => 80 * Math.sin(i / 400 * 2 * Math.PI));
  assert.ok(Math.abs(waveformRms(sine) - 80 / Math.sqrt(2)) < 1e-10);
  assert.equal(waveformRms(samples(-3)), 3);
  const input = batch(1, -1.25);
  assert.equal(buffer.accept(input), true);
  assert.equal(buffer.displayed.rms[0], '1.3V');
  assert.equal(buffer.displayed.rms[3], '1.25A');
  assert.equal(buffer.displayed.samples[0][0], -1.25); // native 已换算，不再除以 100。
});

test('六路乱序到达后统一提交，重复读取缓存不凑成新一帧', () => {
  const buffer = new WaveformBuffer();
  const input = batch();
  input.forEach(p => { p.ready = false; });
  for (const index of [5, 2, 0, 3, 1]) {
    input[index].ready = true;
    assert.equal(buffer.accept(input), false);
  }
  assert.equal(buffer.receivedCount, 5);
  assert.equal(buffer.displayed.rms[0], '--');
  input[4].ready = true;
  assert.equal(buffer.accept(input), true);
  const shown = buffer.displayed;
  assert.equal(buffer.accept(input), false);
  assert.equal(buffer.receivedCount, 0);
  input[0] = packet(0, 2, 99);
  assert.equal(buffer.accept(input), false);
  assert.equal(buffer.receivedCount, 1);
  assert.equal(buffer.displayed, shown);
  for (let i = 1; i < 6; i++) input[i] = packet(i, 2, 99);
  assert.equal(buffer.accept(input), true);
  assert.equal(buffer.displayed.rms[0], '99.0V');
});

test('暂停同时冻结曲线与 RMS，恢复只显示最新完整帧，不混入半帧', () => {
  const buffer = new WaveformBuffer();
  buffer.accept(batch(1, 1));
  const frozen = buffer.displayed;
  buffer.setRefreshing(false);
  assert.equal(buffer.accept(batch(2, 2)), true);
  assert.equal(buffer.accept(batch(3, 3)), true);
  assert.equal(buffer.displayed, frozen);
  const partial = batch(3, 3);
  partial[0] = packet(0, 4, 4);
  assert.equal(buffer.accept(partial), false);
  buffer.setRefreshing(true);
  assert.equal(buffer.displayed.samples[0][0], 3);
  assert.equal(buffer.displayed.rms[0], '3.0V');
  assert.equal(buffer.displayed.rms[3], '3.00A');
});

test('短包、长包、缺失字段、非法数字和错误地址均不提交', () => {
  for (const mutate of [
    p => { p.fields[0].values.pop(); },
    p => { p.fields[0].values.push(1); },
    p => { p.fields = []; },
    p => { p.fields[0].values[200] = NaN; },
    p => { p.fields[0].values[200] = Infinity; },
    p => { p.fields[0].values[200] = null; },
    p => { p.objectAddress = 0x33; },
    p => { p.commonAddress = 0x1344; },
    p => { p.revision = NaN; }
  ]) {
    const buffer = new WaveformBuffer();
    const input = batch();
    mutate(input[2]);
    assert.equal(buffer.accept(input), false);
    assert.equal(buffer.hasCompleteFrame, false);
    assert.equal(buffer.receivedCount, 5);
  }
  assert.equal(waveformRms([]), undefined);
  assert.equal(waveformRms([1]), undefined);
});

test('零值是有效数据，重复内容的新回包按版本接收，快照与外部数组隔离', () => {
  const buffer = new WaveformBuffer();
  const input = batch(1, 0);
  assert.equal(buffer.accept(input), true);
  assert.equal(buffer.displayed.rms[0], '0.0V');
  assert.equal(buffer.displayed.rms[3], '0.00A');
  const previous = buffer.displayed;
  input[0].fields[0].values[0] = 999;
  assert.equal(previous.samples[0][0], 0);
  assert.equal(buffer.accept(batch(2, 0)), true);
  assert.notEqual(buffer.displayed, previous);
});

test('重连清除未完成组和旧的恢复快照，跨连接混合读取不提交', () => {
  const buffer = new WaveformBuffer();
  buffer.accept(batch(1, 1));
  buffer.setRefreshing(false);
  buffer.accept(batch(2, 2));
  const reconnect = batch(3, 3, 1);
  reconnect[5].ready = false;
  assert.equal(buffer.accept(reconnect), false);
  assert.equal(buffer.receivedCount, 5);
  assert.equal(buffer.hasCompleteFrame, false);
  buffer.setRefreshing(true);
  assert.equal(buffer.displayed.rms[0], '1.0V');
  reconnect[5].ready = true;
  reconnect[5].sessionId = 2;
  assert.equal(buffer.accept(reconnect), false);
  reconnect[5].sessionId = 1;
  assert.equal(buffer.accept(reconnect), true);
  assert.equal(buffer.displayed.rms[0], '3.0V');
});

test('双纵轴分别按可见通道计算并加余量，隐藏大幅值通道后范围收缩', () => {
  const input = [samples(-80), samples(80), samples(200), samples(-1), samples(1), samples(2)];
  let range = waveformRange(input, allVisible, true);
  assert.equal(range.min, -94);
  assert.equal(range.max, 214);
  range = waveformRange(input, [true, true, false, true, true, false], true);
  assert.equal(range.min, -88);
  assert.equal(range.max, 88);
  range = waveformRange(input, [true, true, false, true, true, false], false);
  assert.equal(range.min, -1.1);
  assert.equal(range.max, 1.1);
  range = waveformRange(Array.from({ length: 6 }, () => samples(0)), allVisible, true);
  assert.equal(range.min, -1);
  assert.equal(range.max, 1);
  range = waveformRange(emptyWaveformFrame().samples, Array(6).fill(false), false);
  assert.equal(range.min, -1.65);
  assert.equal(range.max, 1.65);
});

test('Qt 95%/70% 居中高度及边界裁剪', () => {
  const range = { min: -1, max: 1 };
  assert.ok(Math.abs(waveformY(1, range, true, 10, 200) - 15) < 1e-10);
  assert.ok(Math.abs(waveformY(-1, range, true, 10, 200) - 205) < 1e-10);
  assert.ok(Math.abs(waveformY(1, range, false, 10, 200) - 40) < 1e-10);
  assert.ok(Math.abs(waveformY(-1, range, false, 10, 200) - 180) < 1e-10);
  assert.equal(waveformY(0, range, true, 10, 200), 110);
  assert.equal(waveformY(9, range, true, 10, 200), waveformY(1, range, true, 10, 200));
});
