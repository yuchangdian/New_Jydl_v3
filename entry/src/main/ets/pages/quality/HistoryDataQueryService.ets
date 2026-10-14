import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';
import nativeHistory, { HistoryNativeBatch } from 'libentry.so';

export interface HistoryExportDocument {
  name: string;
  path: string;
  rows: number;
}

interface HistoryGroup {
  name: string;
  table: string;
  types: string[];
  fields: string[];
  widths: number[];
}

const BASE_FIELDS: string[] = [
  'Flag_BD_LockOK', 'Ua_Frequency', 'Ub_Frequency', 'Uc_Frequency',
  'Ua_Rms', 'Ua_Phase', 'Ub_Rms', 'Ub_Phase', 'Uc_Rms', 'Uc_Phase', 'Uo_Rms', 'Uo_Phase',
  'IA_Rms', 'IA_Phase', 'IB_Rms', 'IB_Phase', 'IC_Rms', 'IC_Phase', 'Io_Rms', 'Io_Phase',
  'Pa', 'Qa', 'Sa', 'Fa', 'Pb', 'Qb', 'Sb', 'Fb', 'Pc', 'Qc', 'Sc', 'Fc', 'Pt', 'Qt', 'St', 'Ft'
];

// 与 Qt HistoryDataQueryService::PowerQualityNames 的字段顺序一致。
const QUALITY_FIELDS: string[] = [
  'FreqDeviation_A', 'FreqDeviation_B', 'FreqDeviation_C', 'FreqDeviation_All',
  'FreqQualifiRate_A', 'FreqQualifiRate_B', 'FreqQualifiRate_C', 'FreqQualifiRate_All',
  'VoltageDeviation_A', 'VoltageDeviation_B', 'VoltageDeviation_C', 'VoltageDeviation_AB',
  'VoltageDeviation_BC', 'VoltageDeviation_CA', 'VoltageQualifiRate_A', 'VoltageQualifiRate_B',
  'VoltageQualifiRate_C', 'VoltageQualifiRate_All', 'Voltage_U1', 'Voltage_U2', 'Voltage_Uo',
  'Current_I1', 'Current_I2', 'Current_Io', 'Voltage_U2_Unbalance', 'Voltage_Uo_Unbalance',
  'Current_I2_Unbalance', 'Current_In_Unbalance', 'VoltageFluct_A', 'VoltageFluct_B',
  'VoltageFluct_C', 'VoltageFluctFreq_A', 'VoltageFluctFreq_B', 'VoltageFluctFreq_C',
  'VoltageShortFlicke_A', 'VoltageShortFlicke_B', 'VoltageShortFlicke_C',
  'VoltageLongFlicke_A', 'VoltageLongFlicke_B', 'VoltageLongFlicke_C',
  'CurrentTHD_A', 'CurrentTHD_B', 'CurrentTHD_C', 'CurrentOddTHD_A', 'CurrentOddTHD_B',
  'CurrentOddTHD_C', 'CurrentEvenTHD_A', 'CurrentEvenTHD_B', 'CurrentEvenTHD_C',
  'CurrentInterTHD_A', 'CurrentInterTHD_B', 'CurrentInterTHD_C', 'FullWave_Ua', 'FullWave_Ub',
  'FullWave_Uc', 'FullWave_Uab', 'FullWave_Ubc', 'FullWave_Uca', 'FullWave_Ia', 'FullWave_Ib',
  'FullWave_Ic', 'VoltageTHD_A', 'VoltageTHD_B', 'VoltageTHD_C', 'VoltageOddTHD_A',
  'VoltageOddTHD_B', 'VoltageOddTHD_C', 'VoltageEvenTHD_A', 'VoltageEvenTHD_B',
  'VoltageEvenTHD_C', 'VoltageInterTHD_A', 'VoltageInterTHD_B', 'VoltageInterTHD_C',
  'PeakFactor_Ua', 'PeakFactor_Ub', 'PeakFactor_Uc', 'PeakFactor_Ia', 'PeakFactor_Ib',
  'PeakFactor_Ic', 'PowerP_THD_A', 'PowerP_THD_B', 'PowerP_THD_C', 'PowerQ_THD_A',
  'PowerQ_THD_B', 'PowerQ_THD_C', 'PowerS_THD_A', 'PowerS_THD_B', 'PowerS_THD_C',
  'PowerF_THD_A', 'PowerF_THD_B', 'PowerF_THD_C', 'FullWave_Pa', 'FullWave_Pb',
  'FullWave_Pc', 'FullWave_Pt', 'FullWave_Qa', 'FullWave_Qb', 'FullWave_Qc', 'FullWave_Qt',
  'FullWave_Sa', 'FullWave_Sb', 'FullWave_Sc', 'FullWave_St', 'FullWave_Fa', 'FullWave_Fb',
  'FullWave_Fc', 'FullWave_Ft'
];

const DISTORTION_FIELDS: string[] = ['ObjectAddress', 'Rms', 'Angle'];

function repeatWidth(count: number, width: number): number[] {
  const result: number[] = [];
  for (let i = 0; i < count; i++) result.push(width);
  return result;
}

export function createHistoryGroups(selected: boolean[]): HistoryGroup[] {
  const groups: HistoryGroup[] = [];
  if (selected[0]) groups.push({ name: 'Package_YC_BaseValue_Struct', table: 'Package_YC_BaseValue_Struct',
    types: ['BaseValue'], fields: BASE_FIELDS, widths: repeatWidth(BASE_FIELDS.length, 1) });
  if (selected[1]) groups.push({ name: 'Package_YC_PowerQuality_Struct', table: 'Package_YC_PowerQuality_Struct',
    types: ['PowerQuality'], fields: QUALITY_FIELDS, widths: repeatWidth(QUALITY_FIELDS.length, 1) });
  const distortionTypes: string[][] = [
    ['HD_Ua', 'HD_Ub', 'HD_Uc'], ['HD_Ia', 'HD_Ib', 'HD_Ic'],
    ['IHD_Ua', 'IHD_Ub', 'IHD_Uc'], ['IHD_Ia', 'IHD_Ib', 'IHD_Ic']
  ];
  const distortionNames: string[] = ['VoltageHD', 'CurrentHD', 'VoltageIHD', 'CurrentIHD'];
  for (let i = 0; i < distortionTypes.length; i++) {
    if (selected[i + 2]) groups.push({ name: distortionNames[i], table: 'Package_YC_Distortion_Struct',
      types: distortionTypes[i], fields: DISTORTION_FIELDS, widths: [1, 63, 63] });
  }
  return groups.sort((left: HistoryGroup, right: HistoryGroup) =>
    left.name < right.name ? -1 : left.name > right.name ? 1 : 0);
}

function csvCell(text: string): string {
  if (text.includes(',') || text.includes('"') || text.includes('\r') || text.includes('\n')) {
    return '"' + text.replace(/"/g, '""') + '"';
  }
  return text;
}

function pad(value: number, width: number): string {
  return value.toString().padStart(width, '0');
}

export function exportTimestamp(ms: number): string {
  const date = new Date(ms);
  return `${date.getFullYear()}-${pad(date.getMonth() + 1, 2)}-${pad(date.getDate(), 2)} ` +
    `${pad(date.getHours(), 2)}:${pad(date.getMinutes(), 2)}:${pad(date.getSeconds(), 2)}.` +
    `${pad(date.getMilliseconds(), 3)}`;
}

function numberText(value: number): string {
  return Number.isFinite(value) ? Number(value.toPrecision(12)).toString() : '';
}

function header(group: HistoryGroup): string {
  const columns: string[] = ['ID', '时间', 'TimeMs'];
  if (group.types.length > 1) columns.push('DataType');
  for (let i = 0; i < group.fields.length; i++) {
    if (group.widths[i] === 1) columns.push(group.fields[i]);
    else for (let j = 1; j <= group.widths[i]; j++) columns.push(`${group.fields[i]}_${j}`);
  }
  return columns.map(csvCell).join(',') + '\r\n';
}

function distortionAddress(type: string): number {
  const types: string[] = ['HD_Ua', 'HD_Ub', 'HD_Uc', 'HD_Ia', 'HD_Ib', 'HD_Ic',
    'IHD_Ua', 'IHD_Ub', 'IHD_Uc', 'IHD_Ia', 'IHD_Ib', 'IHD_Ic'];
  const index = types.indexOf(type);
  return index < 0 ? 0 : (index < 6 ? 0x81 + index : 0x91 + index - 6);
}

function floatValue(view: DataView, offset: number): string {
  return offset + 4 <= view.byteLength ? numberText(view.getFloat32(offset, true)) : '';
}

function decodePayload(group: HistoryGroup, blob: Uint8Array): string[] | undefined {
  const expected = 13 + (group.name === 'Package_YC_BaseValue_Struct' ? 4 + 35 * 4 : QUALITY_FIELDS.length * 4);
  if (blob.byteLength !== expected) return undefined;
  const view = new DataView(blob.buffer, blob.byteOffset, blob.byteLength);
  const values: string[] = [];
  if (group.name === 'Package_YC_BaseValue_Struct') {
    values.push(view.getUint32(13, true).toString());
    for (let i = 0; i < 35; i++) values.push(floatValue(view, 17 + i * 4));
  } else {
    for (let i = 0; i < QUALITY_FIELDS.length; i++) values.push(floatValue(view, 13 + i * 4));
  }
  return values;
}

function decodeDistortion(address: number, rms: Uint8Array, angle: Uint8Array): string[] {
  const values: string[] = [address.toString()];
  for (const blob of [rms, angle]) {
    if (blob.byteLength !== 63 * 4) {
      for (let i = 0; i < 63; i++) values.push('0');
    } else {
      const view = new DataView(blob.buffer, blob.byteOffset, blob.byteLength);
      for (let i = 0; i < 63; i++) values.push(floatValue(view, i * 4));
    }
  }
  return values;
}

function appendText(fd: number, value: string): void {
  const written = fs.writeSync(fd, value);
  if (written <= 0) throw new Error('CSV 写入失败');
}

function appendHeader(fd: number, group: HistoryGroup): void {
  // Qt 使用 GB18030。CSV 中只有列名“时间”包含非 ASCII 字符。
  appendText(fd, 'ID,');
  const chinese = new Uint8Array([0xCA, 0xB1, 0xBC, 0xE4]);
  fs.writeSync(fd, chinese.buffer);
  appendText(fd, header(group).substring('ID,时间'.length));
}

export class HistoryDataQueryService {
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async export(startMs: number, endMs: number, selected: boolean[], exportTime: string,
    generation: number, isCurrent: (generation: number) => boolean): Promise<HistoryExportDocument[]> {
    let databasePath = '/data/Report.db';
    try { fs.accessSync(databasePath); }
    catch (_) { databasePath = `${this.context.databaseDir}/Report.db`; }
    try { fs.accessSync(databasePath); }
    catch (_) { throw new Error('未找到 /data/Report.db 或应用数据库目录中的 Report.db'); }
    const duration = endMs - startMs;
    const sampleStep = duration > 7 * 86400000 ? 1000 : duration > 86400000 ? 100 : 1;
    const documents: HistoryExportDocument[] = [];
    const errors: string[] = [];
    for (const group of createHistoryGroups(selected)) {
      if (!isCurrent(generation)) break;
      const path = `${this.context.cacheDir}/PowerQualityHistory_${exportTime}_${group.name}.csv`;
      const file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      let rows = 0;
      try {
        appendHeader(file.fd, group);
        for (const type of group.types) {
          const address = distortionAddress(type);
          const distortion = address !== 0;
          const handle = nativeHistory.openHistoryQuery(databasePath, group.table,
            startMs, endMs + 1, address, sampleStep);
          try {
            let done = false;
            while (!done) {
              if (!isCurrent(generation)) break;
              const batch: HistoryNativeBatch = nativeHistory.nextHistoryBatch(handle);
              for (const record of batch.rows) {
                if (!isCurrent(generation)) break;
                const values = distortion
                  ? decodeDistortion(record.address ?? 0, new Uint8Array(record.rms ?? new ArrayBuffer(0)),
                    new Uint8Array(record.angle ?? new ArrayBuffer(0)))
                  : decodePayload(group, new Uint8Array(record.payload ?? new ArrayBuffer(0)));
                if (!values) continue;
                const row: string[] = [(rows + 1).toString(), exportTimestamp(record.timestampMs),
                  record.timeMs.toString()];
                if (group.types.length > 1) row.push(type);
                appendText(file.fd, row.concat(values).map(csvCell).join(',') + '\r\n');
                rows++;
              }
              done = batch.done;
              await new Promise<void>((resolve) => setTimeout(resolve, 0));
            }
          } finally {
            nativeHistory.closeHistoryQuery(handle);
          }
          if (!isCurrent(generation)) break;
        }
      } catch (error) {
        fs.closeSync(file);
        fs.unlinkSync(path);
        errors.push(`${group.name}：${String(error)}`);
        continue;
      }
      fs.closeSync(file);
      if (!isCurrent(generation) || rows === 0) {
        fs.unlinkSync(path);
      } else {
        documents.push({ name: `PowerQualityHistory_${exportTime}_${group.name}.csv`, path: path, rows: rows });
      }
    }
    if (!isCurrent(generation)) {
      for (const document of documents) fs.unlinkSync(document.path);
      return [];
    }
    if (documents.length === 0 && errors.length > 0) throw new Error(errors.join('\n'));
    return documents;
  }
}
