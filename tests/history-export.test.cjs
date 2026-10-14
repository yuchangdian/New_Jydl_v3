const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const ts = require(process.env.HISTORY_TYPESCRIPT_PATH || 'typescript');
const source = fs.readFileSync(path.join(__dirname,
  '../entry/src/main/ets/pages/quality/HistoryDataQueryService.ets'), 'utf8');
const compiled = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 },
  reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);

function loadService(nativeRows = []) {
  const output = [];
  const queries = [];
  const fakeFs = {
    OpenMode: { CREATE: 1, READ_WRITE: 2, TRUNC: 4 },
    accessSync: () => {},
    openSync: () => ({ fd: 3 }),
    writeSync: (_fd, value) => { output.push(value); return typeof value === 'string' ? value.length : value.byteLength; },
    closeSync: () => {},
    unlinkSync: () => {}
  };
  const native = {
    openHistoryQuery: (...args) => { queries.push(args); return 1; },
    nextHistoryBatch: () => ({ rows: nativeRows, done: true }),
    closeHistoryQuery: () => {}
  };
  const context = vm.createContext({ exports: {}, Date, Uint8Array, ArrayBuffer, DataView,
    setTimeout, require: name => name === '@ohos.file.fs' ? { default: fakeFs } : { default: native } });
  vm.runInContext(compiled.outputText, context);
  return { ...context.exports, context, output, queries };
}

test('六类导出按 Qt 的六个文件结构分组，谐波保留三相类型', () => {
  const { createHistoryGroups } = loadService();
  const groups = createHistoryGroups([true, true, true, true, true, true]);
  assert.deepEqual(Array.from(groups, group => group.name), [
    'CurrentHD', 'CurrentIHD', 'Package_YC_BaseValue_Struct',
    'Package_YC_PowerQuality_Struct', 'VoltageHD', 'VoltageIHD'
  ]);
  assert.deepEqual(Array.from(groups.find(group => group.name === 'VoltageHD').types), ['HD_Ua', 'HD_Ub', 'HD_Uc']);
  assert.equal(groups.find(group => group.name === 'VoltageHD').widths.reduce((a, b) => a + b), 127);
  assert.equal(groups.find(group => group.name === 'Package_YC_PowerQuality_Struct').fields.length, 107);
});

test('按 Qt 打包布局解码基波，并生成 GB18030 的时间列名', async () => {
  const bytes = new Uint8Array(157);
  const view = new DataView(bytes.buffer);
  view.setUint32(13, 7, true);
  view.setFloat32(17, 49.875, true);
  view.setFloat32(153, -0.75, true);
  const { HistoryDataQueryService, output, queries } = loadService([{
    timestampMs: new Date(2026, 8, 28, 12, 34, 56, 789).getTime(), timeMs: 123,
    payload: bytes.buffer
  }]);
  const service = new HistoryDataQueryService({ databaseDir: '/sandbox/db', cacheDir: '/sandbox/cache' });
  const files = await service.export(1000, 2000, [true, false, false, false, false, false],
    '20260928_120000', 1, () => true);
  assert.equal(files.length, 1);
  assert.equal(files[0].rows, 1);
  assert.deepEqual(queries[0], ['/data/Report.db', 'Package_YC_BaseValue_Struct', 1000, 2001, 0, 1]);
  const text = output.filter(value => typeof value === 'string').join('');
  assert.equal(output[0], 'ID,');
  assert.match(text, /,TimeMs,Flag_BD_LockOK,Ua_Frequency/);
  assert.match(text, /,123,7,49\.875/);
  assert.match(text, /,-0\.75\r\n$/);
  assert.deepEqual(Array.from(new Uint8Array(output.find(value => value instanceof ArrayBuffer))),
    [0xCA, 0xB1, 0xBC, 0xE4]);
});

test('超过一日和七日时，沿用 Qt 的抽样步长', async () => {
  for (const [duration, expected] of [[86400000, 1], [86400001, 100],
    [7 * 86400000, 100], [7 * 86400000 + 1, 1000]]) {
    const { HistoryDataQueryService, queries } = loadService();
    const service = new HistoryDataQueryService({ databaseDir: '/db', cacheDir: '/cache' });
    await service.export(0, duration, [true, false, false, false, false, false], 'stamp', 1, () => true);
    assert.equal(queries[0][5], expected);
  }
});

test('电能质量末字段与 63 点畸变数组按原始字节顺序导出', () => {
  const { createHistoryGroups, context } = loadService();
  const quality = createHistoryGroups([false, true, false, false, false, false])[0];
  const payload = new Uint8Array(13 + 107 * 4);
  const view = new DataView(payload.buffer);
  view.setFloat32(13, 0.125, true);
  view.setFloat32(13 + 106 * 4, 99.5, true);
  context.payload = payload;
  context.quality = quality;
  const decoded = vm.runInContext('decodePayload(quality, payload)', context);
  assert.equal(decoded.length, 107);
  assert.equal(decoded[0], '0.125');
  assert.equal(decoded[106], '99.5');

  const rms = new Uint8Array(63 * 4);
  const angle = new Uint8Array(63 * 4);
  new DataView(rms.buffer).setFloat32(62 * 4, 1.5, true);
  new DataView(angle.buffer).setFloat32(0, -30, true);
  context.rms = rms;
  context.angle = angle;
  const distortion = vm.runInContext('decodeDistortion(0x81, rms, angle)', context);
  assert.equal(distortion.length, 127);
  assert.equal(distortion[0], '129');
  assert.equal(distortion[63], '1.5');
  assert.equal(distortion[64], '-30');
});
