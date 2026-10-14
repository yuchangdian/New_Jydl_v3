const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require(process.env.HISTORY_TYPESCRIPT_PATH || 'typescript');
const source = fs.readFileSync(path.join(__dirname,
  '../entry/src/main/ets/pages/quality/QtHistoryDateDialog.ets'), 'utf8');
const compiled = ts.transpileModule(source.slice(0, source.indexOf('@Component')), {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 },
  reportDiagnostics: true
});
assert.equal(compiled.diagnostics.length, 0);
const context = { exports: {}, Date };
vm.runInNewContext(compiled.outputText, context);
const { buildHistoryCalendarWeeks } = context.exports;
const numbers = week => Array.from(week.days, day => day.date.getDate());

test('Qt 中文日历从周一开始，显示周号和六周，包括相邻月', () => {
  const weeks = buildHistoryCalendarWeeks(2026, 9);
  assert.equal(weeks.length, 6);
  assert.deepEqual(numbers(weeks[0]), [28, 29, 30, 1, 2, 3, 4]);
  assert.deepEqual(numbers(weeks[5]), [2, 3, 4, 5, 6, 7, 8]);
  assert.deepEqual(Array.from(weeks, week => week.number), [40, 41, 42, 43, 44, 45]);
  assert.equal(weeks[0].days[0].inMonth, false);
  assert.equal(weeks[0].days[3].inMonth, true);
});

test('一号为周一时与 QCalendarWidget 一致，首行保留完整上一周', () => {
  const weeks = buildHistoryCalendarWeeks(2026, 5);
  assert.deepEqual(numbers(weeks[0]), [25, 26, 27, 28, 29, 30, 31]);
  assert.equal(weeks[0].number, 22);
  assert.deepEqual(numbers(weeks[1]), [1, 2, 3, 4, 5, 6, 7]);
});

test('闰年二月和跨年的 ISO 周号正确', () => {
  const leap = buildHistoryCalendarWeeks(2024, 1);
  assert.deepEqual(numbers(leap[4]), [26, 27, 28, 29, 1, 2, 3]);
  assert.equal(leap[4].days[3].inMonth, true);
  const january = buildHistoryCalendarWeeks(2025, 0);
  assert.deepEqual(numbers(january[0]), [30, 31, 1, 2, 3, 4, 5]);
  assert.equal(january[0].number, 1);
});
