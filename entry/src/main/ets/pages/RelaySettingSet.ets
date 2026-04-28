import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import * as relaySettingNativeModule from 'libentry.so';
import {
  RELAY_SETTING_PROFILES_STORE_KEY,
  RelayFieldBinding,
  RelaySettingProfile,
  RelaySettingProfilesStore,
  RelayStoredField,
  buildRelayFieldBindings,
  createDefaultRelaySettingProfile,
  createDefaultRelaySettingProfileForSetZone,
  relayDefaultSelectOptions,
  relayDefaultStoredField,
  relayFindFieldBinding,
  relayFormatStoredField,
  relayLegacyZoneCodeForIndex,
  relayParseStoredField,
  relayReadProfileField,
  relayRememberProfilesStoreInSession,
  relaySerializeProfilesStore,
  relaySetZoneCodeForIndex,
  relaySetZoneCodeToIndex,
  relaySetZoneCodeToLegacyZoneCode,
  relayNormalizeSetZoneCode,
  relayWriteProfileField,
  RELAY_PROFILE_COUNT
} from './RelaySettingProfiles';
import {
  createRelayMainSections,
  createRelayMonitorSections,
  RelayCellSpec,
  RelayMonitorFieldSpec,
  RelayMonitorSectionSpec,
  RelayRowItemSpec,
  RelayRowSpec,
  RelaySectionSpec
} from './RelaySettingSetSchema';

const RELAY_SETTING_STORE_KEY: string = 'relay_setting_set_store';

PersistentStorage.persistProp(RELAY_SETTING_STORE_KEY, '');
PersistentStorage.persistProp(RELAY_SETTING_PROFILES_STORE_KEY, '');

@Observed
class StrapFlag {
  id: string;
  label: string;
  checked: boolean;
  enabled: boolean;

  constructor(id: string, label: string, checked: boolean = false, enabled: boolean = true) {
    this.id = id;
    this.label = label;
    this.checked = checked;
    this.enabled = enabled;
  }
}

@Observed
class HeaderModeState {
  inMode: StrapFlag = new StrapFlag('checkBox', '投入', true, true);
  outMode: StrapFlag = new StrapFlag('checkBox_2', '退出', false, true);
}

@Observed
class BottomActionState {
  defaultText: string = '默认值';
  confirmText: string = '确认';
  closeText: string = '关闭';
  cancelText: string = '取消';
}

class RouterParams {
  zoneCode?: string;
}

class RelayValueEntry {
  key: string;
  value: string;

  constructor(key: string, value: string) {
    this.key = key;
    this.value = value;
  }
}

interface AbilityFileContext {
  filesDir: string;
}

interface RelaySettingFieldEntry {
  id: string;
  value: string;
}

interface RelaySettingZoneValue {
  ready: boolean;
  zoneCode: number;
  fields: RelaySettingFieldEntry[];
}

interface RelaySettingWriteFieldEntry {
  id: string;
  textValue: string;
  numberValue: number;
  enumValue: number;
}

interface RelaySettingWriteZoneValue {
  zoneCode: number;
  fields: RelaySettingWriteFieldEntry[];
}

interface RelaySettingNativeModule {
  getRelaySettingByZone?: (zoneCode: number) => RelaySettingZoneValue | undefined;
  requestRelaySettingByZone?: (zoneCode: number) => boolean;
  updateRelaySettingByZone?: (value: RelaySettingWriteZoneValue) => boolean;
}

declare function requireNapi(
  moduleName: string,
  isAppModule?: boolean,
  modulePath?: string
): RelaySettingNativeModule | undefined;

let RELAY_MAIN_SECTIONS: RelaySectionSpec[] = [];
let RELAY_MONITOR_SECTIONS: RelayMonitorSectionSpec[] = [];
let RELAY_FIELD_BINDINGS: RelayFieldBinding[] = [];
let RELAY_BOUND_MAIN_CELLS: RelayCellSpec[] = [];
let RELAY_BOUND_MONITOR_FIELDS: RelayMonitorFieldSpec[] = [];
let RELAY_SCHEMA_READY: boolean = false;

function isUsableRelaySettingZoneValue(value: RelaySettingZoneValue | undefined): boolean {
  return !!value &&
    value.ready === true &&
    typeof value.zoneCode === 'number' &&
    Array.isArray(value.fields) &&
    value.fields.length > 0;
}

function relayLabelCellMinWidth(text: string): number {
  if (text.length >= 18) {
    return 248;
  }
  if (text.length >= 14) {
    return 210;
  }
  if (text.length >= 10) {
    return 178;
  }
  if (text.length >= 8) {
    return 158;
  }
  if (text.length >= 6) {
    return 126;
  }
  if (text.length >= 4) {
    return 104;
  }
  return 76;
}

function relayIsRightEdgeTimeCell(cellId: string): boolean {
  return cellId.indexOf('section-10-row-02-item-03-cell-') === 0 ||
    cellId.indexOf('section-11-row-02-item-05-cell-') === 0 ||
    cellId.indexOf('section-12-row-01-item-07-cell-') === 0 ||
    cellId.indexOf('section-13-row-03-item-05-cell-') === 0 ||
    cellId.indexOf('section-14-row-02-item-03-cell-') === 0 ||
    cellId.indexOf('section-15-row-02-item-03-cell-') === 0 ||
    cellId.indexOf('section-16-row-02-item-03-cell-') === 0 ||
    cellId.indexOf('section-17-row-02-item-05-cell-') === 0 ||
    cellId.indexOf('section-18-row-03-item-03-cell-') === 0 ||
    cellId.indexOf('section-21-row-02-item-03-cell-') === 0 ||
    cellId.indexOf('section-22-row-01-item-07-cell-') === 0 ||
    cellId.indexOf('section-23-row-01-item-07-cell-') === 0 ||
    cellId.indexOf('section-24-row-01-item-07-cell-') === 0 ||
    cellId.indexOf('section-25-row-01-item-07-cell-') === 0 ||
    cellId.indexOf('section-26-row-01-item-07-cell-') === 0 ||
    cellId.indexOf('section-27-row-01-item-07-cell-') === 0 ||
    cellId.indexOf('section-28-row-01-item-07-cell-') === 0;
}

function relayIsRightEdgeWideUnitCell(cellId: string): boolean {
  return cellId.indexOf('section-20-row-03-item-03-cell-') === 0 ||
    cellId.indexOf('section-20-row-03-item-05-cell-') === 0 ||
    cellId.indexOf('section-22-row-02-item-05-cell-') === 0 ||
    cellId.indexOf('section-22-row-03-item-05-cell-') === 0 ||
    cellId.indexOf('section-24-row-02-item-05-cell-') === 0 ||
    cellId.indexOf('section-24-row-03-item-05-cell-') === 0;
}

function relayUnitMinWidthForCell(cell: RelayCellSpec): number {
  if (relayIsRightEdgeTimeCell(cell.id)) {
    return cell.text.length >= 2 ? 12 : 10;
  }
  if (relayIsRightEdgeWideUnitCell(cell.id)) {
    return cell.text.length >= 4 ? 28 : 20;
  }
  if (cell.id.indexOf('section-01-row-') === 0) {
    return 28;
  }
  if (cell.text.length >= 4) {
    return 30;
  }
  if (cell.text.length >= 3) {
    return 26;
  }
  if (cell.text.length >= 2) {
    return 20;
  }
  return 16;
}

function relayUnitLeftMarginForCell(cell: RelayCellSpec): number {
  if (cell.id.indexOf('section-01-row-01-item-06-cell-01') === 0 ||
    cell.id.indexOf('section-01-row-01-item-10-cell-01') === 0 ||
    cell.id.indexOf('section-01-row-02-item-03-cell-01') === 0 ||
    cell.id.indexOf('section-01-row-02-item-07-cell-01') === 0 ||
    cell.id.indexOf('section-01-row-02-item-11-cell-01') === 0) {
    return 18;
  }
  if (cell.id.indexOf('section-05-row-01-item-05-cell-03') === 0 ||
    cell.id.indexOf('section-05-row-01-item-07-cell-03') === 0 ||
    cell.id.indexOf('section-06-row-01-item-05-cell-03') === 0 ||
    cell.id.indexOf('section-06-row-01-item-07-cell-03') === 0) {
    return 0;
  }
  if (cell.id.indexOf('section-01-row-') === 0) {
    return 8;
  }
  if (relayIsRightEdgeTimeCell(cell.id)) {
    return 0;
  }
  if (relayIsRightEdgeWideUnitCell(cell.id)) {
    return 1;
  }
  return 2;
}

function relaySelectCellMinWidth(text: string): number {
  if (text.length >= 16) {
    return 204;
  }
  if (text.length >= 12) {
    return 176;
  }
  if (text.length >= 8) {
    return 144;
  }
  if (text.length >= 5) {
    return 112;
  }
  if (text.length >= 3) {
    return 82;
  }
  return 64;
}

function relayValueCellMinWidth(text: string): number {
  if (text.length >= 18) {
    return 228;
  }
  if (text.length >= 12) {
    return 188;
  }
  if (text.length >= 9) {
    return 144;
  }
  if (text.length >= 6) {
    return 116;
  }
  return 92;
}

function relayLabelMinWidthForCell(cell: RelayCellSpec): number {
  if (cell.id.indexOf('section-01-row-01-item-04-cell-01') === 0) {
    return 164;
  }
  if (cell.id.indexOf('section-01-row-01-item-08-cell-01') === 0) {
    return 154;
  }
  if (cell.id.indexOf('section-05-row-01-item-05-cell-01') === 0 || cell.id.indexOf('section-06-row-01-item-05-cell-01') === 0) {
    return 82;
  }
  if (cell.id.indexOf('section-05-row-01-item-07-cell-01') === 0 || cell.id.indexOf('section-06-row-01-item-07-cell-01') === 0) {
    return 110;
  }
  if (cell.id.indexOf('section-07-row-01-item-01-cell-01') === 0) {
    return 124;
  }
  if (cell.id.indexOf('section-07-row-01-item-03-cell-01') === 0) {
    return 152;
  }
  if (cell.id.indexOf('section-11-row-02-item-05-cell-01') === 0 || cell.id.indexOf('section-17-row-02-item-05-cell-01') === 0) {
    return 122;
  }
  if (cell.id.indexOf('section-13-row-03-item-05-cell-01') === 0) {
    return 90;
  }
  if (cell.id.indexOf('section-21-row-02-item-03-cell-01') === 0) {
    return 96;
  }
  if (cell.id.indexOf('section-20-row-03-item-03-cell-01') === 0 || cell.id.indexOf('section-20-row-03-item-05-cell-01') === 0) {
    return 126;
  }
  if (cell.id.indexOf('section-22-row-02-item-05-cell-01') === 0 || cell.id.indexOf('section-24-row-02-item-05-cell-01') === 0) {
    return 128;
  }
  if (cell.id.indexOf('section-22-row-03-item-05-cell-01') === 0 || cell.id.indexOf('section-24-row-03-item-05-cell-01') === 0) {
    return 118;
  }
  if (relayIsRightEdgeTimeCell(cell.id)) {
    return 86;
  }
  if (cell.id.indexOf('section-19-row-01-item-03-cell-01') === 0 || cell.id.indexOf('section-19-row-01-item-05-cell-01') === 0) {
    return 98;
  }
  if (cell.id.indexOf('section-19-row-02-') === 0) {
    return cell.text.length >= 8 ? 104 : 88;
  }
  if (cell.id.indexOf('section-19-row-03-item-01-cell-01') === 0) {
    return 150;
  }
  if (cell.id.indexOf('section-19-row-03-item-03-cell-01') === 0) {
    return 192;
  }
  if (cell.id.indexOf('section-19-row-03-') === 0) {
    return 116;
  }
  return relayLabelCellMinWidth(cell.text);
}

function relaySelectMinWidthForCell(cell: RelayCellSpec): number {
  if (cell.id.indexOf('section-19-row-02-') === 0 || cell.id.indexOf('section-19-row-03-') === 0) {
    return 64;
  }
  return relaySelectCellMinWidth(cell.text);
}

function relayValueMinWidthForCell(cell: RelayCellSpec): number {
  if (cell.id.indexOf('section-01-row-01-item-05-cell-01') === 0 ||
    cell.id.indexOf('section-01-row-01-item-09-cell-01') === 0 ||
    cell.id.indexOf('section-01-row-02-item-06-cell-01') === 0 ||
    cell.id.indexOf('section-01-row-02-item-10-cell-01') === 0) {
    return 76;
  }
  if (cell.id.indexOf('section-01-row-02-item-02-cell-01') === 0) {
    return 80;
  }
  if (cell.id.indexOf('section-07-row-01-item-01-cell-03') === 0 || cell.id.indexOf('section-07-row-01-item-03-cell-03') === 0) {
    return 72;
  }
  if (cell.id.indexOf('section-05-row-01-item-05-cell-02') === 0 ||
    cell.id.indexOf('section-05-row-01-item-07-cell-02') === 0 ||
    cell.id.indexOf('section-06-row-01-item-05-cell-02') === 0 ||
    cell.id.indexOf('section-06-row-01-item-07-cell-02') === 0) {
    return 74;
  }
  if (cell.id.indexOf('section-11-row-02-item-05-cell-02') === 0 || cell.id.indexOf('section-17-row-02-item-05-cell-02') === 0) {
    return 74;
  }
  if (cell.id.indexOf('section-13-row-03-item-05-cell-02') === 0) {
    return 72;
  }
  if (cell.id.indexOf('section-20-row-03-item-03-cell-02') === 0 || cell.id.indexOf('section-20-row-03-item-05-cell-02') === 0) {
    return 78;
  }
  if (cell.id.indexOf('section-21-row-02-item-03-cell-02') === 0) {
    return 82;
  }
  if (cell.id.indexOf('section-22-row-02-item-05-cell-02') === 0 || cell.id.indexOf('section-24-row-02-item-05-cell-02') === 0) {
    return 74;
  }
  if (cell.id.indexOf('section-22-row-03-item-05-cell-02') === 0 || cell.id.indexOf('section-24-row-03-item-05-cell-02') === 0) {
    return 78;
  }
  if (relayIsRightEdgeTimeCell(cell.id)) {
    return 78;
  }
  if (cell.id.indexOf('section-19-row-01-item-01-cell-02') === 0 ||
    cell.id.indexOf('section-19-row-01-item-03-cell-02') === 0 ||
    cell.id.indexOf('section-19-row-01-item-03-cell-04') === 0 ||
    cell.id.indexOf('section-19-row-01-item-05-cell-02') === 0 ||
    cell.id.indexOf('section-19-row-01-item-05-cell-04') === 0) {
    return 76;
  }
  return relayValueCellMinWidth(cell.text);
}

function relayPrepareCellLayout(cell: RelayCellSpec): void {
  cell.labelMinWidth = relayLabelMinWidthForCell(cell);
  cell.valueMinWidth = relayValueMinWidthForCell(cell);
  cell.selectMinWidth = relaySelectMinWidthForCell(cell);
  cell.unitMinWidth = relayUnitMinWidthForCell(cell);
  cell.unitLeftMargin = relayUnitLeftMarginForCell(cell);
  cell.inputFontFamily = cell.text.indexOf(':') !== -1 ? 'sans-serif' : 'monospace';
}

function relayPrepareMonitorFieldLayout(field: RelayMonitorFieldSpec): void {
  field.resolvedBoxWidth = field.boxWidth;
  field.inputFontFamily = 'monospace';
}

function relayBindFieldSpecs(): void {
  RELAY_BOUND_MAIN_CELLS = [];
  RELAY_BOUND_MONITOR_FIELDS = [];
  for (let sectionIndex = 0; sectionIndex < RELAY_MAIN_SECTIONS.length; sectionIndex++) {
    let section = RELAY_MAIN_SECTIONS[sectionIndex];
    for (let rowIndex = 0; rowIndex < section.rows.length; rowIndex++) {
      let row = section.rows[rowIndex];
      for (let itemIndex = 0; itemIndex < row.items.length; itemIndex++) {
        let item = row.items[itemIndex];
        for (let cellIndex = 0; cellIndex < item.cells.length; cellIndex++) {
          let cell = item.cells[cellIndex];
          relayPrepareCellLayout(cell);
          if (cell.kind !== 'input' && cell.kind !== 'select') {
            continue;
          }
          let binding = relayFindFieldBinding(RELAY_FIELD_BINDINGS, cell.id);
          if (!binding) {
            continue;
          }
          cell.bindingIndex = binding.bindingIndex;
          cell.labelText = binding.labelText;
          cell.unitText = binding.unit;
          RELAY_BOUND_MAIN_CELLS[binding.bindingIndex] = cell;
        }
      }
    }
  }

  for (let sectionIndex = 0; sectionIndex < RELAY_MONITOR_SECTIONS.length; sectionIndex++) {
    let section = RELAY_MONITOR_SECTIONS[sectionIndex];
    for (let fieldIndex = 0; fieldIndex < section.fields.length; fieldIndex++) {
      let field = section.fields[fieldIndex];
      relayPrepareMonitorFieldLayout(field);
      let binding = relayFindFieldBinding(RELAY_FIELD_BINDINGS, field.id);
      if (!binding) {
        continue;
      }
      field.bindingIndex = binding.bindingIndex;
      RELAY_BOUND_MONITOR_FIELDS[binding.bindingIndex] = field;
    }
  }
}

function relayEnsureSchemaReady(): void {
  if (RELAY_SCHEMA_READY) {
    return;
  }
  RELAY_MAIN_SECTIONS = createRelayMainSections();
  RELAY_MONITOR_SECTIONS = createRelayMonitorSections();
  RELAY_FIELD_BINDINGS = buildRelayFieldBindings(RELAY_MAIN_SECTIONS, RELAY_MONITOR_SECTIONS);
  relayBindFieldSpecs();
  RELAY_SCHEMA_READY = true;
}

@Observed
class RelaySettingVM {
  headerMode: HeaderModeState = new HeaderModeState();
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定 01 区保护定值';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

@Component
struct QtStaticCheck {
  @Prop checked: boolean = false;
  @Prop label: string = '';
  @Prop boxSize: number = 30;
  @Prop fontSize: number = 16;
  @Prop fontColor: string = '#000000';
  @Prop fontFamilyName: string = 'STKaiti';

  build() {
    Row() {
      Stack() {
        Row()
          .width(this.boxSize)
          .height(this.boxSize)
          .backgroundColor('#FFFFFF')
          .border({ width: 1.4, color: '#000000' })
          .borderRadius(1);

        if (this.checked) {
          Text('√')
            .fontSize(this.boxSize * 0.82)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .width(this.boxSize)
            .height(this.boxSize)
            .textAlign(TextAlign.Center);
        }
      }
      .width(this.boxSize)
      .height(this.boxSize)
      .margin({ right: 6 });

      Text(this.label)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .fontFamily(this.fontFamilyName)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip });
    }
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start);
  }
}

@Entry
@Component
struct RelaySettingSet {
  @StorageLink('relay_setting_set_store') relaySettingStore: string = '';
  @StorageLink('relay_setting_profiles_store_v2') relaySettingProfilesStore: string = '';
  @State isLoading: boolean = true;
  @State vm: RelaySettingVM = new RelaySettingVM();
  @State uiScale: number = 1;
  @State modeInSelected: boolean = true;
  @State currentZoneCode: string = '01';
  @State currentProfileIndex: number = 0;
  @State currentDisplayValues: string[] = [];
  @State currentWidthCache: number[] = [];
  @State visibleSectionCount: number = 0;
  @State visibleMonitorSectionCount: number = 0;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayTitle: string = '请选择';
  @State selectOverlayOptions: string[] = [];
  @State selectOverlayValue: string = '';
  @State selectOverlayTargetBindingIndex: number = -1;
  @State submitWaitingDialogVisible: boolean = false;
  @State submitWaitingMessage: string = '';

  private currentProfileData: RelaySettingProfile = new RelaySettingProfile('01');
  private lastSyncedProfileData?: RelaySettingProfile;
  private loadToken: number = 0;
  private sectionRenderToken: number = 0;
  private relayRefreshTimer: number = -1;
  private relayRefreshGeneration: number = 0;
  private hasPendingLocalEdits: boolean = false;
  private loadStartedAt: number = 0;
  private readonly relayRefreshIntervalMs: number = 5000;
  private readonly relayRefreshReadDelayMs: number = 300;
  private readonly checkBoxSize: number = 28;
  private readonly noticeFontSize: number = 18;
  private readonly midFontSize: number = 18;
  private readonly titleFontSize: number = 20;
  private readonly sectionTitleFontSize: number = 18;
  private readonly fieldLabelFontSize: number = 18;
  private readonly fieldValueFontSize: number = 18;
  private readonly inputValueFontSize: number = 16;
  private readonly fieldUnitFontSize: number = 18;
  private readonly fieldMinFontSize: number = 15;
  private readonly inputBoxHeight: number = 34;
  private readonly sectionCardRadius: number = 3;
  private readonly fieldBoxRadius: number = 1;
  private readonly bottomButtonHeight: number = 46;
  private readonly bottomButtonRadius: number = 14;
  private readonly sectionRenderBatchSize: number = 4;
  private readonly monitorRenderBatchSize: number = 1;
  private readonly initialSectionRenderCount: number = 4;
  private readonly progressiveRenderStartDelayMs: number = 320;
  private readonly progressiveRenderBatchDelayMs: number = 48;
  private readonly zoneStoreDirectoryName: string = 'relay_setting';
  private readonly zoneMigrationFlagFileName: string = 'migration_01_20.done';
  private cachedRelaySettingNativeModule?: RelaySettingNativeModule;

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  private scopedValueKeyForZone(zoneCode: string, id: string): string {
    return zoneCode + '|' + id;
  }

  private findValueIndex(entries: RelayValueEntry[], key: string): number {
    for (let i = 0; i < entries.length; i++) {
      if (entries[i].key === key) {
        return i;
      }
    }
    return -1;
  }

  private deserializeValueEntries(raw: string): RelayValueEntry[] {
    let entries: RelayValueEntry[] = [];
    if (raw.length === 0) {
      return entries;
    }
    let lines = raw.split('\n');
    for (let i = 0; i < lines.length; i++) {
      let line = lines[i];
      if (line.length === 0) {
        continue;
      }
      let splitIndex = line.indexOf('\t');
      if (splitIndex < 0) {
        continue;
      }
      let key = line.substring(0, splitIndex);
      let encodedValue = line.substring(splitIndex + 1);
      let value = encodedValue;
      try {
        value = decodeURIComponent(encodedValue);
      } catch (e) {
        value = encodedValue;
      }
      entries.push(new RelayValueEntry(key, value));
    }
    return entries;
  }

  private bindingForFieldId(fieldId: string): RelayFieldBinding | undefined {
    return relayFindFieldBinding(RELAY_FIELD_BINDINGS, fieldId);
  }

  private currentProfile(): RelaySettingProfile {
    return this.currentProfileData;
  }

  private syncCurrentZoneState(zoneCode?: string): void {
    this.currentZoneCode = relayNormalizeSetZoneCode(zoneCode ? zoneCode : this.currentZoneCode);
    this.currentProfileIndex = relaySetZoneCodeToIndex(this.currentZoneCode);
    this.syncCurrentZoneTitle();
  }

  private syncCurrentZoneTitle(): void {
    this.vm.titleRight = '—整定 ' + this.currentZoneCode + ' 区保护定值';
  }

  private findLegacyValue(entries: RelayValueEntry[], key: string): string | undefined {
    let index = this.findValueIndex(entries, key);
    if (index === -1) {
      return undefined;
    }
    return entries[index].value;
  }

  private createDefaultCurrentZoneProfile(zoneCode: string = this.currentZoneCode): RelaySettingProfile {
    return createDefaultRelaySettingProfileForSetZone(zoneCode, RELAY_FIELD_BINDINGS);
  }

  private relaySettingStoreDirectoryPath(): string {
    let context = getContext(this) as AbilityFileContext;
    return `${context.filesDir}/${this.zoneStoreDirectoryName}`;
  }

  private ensureRelaySettingStoreDirectory(): string {
    let directoryPath = this.relaySettingStoreDirectoryPath();
    if (!fs.accessSync(directoryPath)) {
      fs.mkdirSync(directoryPath);
    }
    return directoryPath;
  }

  private relayZoneProfileFilePath(zoneCode: string): string {
    return `${this.ensureRelaySettingStoreDirectory()}/zone_${relayNormalizeSetZoneCode(zoneCode)}.json`;
  }

  private relayMigrationFlagFilePath(): string {
    return `${this.ensureRelaySettingStoreDirectory()}/${this.zoneMigrationFlagFileName}`;
  }

  private hasRelayMigrationFlag(): boolean {
    try {
      return fs.accessSync(this.relayMigrationFlagFilePath());
    } catch (error) {
      return false;
    }
  }

  private markRelayMigrationCompleted(): void {
    let flagFilePath = this.relayMigrationFlagFilePath();
    let file = fs.openSync(flagFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
    try {
      fs.writeSync(file.fd, 'done', { encoding: 'utf-8' });
    } finally {
      fs.closeSync(file);
    }
  }

  private normalizeProfileFromSource(
    sourceProfile: RelaySettingProfile | undefined,
    zoneCode: string
  ): RelaySettingProfile {
    let normalizedProfile = this.createDefaultCurrentZoneProfile(zoneCode);
    if (!sourceProfile) {
      return normalizedProfile;
    }
    for (let bindingIndex = 0; bindingIndex < RELAY_FIELD_BINDINGS.length; bindingIndex++) {
      let binding = RELAY_FIELD_BINDINGS[bindingIndex];
      let sourceField = relayReadProfileField(sourceProfile, binding);
      let normalizedField = relayParseStoredField(
        relayFormatStoredField(sourceField, binding),
        binding,
        relayDefaultStoredField(binding)
      );
      relayWriteProfileField(normalizedProfile, binding, normalizedField);
    }
    return normalizedProfile;
  }

  private loadRelayZoneProfileFromFile(zoneCode: string): RelaySettingProfile | undefined {
    let filePath = this.relayZoneProfileFilePath(zoneCode);
    if (!fs.accessSync(filePath)) {
      return undefined;
    }
    try {
      let raw = fs.readTextSync(filePath);
      if (raw.trim().length === 0) {
        return undefined;
      }
      let parsed = JSON.parse(raw) as RelaySettingProfile;
      return this.normalizeProfileFromSource(parsed, zoneCode);
    } catch (error) {
      return undefined;
    }
  }

  private saveRelayZoneProfile(zoneCode: string, profile: RelaySettingProfile): void {
    let normalizedZoneCode = relayNormalizeSetZoneCode(zoneCode);
    let normalizedProfile = this.normalizeProfileFromSource(profile, normalizedZoneCode);
    let filePath = this.relayZoneProfileFilePath(normalizedZoneCode);
    let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
    try {
      fs.writeSync(file.fd, JSON.stringify(normalizedProfile), { encoding: 'utf-8' });
    } finally {
      fs.closeSync(file);
    }
  }

  private loadLegacyZoneProfileFromSerializedStore(zoneCode: string): RelaySettingProfile | undefined {
    if (this.relaySettingProfilesStore.trim().length === 0) {
      return undefined;
    }
    try {
      let parsedStore = JSON.parse(this.relaySettingProfilesStore) as RelaySettingProfilesStore;
      if (!parsedStore || !Array.isArray(parsedStore.profiles)) {
        return undefined;
      }
      let legacyIndex = relaySetZoneCodeToIndex(zoneCode);
      let sourceProfile = parsedStore.profiles[legacyIndex] as RelaySettingProfile;
      if (!sourceProfile) {
        return undefined;
      }
      return this.normalizeProfileFromSource(sourceProfile, zoneCode);
    } catch (error) {
      return undefined;
    }
  }

  private loadLegacyZoneProfileFromLineStore(zoneCode: string): RelaySettingProfile | undefined {
    let entries = this.deserializeValueEntries(this.relaySettingStore);
    if (entries.length === 0) {
      return undefined;
    }
    let legacyZoneCode = relaySetZoneCodeToLegacyZoneCode(zoneCode);
    let profile = this.createDefaultCurrentZoneProfile(zoneCode);
    let hasMatchedEntry = false;

    for (let entryIndex = 0; entryIndex < entries.length; entryIndex++) {
      let entry = entries[entryIndex];
      let splitIndex = entry.key.indexOf('|');
      if (splitIndex <= 0 || splitIndex >= entry.key.length - 1) {
        continue;
      }
      if (entry.key.substring(0, splitIndex).trim() !== legacyZoneCode) {
        continue;
      }
      let binding = this.bindingForFieldId(entry.key.substring(splitIndex + 1));
      if (!binding) {
        continue;
      }
      let previousField = relayReadProfileField(profile, binding);
      let nextField = relayParseStoredField(
        entry.value,
        binding,
        previousField ? previousField : relayDefaultStoredField(binding)
      );
      relayWriteProfileField(profile, binding, nextField);
      hasMatchedEntry = true;
    }

    return hasMatchedEntry ? profile : undefined;
  }

  private loadLegacyZoneProfile(zoneCode: string): RelaySettingProfile | undefined {
    let profileFromStore = this.loadLegacyZoneProfileFromSerializedStore(zoneCode);
    if (profileFromStore) {
      return profileFromStore;
    }
    return this.loadLegacyZoneProfileFromLineStore(zoneCode);
  }

  private loadRelayZoneProfile(zoneCode: string): RelaySettingProfile {
    let normalizedZoneCode = relayNormalizeSetZoneCode(zoneCode);
    let profileFromFile = this.loadRelayZoneProfileFromFile(normalizedZoneCode);
    if (profileFromFile) {
      return profileFromFile;
    }

    let legacyProfile = this.loadLegacyZoneProfile(normalizedZoneCode);
    if (legacyProfile) {
      return legacyProfile;
    }

    return this.createDefaultCurrentZoneProfile(normalizedZoneCode);
  }

  private isValidRelaySettingNativeModule(module: RelaySettingNativeModule | undefined): boolean {
    return !!module && typeof module.getRelaySettingByZone === 'function';
  }

  private loadRelaySettingNativeModule(): RelaySettingNativeModule | undefined {
    if (this.isValidRelaySettingNativeModule(this.cachedRelaySettingNativeModule)) {
      return this.cachedRelaySettingNativeModule;
    }
    if (this.isValidRelaySettingNativeModule(relaySettingNativeModule)) {
      this.cachedRelaySettingNativeModule = relaySettingNativeModule;
      return this.cachedRelaySettingNativeModule;
    }

    let napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidRelaySettingNativeModule(napiModuleWithPath)) {
      this.cachedRelaySettingNativeModule = napiModuleWithPath;
      return this.cachedRelaySettingNativeModule;
    }

    let napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidRelaySettingNativeModule(napiModuleWithApp)) {
      this.cachedRelaySettingNativeModule = napiModuleWithApp;
      return this.cachedRelaySettingNativeModule;
    }

    let napiModule = requireNapi('entry');
    if (this.isValidRelaySettingNativeModule(napiModule)) {
      this.cachedRelaySettingNativeModule = napiModule;
      return this.cachedRelaySettingNativeModule;
    }

    return undefined;
  }

  private createProfileWithNativeRelayFields(
    zoneCode: string,
    baseProfile: RelaySettingProfile,
    fields: RelaySettingFieldEntry[]
  ): RelaySettingProfile {
    let nextProfile = this.normalizeProfileFromSource(baseProfile, zoneCode);
    for (let fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
      let fieldEntry = fields[fieldIndex];
      if (!fieldEntry || typeof fieldEntry.id !== 'string' || typeof fieldEntry.value !== 'string') {
        continue;
      }

      let binding = this.bindingForFieldId(fieldEntry.id);
      if (!binding || fieldEntry.value.length === 0) {
        continue;
      }

      let previousField = relayReadProfileField(nextProfile, binding);
      let nextField = relayParseStoredField(
        fieldEntry.value,
        binding,
        previousField ? previousField : relayDefaultStoredField(binding)
      );
      relayWriteProfileField(nextProfile, binding, nextField);
    }
    return nextProfile;
  }

  private loadNativeRelayZoneProfile(
    zoneCode: string,
    baseProfile: RelaySettingProfile
  ): RelaySettingProfile | undefined {
    try {
      let nativeModule = this.loadRelaySettingNativeModule();
      if (!nativeModule || typeof nativeModule.getRelaySettingByZone !== 'function') {
        return undefined;
      }

      let zoneValue = nativeModule.getRelaySettingByZone(Number(relayNormalizeSetZoneCode(zoneCode)));
      if (!isUsableRelaySettingZoneValue(zoneValue)) {
        return undefined;
      }

      let usableZoneValue = zoneValue as RelaySettingZoneValue;
      return this.createProfileWithNativeRelayFields(zoneCode, baseProfile, usableZoneValue.fields);
    } catch (error) {
      console.error(`load native relay setting failed: ${JSON.stringify(error)}`);
      return undefined;
    }
  }

  private buildLegacyMirrorStore(): RelaySettingProfilesStore {
    let mirrorStore = new RelaySettingProfilesStore();
    mirrorStore.profiles = [];

    for (let profileIndex = 0; profileIndex < RELAY_PROFILE_COUNT; profileIndex++) {
      let setZoneCode = relaySetZoneCodeForIndex(profileIndex);
      let setProfile = setZoneCode === this.currentZoneCode
        ? this.normalizeProfileFromSource(this.currentProfileData, setZoneCode)
        : this.loadRelayZoneProfileFromFile(setZoneCode);
      let normalizedSetProfile = setProfile ? setProfile : this.loadLegacyZoneProfile(setZoneCode);
      let finalSetProfile = normalizedSetProfile ? normalizedSetProfile : this.createDefaultCurrentZoneProfile(setZoneCode);
      let legacyProfile = createDefaultRelaySettingProfile(relayLegacyZoneCodeForIndex(profileIndex), RELAY_FIELD_BINDINGS);

      for (let bindingIndex = 0; bindingIndex < RELAY_FIELD_BINDINGS.length; bindingIndex++) {
        let binding = RELAY_FIELD_BINDINGS[bindingIndex];
        let sourceField = relayReadProfileField(finalSetProfile, binding);
        relayWriteProfileField(
          legacyProfile,
          binding,
          sourceField ? sourceField : relayDefaultStoredField(binding)
        );
      }

      mirrorStore.profiles.push(legacyProfile);
    }

    return mirrorStore;
  }

  private syncLegacyMirrorStore(): void {
    let mirrorStore = this.buildLegacyMirrorStore();
    let serializedStore = relaySerializeProfilesStore(mirrorStore);
    this.relaySettingProfilesStore = serializedStore;
    relayRememberProfilesStoreInSession(serializedStore, mirrorStore);
  }

  private migrateLegacyRelayProfilesIfNeeded(): void {
    if (this.hasRelayMigrationFlag()) {
      return;
    }

    this.ensureRelaySettingStoreDirectory();
    for (let profileIndex = 0; profileIndex < RELAY_PROFILE_COUNT; profileIndex++) {
      let setZoneCode = relaySetZoneCodeForIndex(profileIndex);
      let existingProfile = this.loadRelayZoneProfileFromFile(setZoneCode);
      let profileToSave = existingProfile ? existingProfile : this.loadRelayZoneProfile(setZoneCode);
      this.saveRelayZoneProfile(setZoneCode, profileToSave);
    }
    this.markRelayMigrationCompleted();
    this.syncLegacyMirrorStore();
  }

  private saveValueEntries(noticeText: string = ''): void {
    if (this.isLoading) {
      return;
    }
    this.saveRelayZoneProfile(this.currentZoneCode, this.currentProfileData);
    this.syncLegacyMirrorStore();
    this.vm.noticeText = noticeText;
  }

  private showFeedback(noticeText: string): void {
    this.vm.noticeText = noticeText;
  }

  private showSubmitWaiting(message: string): void {
    this.submitWaitingMessage = message;
    this.submitWaitingDialogVisible = true;
  }

  private closeSubmitWaiting(): void {
    this.submitWaitingDialogVisible = false;
    this.submitWaitingMessage = '';
  }

  private createRelaySettingWriteValue(): RelaySettingWriteZoneValue {
    let fields: RelaySettingWriteFieldEntry[] = [];
    let profile = this.currentProfile();
    for (let bindingIndex = 0; bindingIndex < RELAY_FIELD_BINDINGS.length; bindingIndex++) {
      let binding = RELAY_FIELD_BINDINGS[bindingIndex];
      let fallbackField = relayDefaultStoredField(binding);
      let sourceField = relayReadProfileField(profile, binding);
      let normalizedField = relayParseStoredField(
        relayFormatStoredField(sourceField, binding),
        binding,
        sourceField ? sourceField : fallbackField
      );
      fields.push({
        id: binding.fieldId,
        textValue: normalizedField.textValue,
        numberValue: normalizedField.numberValue,
        enumValue: normalizedField.enumValue
      });
    }

    return {
      zoneCode: Number(relayNormalizeSetZoneCode(this.currentZoneCode)),
      fields: fields
    };
  }

  private writeNativeRelaySettingByZone(): boolean {
    try {
      let nativeModule = this.loadRelaySettingNativeModule();
      if (!nativeModule || typeof nativeModule.updateRelaySettingByZone !== 'function') {
        return false;
      }
      return !!nativeModule.updateRelaySettingByZone(this.createRelaySettingWriteValue());
    } catch (error) {
      console.error(`write native relay setting failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private submitCurrentData(): void {
    if (this.isLoading) {
      return;
    }

    this.closeSelectOverlay();
    this.closeSubmitWaiting();

    try {
      this.saveValueEntries();
    } catch (error) {
      this.showFeedback('提交失败');
      return;
    }

    if (!this.writeNativeRelaySettingByZone()) {
      this.showFeedback('提交失败，请检查当前区保护定值写入。');
      return;
    }

    this.syncLastSyncedProfile(this.currentProfileData);
    this.updatePendingLocalEditState();
    this.startRelayAutoRefreshTimer();
    this.showSubmitWaiting(`当前${this.currentZoneCode}区保护定值已写入结构体，等待装置回应...`);
  }

  private resetCurrentZoneValues(): void {
    if (this.isLoading) {
      return;
    }
    this.currentProfileData = this.createDefaultCurrentZoneProfile(this.currentZoneCode);
    this.rebuildCurrentZoneCache();
    this.saveValueEntries();
    this.syncLastSyncedProfile(this.currentProfileData);
    this.updatePendingLocalEditState();
    this.startRelayAutoRefreshTimer();
  }

  private sameStoredField(left: RelayStoredField | undefined, right: RelayStoredField): boolean {
    return !!left &&
      left.valueType === right.valueType &&
      left.textValue === right.textValue &&
      left.numberValue === right.numberValue &&
      left.enumValue === right.enumValue;
  }

  private profilesMatch(
    leftProfile: RelaySettingProfile | undefined,
    rightProfile: RelaySettingProfile | undefined
  ): boolean {
    if (!leftProfile && !rightProfile) {
      return true;
    }
    if (!leftProfile || !rightProfile) {
      return false;
    }

    for (let bindingIndex = 0; bindingIndex < RELAY_FIELD_BINDINGS.length; bindingIndex++) {
      let binding = RELAY_FIELD_BINDINGS[bindingIndex];
      let leftField = relayReadProfileField(leftProfile, binding);
      let rightField = relayReadProfileField(rightProfile, binding);
      let normalizedLeft = leftField ? leftField : relayDefaultStoredField(binding);
      let normalizedRight = rightField ? rightField : relayDefaultStoredField(binding);
      if (!this.sameStoredField(normalizedLeft, normalizedRight) ||
        !this.sameStoredField(normalizedRight, normalizedLeft)) {
        return false;
      }
    }

    return true;
  }

  private syncLastSyncedProfile(profile?: RelaySettingProfile): void {
    if (!profile) {
      this.lastSyncedProfileData = undefined;
      return;
    }
    this.lastSyncedProfileData = this.normalizeProfileFromSource(profile, this.currentZoneCode);
  }

  private updatePendingLocalEditState(): void {
    this.hasPendingLocalEdits = !this.profilesMatch(this.currentProfileData, this.lastSyncedProfileData);
  }

  private shouldPauseRelayAutoRefresh(): boolean {
    return this.isLoading ||
      this.selectOverlayVisible ||
      this.submitWaitingDialogVisible ||
      this.hasPendingLocalEdits;
  }

  private bindingAtIndex(bindingIndex: number): RelayFieldBinding | undefined {
    if (bindingIndex < 0 || bindingIndex >= RELAY_FIELD_BINDINGS.length) {
      return undefined;
    }
    return RELAY_FIELD_BINDINGS[bindingIndex];
  }

  private displayValueAtBindingIndex(bindingIndex: number, fallbackValue: string): string {
    if (bindingIndex < 0 || bindingIndex >= this.currentDisplayValues.length) {
      return fallbackValue;
    }
    return this.currentDisplayValues[bindingIndex];
  }

  private widthAtBindingIndex(bindingIndex: number, fallbackWidth: number): number {
    if (bindingIndex < 0 || bindingIndex >= this.currentWidthCache.length) {
      return fallbackWidth;
    }
    let currentWidth = this.currentWidthCache[bindingIndex];
    return currentWidth > fallbackWidth ? currentWidth : fallbackWidth;
  }

  private cloneStringArray(source: string[]): string[] {
    let target: string[] = [];
    for (let i = 0; i < source.length; i++) {
      target.push(source[i]);
    }
    return target;
  }

  private cloneNumberArray(source: number[]): number[] {
    let target: number[] = [];
    for (let i = 0; i < source.length; i++) {
      target.push(source[i]);
    }
    return target;
  }

  private resolveBindingWidth(bindingIndex: number, displayValue: string): number {
    let cell = RELAY_BOUND_MAIN_CELLS[bindingIndex];
    if (cell && cell.kind === 'select') {
      let defaultWidth = cell.selectMinWidth;
      let dynamicWidth = this.selectCellMinWidth(displayValue);
      return dynamicWidth > defaultWidth ? dynamicWidth : defaultWidth;
    }

    let field = RELAY_BOUND_MONITOR_FIELDS[bindingIndex];
    if (!field) {
      return 0;
    }

    let minWidth = field.kind === 'select'
      ? this.selectCellMinWidth(displayValue)
      : this.valueCellMinWidth(displayValue);
    return field.resolvedBoxWidth > minWidth ? field.resolvedBoxWidth : minWidth;
  }

  private rebuildCurrentZoneCache(): void {
    let nextDisplayValues: string[] = [];
    let nextWidthCache: number[] = [];
    let profile = this.currentProfile();

    for (let bindingIndex = 0; bindingIndex < RELAY_FIELD_BINDINGS.length; bindingIndex++) {
      let binding = RELAY_FIELD_BINDINGS[bindingIndex];
      let displayValue = profile
        ? relayFormatStoredField(relayReadProfileField(profile, binding), binding)
        : binding.defaultText;
      nextDisplayValues.push(displayValue);
      nextWidthCache.push(this.resolveBindingWidth(bindingIndex, displayValue));
    }

    this.currentDisplayValues = nextDisplayValues;
    this.currentWidthCache = nextWidthCache;
  }

  private requestCurrentZoneRelaySetting(): boolean {
    try {
      let nativeModule = this.loadRelaySettingNativeModule();
      if (!nativeModule || typeof nativeModule.requestRelaySettingByZone !== 'function') {
        return false;
      }
      return !!nativeModule.requestRelaySettingByZone(Number(relayNormalizeSetZoneCode(this.currentZoneCode)));
    } catch (error) {
      console.error(`request relay setting failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private applyCurrentZoneNativeRefresh(): void {
    if (this.shouldPauseRelayAutoRefresh()) {
      return;
    }

    let baseProfile = this.lastSyncedProfileData
      ? this.normalizeProfileFromSource(this.lastSyncedProfileData, this.currentZoneCode)
      : this.normalizeProfileFromSource(this.currentProfileData, this.currentZoneCode);
    let nativeProfile = this.loadNativeRelayZoneProfile(this.currentZoneCode, baseProfile);
    if (!nativeProfile) {
      return;
    }

    let normalizedProfile = this.normalizeProfileFromSource(nativeProfile, this.currentZoneCode);
    if (this.profilesMatch(this.currentProfileData, normalizedProfile) &&
      this.profilesMatch(this.lastSyncedProfileData, normalizedProfile)) {
      return;
    }

    this.currentProfileData = normalizedProfile;
    this.syncLastSyncedProfile(normalizedProfile);
    this.rebuildCurrentZoneCache();
    this.updatePendingLocalEditState();
  }

  private scheduleRelayAutoRefresh(refreshGeneration: number): void {
    if (refreshGeneration !== this.relayRefreshGeneration) {
      return;
    }
    if (this.relayRefreshTimer >= 0) {
      clearTimeout(this.relayRefreshTimer);
      this.relayRefreshTimer = -1;
    }

    this.relayRefreshTimer = setTimeout(() => {
      this.relayRefreshTimer = -1;
      if (refreshGeneration !== this.relayRefreshGeneration) {
        return;
      }

      if (this.shouldPauseRelayAutoRefresh()) {
        this.scheduleRelayAutoRefresh(refreshGeneration);
        return;
      }

      this.requestCurrentZoneRelaySetting();
      this.relayRefreshTimer = setTimeout(() => {
        this.relayRefreshTimer = -1;
        if (refreshGeneration !== this.relayRefreshGeneration) {
          return;
        }
        if (!this.shouldPauseRelayAutoRefresh()) {
          this.applyCurrentZoneNativeRefresh();
        }
        this.scheduleRelayAutoRefresh(refreshGeneration);
      }, this.relayRefreshReadDelayMs);
    }, this.relayRefreshIntervalMs);
  }

  private startRelayAutoRefreshTimer(): void {
    this.stopRelayAutoRefreshTimer();
    this.scheduleRelayAutoRefresh(this.relayRefreshGeneration);
  }

  private stopRelayAutoRefreshTimer(): void {
    this.relayRefreshGeneration++;
    if (this.relayRefreshTimer >= 0) {
      clearTimeout(this.relayRefreshTimer);
      this.relayRefreshTimer = -1;
    }
  }

  private updateBindingCache(bindingIndex: number, displayValue: string): void {
    let nextDisplayValues = this.cloneStringArray(this.currentDisplayValues);
    let nextWidthCache = this.cloneNumberArray(this.currentWidthCache);

    while (nextDisplayValues.length <= bindingIndex) {
      nextDisplayValues.push('');
    }
    while (nextWidthCache.length <= bindingIndex) {
      nextWidthCache.push(0);
    }

    nextDisplayValues[bindingIndex] = displayValue;
    nextWidthCache[bindingIndex] = this.resolveBindingWidth(bindingIndex, displayValue);
    this.currentDisplayValues = nextDisplayValues;
    this.currentWidthCache = nextWidthCache;
  }

  private writeBindingValue(bindingIndex: number, value: string): void {
    if (this.isLoading) {
      return;
    }
    let binding = this.bindingAtIndex(bindingIndex);
    let profile = this.currentProfile();
    if (!binding || !profile) {
      return;
    }

    let currentField = relayReadProfileField(profile, binding);
    let nextField = relayParseStoredField(
      value,
      binding,
      currentField ? currentField : relayDefaultStoredField(binding)
    );
    if (this.sameStoredField(currentField, nextField)) {
      return;
    }

    relayWriteProfileField(profile, binding, nextField);
    this.updateBindingCache(bindingIndex, relayFormatStoredField(nextField, binding));
    this.updatePendingLocalEditState();
    this.vm.noticeText = '';
  }

  private stripUnitSuffix(value: string, unit: string): string {
    let next = value.trim();
    if (unit.length === 0 || next.length === 0) {
      return next;
    }
    let spacedSuffix = ' ' + unit;
    if (next.endsWith(spacedSuffix)) {
      return next.substring(0, next.length - spacedSuffix.length).trim();
    }
    if (next.endsWith(unit)) {
      return next.substring(0, next.length - unit.length).trim();
    }
    return next;
  }

  private normalizeCellInputValue(cell: RelayCellSpec, value: string): string {
    if (cell.kind !== 'input') {
      return value;
    }
    return this.stripUnitSuffix(value, cell.unitText);
  }

  private normalizeMonitorInputValue(field: RelayMonitorFieldSpec, value: string): string {
    if (field.kind !== 'input') {
      return value;
    }
    return this.stripUnitSuffix(value, field.unit);
  }

  private getCellValue(cell: RelayCellSpec): string {
    return this.displayValueAtBindingIndex(cell.bindingIndex, cell.text);
  }

  private setCellValue(cell: RelayCellSpec, value: string): void {
    this.writeBindingValue(cell.bindingIndex, this.normalizeCellInputValue(cell, value));
  }

  private getMonitorFieldValue(field: RelayMonitorFieldSpec): string {
    return this.displayValueAtBindingIndex(field.bindingIndex, field.value);
  }

  private setMonitorFieldValue(field: RelayMonitorFieldSpec, value: string): void {
    this.writeBindingValue(field.bindingIndex, this.normalizeMonitorInputValue(field, value));
  }

  private appendUniqueOption(options: string[], option: string): void {
    if (option.length === 0) {
      return;
    }
    for (let i = 0; i < options.length; i++) {
      if (options[i] === option) {
        return;
      }
    }
    options.push(option);
  }

  private defaultSelectOptions(defaultValue: string): string[] {
    return relayDefaultSelectOptions(defaultValue);
  }

  private selectOptionsForValue(defaultValue: string, currentValue: string): string[] {
    let options = this.defaultSelectOptions(defaultValue);
    this.appendUniqueOption(options, currentValue);
    return options;
  }

  private openCellSelect(cell: RelayCellSpec): void {
    let currentValue = this.getCellValue(cell);
    this.selectOverlayTargetBindingIndex = cell.bindingIndex;
    this.selectOverlayTitle = cell.labelText;
    this.selectOverlayOptions = this.selectOptionsForValue(cell.text, currentValue);
    this.selectOverlayValue = currentValue;
    this.selectOverlayVisible = true;
  }

  private openMonitorSelect(field: RelayMonitorFieldSpec): void {
    let currentValue = this.getMonitorFieldValue(field);
    this.selectOverlayTargetBindingIndex = field.bindingIndex;
    this.selectOverlayTitle = field.label;
    this.selectOverlayOptions = this.selectOptionsForValue(field.value, currentValue);
    this.selectOverlayValue = currentValue;
    this.selectOverlayVisible = true;
  }

  private closeSelectOverlay(): void {
    this.selectOverlayVisible = false;
    this.selectOverlayTargetBindingIndex = -1;
  }

  private applySelectOverlayValue(value: string): void {
    this.writeBindingValue(this.selectOverlayTargetBindingIndex, value);
    this.selectOverlayValue = value;
    this.closeSelectOverlay();
  }

  private labelCellMinWidth(text: string): number {
    if (text.length >= 18) {
      return 248;
    }
    if (text.length >= 14) {
      return 210;
    }
    if (text.length >= 10) {
      return 178;
    }
    if (text.length >= 8) {
      return 158;
    }
    if (text.length >= 6) {
      return 126;
    }
    if (text.length >= 4) {
      return 104;
    }
    return 76;
  }

  private isRightEdgeTimeCell(cellId: string): boolean {
    return cellId.indexOf('section-10-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-11-row-02-item-05-cell-') === 0 ||
      cellId.indexOf('section-12-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-13-row-03-item-05-cell-') === 0 ||
      cellId.indexOf('section-14-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-15-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-16-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-17-row-02-item-05-cell-') === 0 ||
      cellId.indexOf('section-18-row-03-item-03-cell-') === 0 ||
      cellId.indexOf('section-21-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-22-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-23-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-24-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-25-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-26-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-27-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-28-row-01-item-07-cell-') === 0;
  }

  private isRightEdgeWideUnitCell(cellId: string): boolean {
    return cellId.indexOf('section-20-row-03-item-03-cell-') === 0 ||
      cellId.indexOf('section-20-row-03-item-05-cell-') === 0 ||
      cellId.indexOf('section-22-row-02-item-05-cell-') === 0 ||
      cellId.indexOf('section-22-row-03-item-05-cell-') === 0 ||
      cellId.indexOf('section-24-row-02-item-05-cell-') === 0 ||
      cellId.indexOf('section-24-row-03-item-05-cell-') === 0;
  }

  private unitMinWidthForCell(cell: RelayCellSpec): number {
    if (this.isRightEdgeTimeCell(cell.id)) {
      return cell.text.length >= 2 ? 12 : 10;
    }
    if (this.isRightEdgeWideUnitCell(cell.id)) {
      return cell.text.length >= 4 ? 28 : 20;
    }
    if (cell.id.indexOf('section-01-row-') === 0) {
      return 28;
    }
    if (cell.text.length >= 4) {
      return 30;
    }
    if (cell.text.length >= 3) {
      return 26;
    }
    if (cell.text.length >= 2) {
      return 20;
    }
    return 16;
  }

  private unitLeftMarginForCell(cell: RelayCellSpec): number {
    if (cell.id.indexOf('section-01-row-01-item-06-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-01-item-10-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-03-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-07-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-11-cell-01') === 0) {
      return 18;
    }
    if (cell.id.indexOf('section-05-row-01-item-05-cell-03') === 0 ||
      cell.id.indexOf('section-05-row-01-item-07-cell-03') === 0 ||
      cell.id.indexOf('section-06-row-01-item-05-cell-03') === 0 ||
      cell.id.indexOf('section-06-row-01-item-07-cell-03') === 0) {
      return 0;
    }
    if (cell.id.indexOf('section-01-row-') === 0) {
      return 8;
    }
    if (this.isRightEdgeTimeCell(cell.id)) {
      return 0;
    }
    if (this.isRightEdgeWideUnitCell(cell.id)) {
      return 1;
    }
    return 2;
  }

  private selectCellMinWidth(text: string): number {
    if (text.length >= 16) {
      return 204;
    }
    if (text.length >= 12) {
      return 176;
    }
    if (text.length >= 8) {
      return 144;
    }
    if (text.length >= 5) {
      return 112;
    }
    if (text.length >= 3) {
      return 82;
    }
    return 64;
  }

  private valueCellMinWidth(text: string): number {
    if (text.length >= 18) {
      return 228;
    }
    if (text.length >= 12) {
      return 188;
    }
    if (text.length >= 9) {
      return 144;
    }
    if (text.length >= 6) {
      return 116;
    }
    return 92;
  }

  private labelMinWidthForCell(cell: RelayCellSpec): number {
    if (cell.id.indexOf('section-01-row-01-item-04-cell-01') === 0) {
      return 164;
    }
    if (cell.id.indexOf('section-01-row-01-item-08-cell-01') === 0) {
      return 154;
    }
    if (cell.id.indexOf('section-05-row-01-item-05-cell-01') === 0 || cell.id.indexOf('section-06-row-01-item-05-cell-01') === 0) {
      return 82;
    }
    if (cell.id.indexOf('section-05-row-01-item-07-cell-01') === 0 || cell.id.indexOf('section-06-row-01-item-07-cell-01') === 0) {
      return 110;
    }
    if (cell.id.indexOf('section-07-row-01-item-01-cell-01') === 0) {
      return 124;
    }
    if (cell.id.indexOf('section-07-row-01-item-03-cell-01') === 0) {
      return 152;
    }
    if (cell.id.indexOf('section-11-row-02-item-05-cell-01') === 0 || cell.id.indexOf('section-17-row-02-item-05-cell-01') === 0) {
      return 122;
    }
    if (cell.id.indexOf('section-13-row-03-item-05-cell-01') === 0) {
      return 90;
    }
    if (cell.id.indexOf('section-21-row-02-item-03-cell-01') === 0) {
      return 96;
    }
    if (cell.id.indexOf('section-20-row-03-item-03-cell-01') === 0 || cell.id.indexOf('section-20-row-03-item-05-cell-01') === 0) {
      return 126;
    }
    if (cell.id.indexOf('section-22-row-02-item-05-cell-01') === 0 || cell.id.indexOf('section-24-row-02-item-05-cell-01') === 0) {
      return 128;
    }
    if (cell.id.indexOf('section-22-row-03-item-05-cell-01') === 0 || cell.id.indexOf('section-24-row-03-item-05-cell-01') === 0) {
      return 118;
    }
    if (this.isRightEdgeTimeCell(cell.id)) {
      return 86;
    }
    if (cell.id.indexOf('section-19-row-01-item-03-cell-01') === 0 || cell.id.indexOf('section-19-row-01-item-05-cell-01') === 0) {
      return 98;
    }
    if (cell.id.indexOf('section-19-row-02-') === 0) {
      return cell.text.length >= 8 ? 104 : 88;
    }
    if (cell.id.indexOf('section-19-row-03-item-01-cell-01') === 0) {
      return 150;
    }
    if (cell.id.indexOf('section-19-row-03-item-03-cell-01') === 0) {
      return 192;
    }
    if (cell.id.indexOf('section-19-row-03-') === 0) {
      return 116;
    }
    return this.labelCellMinWidth(cell.text);
  }

  private selectMinWidthForCell(cell: RelayCellSpec): number {
    if (cell.id.indexOf('section-19-row-02-') === 0 || cell.id.indexOf('section-19-row-03-') === 0) {
      return 64;
    }
    return this.selectCellMinWidth(cell.text);
  }

  private valueMinWidthForCell(cell: RelayCellSpec): number {
    if (cell.id.indexOf('section-01-row-01-item-05-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-01-item-09-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-06-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-10-cell-01') === 0) {
      return 76;
    }
    if (cell.id.indexOf('section-01-row-02-item-02-cell-01') === 0) {
      return 80;
    }
    if (cell.id.indexOf('section-07-row-01-item-01-cell-03') === 0 || cell.id.indexOf('section-07-row-01-item-03-cell-03') === 0) {
      return 72;
    }
    if (cell.id.indexOf('section-05-row-01-item-05-cell-02') === 0 ||
      cell.id.indexOf('section-05-row-01-item-07-cell-02') === 0 ||
      cell.id.indexOf('section-06-row-01-item-05-cell-02') === 0 ||
      cell.id.indexOf('section-06-row-01-item-07-cell-02') === 0) {
      return 74;
    }
    if (cell.id.indexOf('section-11-row-02-item-05-cell-02') === 0 || cell.id.indexOf('section-17-row-02-item-05-cell-02') === 0) {
      return 74;
    }
    if (cell.id.indexOf('section-13-row-03-item-05-cell-02') === 0) {
      return 72;
    }
    if (cell.id.indexOf('section-20-row-03-item-03-cell-02') === 0 || cell.id.indexOf('section-20-row-03-item-05-cell-02') === 0) {
      return 78;
    }
    if (cell.id.indexOf('section-21-row-02-item-03-cell-02') === 0) {
      return 82;
    }
    if (cell.id.indexOf('section-22-row-02-item-05-cell-02') === 0 || cell.id.indexOf('section-24-row-02-item-05-cell-02') === 0) {
      return 74;
    }
    if (cell.id.indexOf('section-22-row-03-item-05-cell-02') === 0 || cell.id.indexOf('section-24-row-03-item-05-cell-02') === 0) {
      return 78;
    }
    if (this.isRightEdgeTimeCell(cell.id)) {
      return 78;
    }
    if (cell.id.indexOf('section-19-row-01-item-01-cell-02') === 0 ||
      cell.id.indexOf('section-19-row-01-item-03-cell-02') === 0 ||
      cell.id.indexOf('section-19-row-01-item-03-cell-04') === 0 ||
      cell.id.indexOf('section-19-row-01-item-05-cell-02') === 0 ||
      cell.id.indexOf('section-19-row-01-item-05-cell-04') === 0) {
      return 76;
    }
    return this.valueCellMinWidth(cell.text);
  }

  private monitorFieldBoxWidth(field: RelayMonitorFieldSpec): number {
    return this.widthAtBindingIndex(field.bindingIndex, field.resolvedBoxWidth);
  }

  private selectBoxMinWidth(cell: RelayCellSpec): number {
    return this.widthAtBindingIndex(cell.bindingIndex, cell.selectMinWidth);
  }

  private scheduleRemainingSectionRender(loadToken: number): void {
    this.sectionRenderToken++;
    let currentRenderToken = this.sectionRenderToken;

    let renderNextBatch = () => {
      if (loadToken !== this.loadToken || currentRenderToken !== this.sectionRenderToken) {
        return;
      }
      if (this.visibleSectionCount >= RELAY_MAIN_SECTIONS.length &&
        this.visibleMonitorSectionCount >= RELAY_MONITOR_SECTIONS.length) {
        console.info(`RelaySettingSet 全部分组渲染完成，区号=${this.currentZoneCode}，耗时=${Date.now() - this.loadStartedAt}ms`);
        return;
      }

      if (this.visibleSectionCount < RELAY_MAIN_SECTIONS.length) {
        this.visibleSectionCount = Math.min(
          this.visibleSectionCount + this.sectionRenderBatchSize,
          RELAY_MAIN_SECTIONS.length
        );
      } else {
        this.visibleMonitorSectionCount = Math.min(
          this.visibleMonitorSectionCount + this.monitorRenderBatchSize,
          RELAY_MONITOR_SECTIONS.length
        );
      }
      setTimeout(() => {
        renderNextBatch();
      }, this.progressiveRenderBatchDelayMs);
    };

    setTimeout(() => {
      renderNextBatch();
    }, this.progressiveRenderStartDelayMs);
  }

  private prepareCurrentZone(loadToken: number): void {
    if (loadToken !== this.loadToken) {
      return;
    }

    try {
      relayEnsureSchemaReady();
      if (loadToken !== this.loadToken) {
        return;
      }
      let profileFromFile = this.loadRelayZoneProfileFromFile(this.currentZoneCode);
      let baseProfile = profileFromFile ? profileFromFile : this.loadRelayZoneProfile(this.currentZoneCode);
      let nativeProfile = this.loadNativeRelayZoneProfile(this.currentZoneCode, baseProfile);
      this.currentProfileData = nativeProfile ? nativeProfile : baseProfile;
      if (!profileFromFile || nativeProfile) {
        this.saveRelayZoneProfile(this.currentZoneCode, this.currentProfileData);
      }
      this.rebuildCurrentZoneCache();
      this.syncLastSyncedProfile(this.currentProfileData);
      this.updatePendingLocalEditState();
      this.visibleSectionCount = Math.min(this.initialSectionRenderCount, RELAY_MAIN_SECTIONS.length);
      this.visibleMonitorSectionCount = 0;
      console.info(`RelaySettingSet 首批分组就绪，区号=${this.currentZoneCode}，耗时=${Date.now() - this.loadStartedAt}ms`);
    } catch (e) {
      if (loadToken !== this.loadToken) {
        return;
      }
      this.currentProfileData = this.createDefaultCurrentZoneProfile(this.currentZoneCode);
      this.rebuildCurrentZoneCache();
      this.syncLastSyncedProfile(this.currentProfileData);
      this.updatePendingLocalEditState();
      this.visibleSectionCount = Math.min(this.initialSectionRenderCount, RELAY_MAIN_SECTIONS.length);
      this.visibleMonitorSectionCount = 0;
      this.vm.noticeText = '';
    } finally {
      if (loadToken === this.loadToken) {
        this.isLoading = false;
        this.scheduleRemainingSectionRender(loadToken);
        this.startRelayAutoRefreshTimer();
      }
    }
  }
  aboutToAppear(): void {
    this.stopRelayAutoRefreshTimer();
    this.loadToken++;
    this.sectionRenderToken++;
    this.loadStartedAt = Date.now();
    this.modeInSelected = this.vm.headerMode.inMode.checked;
    this.selectOverlayVisible = false;
    this.selectOverlayTargetBindingIndex = -1;
    this.submitWaitingDialogVisible = false;
    this.submitWaitingMessage = '';
    this.vm.noticeText = '';
    this.isLoading = true;
    this.hasPendingLocalEdits = false;
    this.lastSyncedProfileData = undefined;
    this.currentDisplayValues = [];
    this.currentWidthCache = [];
    this.visibleSectionCount = 0;
    this.visibleMonitorSectionCount = 0;
    this.syncCurrentZoneState('01');
    try {
      let d = display.getDefaultDisplaySync();
      let sx = d.width / 1024;
      let sy = d.height / 600;
      let val = Math.min(sx, sy);
      this.uiScale = val > 0 ? val : 1;
    } catch (e) {
      this.uiScale = 1;
    }

    try {
      let params = router.getParams() as RouterParams;
      this.syncCurrentZoneState(params.zoneCode?.trim());
    } catch (e) {
      this.syncCurrentZoneState();
    }

    let currentLoadToken = this.loadToken;
    setTimeout(() => {
      this.prepareCurrentZone(currentLoadToken);
    }, 0);
  }

  aboutToDisappear(): void {
    this.stopRelayAutoRefreshTimer();
    this.loadToken++;
    this.sectionRenderToken++;
    this.selectOverlayVisible = false;
    this.selectOverlayTargetBindingIndex = -1;
    this.submitWaitingDialogVisible = false;
    this.submitWaitingMessage = '';
  }

  private setMode(isIn: boolean): void {
    this.modeInSelected = isIn;
    this.vm.headerMode.inMode.checked = isIn;
    this.vm.headerMode.outMode.checked = !isIn;
  }

  build() {
    Stack() {
      Column() {
        this.HeaderBar();

        if (this.isLoading) {
          this.LoadingBody();
        } else {
          List() {
            ForEach(RELAY_MAIN_SECTIONS.slice(0, this.visibleSectionCount), (section: RelaySectionSpec) => {
              ListItem() {
                this.SectionCard(section);
              }
            }, (section: RelaySectionSpec) => section.id)

            if (this.visibleMonitorSectionCount > 0) {
              ListItem() {
                this.MonitorSections();
              }
            }
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ left: this.s(10), right: this.s(16), top: this.s(5), bottom: this.s(7) })
          .backgroundColor('#FFFFFF');
        }

        this.BottomBar();
      }

      if (this.selectOverlayVisible && !this.isLoading) {
        this.SelectOverlay();
      }

      if (this.submitWaitingDialogVisible) {
        this.SubmitWaitingOverlay();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
  @Builder
  LoadingBody() {
    Column() {
      Blank().layoutWeight(1);

      Text('加载中...')
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#444444')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .margin({ bottom: this.s(6) });

      Text('正在准备当前区定值')
        .fontSize(this.s(this.inputValueFontSize))
        .fontColor('#666666')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      Blank().layoutWeight(1);
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: this.s(10), right: this.s(10), top: this.s(8), bottom: this.s(8) })
    .backgroundColor('#FFFFFF');
  }
  @Builder
  HeaderBar() {
    Row() {
      Text(this.vm.noticeText)
        .layoutWeight(200)
        .minFontSize(12)
        .maxLines(1)
        .fontSize(this.s(this.noticeFontSize))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(40);

      Text(this.vm.titleLeft)
        .layoutWeight(120)
        .minFontSize(14)
        .maxLines(1)
        .fontSize(this.s(this.titleFontSize))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .textOverflow({ overflow: TextOverflow.Clip })
        .textAlign(TextAlign.End);

      Text(this.vm.titleRight)
        .layoutWeight(240)
        .minFontSize(14)
        .maxLines(1)
        .fontSize(this.s(this.titleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textOverflow({ overflow: TextOverflow.Clip })
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(40);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(24))
          .height(this.s(24));
      }
      .layoutWeight(80)
      .height(this.s(36))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(20))
          .height(this.s(20));
      }
      .layoutWeight(80)
      .height(this.s(36))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .onClick(() => {
        router.back();
      });
    }
    .width('100%')
    .height(this.s(70))
    .padding({ left: this.s(10), right: this.s(10), top: this.s(8), bottom: this.s(8) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }

  @Builder
  SectionCard(section: RelaySectionSpec) {
    Column() {
      Text(section.title)
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .width('100%')
        .padding({ left: this.s(14), right: this.s(14) })
        .margin({ bottom: this.s(4) });

      ForEach(section.rows, (row: RelayRowSpec, rowIndex: number) => {
        this.SectionRow(row);
        if (rowIndex !== section.rows.length - 1) {
          Blank().height(this.s(3));
        }
      }, (row: RelayRowSpec) => row.id)
    }
    .width('100%')
    .padding({ top: this.s(6), bottom: this.s(6) })
    .margin({ bottom: this.s(6) })
    .backgroundColor('#FBFBFB')
    .border({ width: 1, color: '#DCDCDC' })
    .borderRadius(this.s(this.sectionCardRadius));
  }

  @Builder
  SectionRow(row: RelayRowSpec) {
    Row() {
      if (row.leftMargin > 0) {
        Blank().width(this.s(row.leftMargin));
      }

      ForEach(row.items, (item: RelayRowItemSpec) => {
        this.RowItem(item);
      }, (item: RelayRowItemSpec) => item.id)

      if (row.rightMargin > 0) {
        Blank().width(this.s(row.rightMargin));
      }
    }
    .width('100%')
    .constraintSize({ minHeight: this.s(34) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  RowItem(item: RelayRowItemSpec) {
    if (item.kind === 'spacer') {
      Blank().layoutWeight(item.weight);
    } else {
      Row() {
        ForEach(item.cells, (cell: RelayCellSpec) => {
          this.RowCell(cell);
        }, (cell: RelayCellSpec) => cell.id)
      }
      .layoutWeight(item.weight)
      .alignItems(VerticalAlign.Center);
    }
  }

  @Builder
  RowCell(cell: RelayCellSpec) {
    if (cell.kind === 'spacer') {
      Blank().layoutWeight(cell.weight);
    } else if (cell.kind === 'label') {
      Text(cell.text)
        .layoutWeight(cell.weight)
        .constraintSize({ minWidth: this.s(cell.labelMinWidth) })
        .fontSize(this.s(this.fieldLabelFontSize))
        .minFontSize(this.s(this.fieldMinFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip })
        .textAlign(TextAlign.Start);
    } else if (cell.kind === 'unit') {
      Text(cell.text)
        .layoutWeight(cell.weight)
        .constraintSize({ minWidth: this.s(cell.unitMinWidth) })
        .fontSize(this.s(this.fieldUnitFontSize))
        .fontColor('#444444')
        .fontFamily('STKaiti')
        .maxLines(1)
        .margin({ left: this.s(cell.unitLeftMargin) })
        .textAlign(TextAlign.Start);
    } else if (cell.kind === 'select') {
      Row() {
        Text(this.getCellValue(cell))
          .layoutWeight(1)
          .fontSize(this.s(this.inputValueFontSize))
          .fontColor('#111111')
          .fontFamily('STKaiti')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip })
          .textAlign(TextAlign.Start);

        Image($r('app.media.right_black'))
          .width(this.s(10))
          .height(this.s(10))
          .margin({ left: this.s(3) });
      }
      .layoutWeight(cell.weight)
      .constraintSize({ minWidth: this.s(this.selectBoxMinWidth(cell)) })
      .height(this.s(this.inputBoxHeight))
      .padding({ left: this.s(5), right: this.s(5) })
      .backgroundColor('#FCFCFC')
      .border({ width: 1, color: '#C8C8C8' })
      .borderRadius(this.s(this.fieldBoxRadius))
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.openCellSelect(cell);
      });
    } else {
      TextInput({ text: this.getCellValue(cell), placeholder: '' })
        .layoutWeight(cell.weight)
        .constraintSize({ minWidth: this.s(cell.valueMinWidth) })
        .height(this.s(this.inputBoxHeight))
        .fontSize(this.s(this.inputValueFontSize))
        .fontColor('#111111')
        .fontFamily(cell.inputFontFamily)
        .backgroundColor('#FCFCFC')
        .border({ width: 1, color: '#C8C8C8' })
        .borderRadius(this.s(this.fieldBoxRadius))
        .padding({ left: this.s(5), right: this.s(5), top: this.s(1), bottom: this.s(1) })
        .textAlign(TextAlign.Start)
        .onChange((value: string) => {
          this.setCellValue(cell, value);
        });
    }
  }

  @Builder
  MonitorSections() {
    Column() {
      ForEach(RELAY_MONITOR_SECTIONS.slice(0, this.visibleMonitorSectionCount), (section: RelayMonitorSectionSpec, index: number) => {
        this.MonitorSection(section, index === 0);
      }, (section: RelayMonitorSectionSpec) => section.id)
    }
    .width('100%')
    .padding({ left: this.s(16), right: this.s(16), bottom: this.s(5) });
  }

  @Builder
  MonitorSection(section: RelayMonitorSectionSpec, isFirst: boolean) {
    Column() {
      Divider()
        .strokeWidth(this.s(1))
        .color('#B8B8B8')
        .width('100%')
        .margin({ bottom: this.s(4), top: isFirst ? 0 : this.s(3) });

      Text(section.title)
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .width('100%')
        .margin({ bottom: this.s(4) });

      Row() {
        ForEach(section.fields, (field: RelayMonitorFieldSpec, index: number) => {
          this.MonitorField(field);
          if (index !== section.fields.length - 1) {
            Blank().width(this.s(section.fields.length === 3 ? 38 : 92));
          }
        }, (field: RelayMonitorFieldSpec) => field.id)

        Blank().layoutWeight(1);
      }
      .width('100%')
      .padding({ left: this.s(32), right: this.s(6), bottom: this.s(1) })
      .alignItems(VerticalAlign.Center);
    }
    .width('100%');
  }

  @Builder
  MonitorField(field: RelayMonitorFieldSpec) {
    Row() {
      Text(field.label)
        .fontSize(this.s(this.fieldLabelFontSize))
        .minFontSize(this.s(this.fieldMinFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .margin({ right: this.s(6) });

      Row() {
        if (field.kind === 'select') {
          Text(this.getMonitorFieldValue(field))
            .layoutWeight(1)
            .fontSize(this.s(this.inputValueFontSize))
            .fontColor('#111111')
            .fontFamily('STKaiti')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Clip })
            .textAlign(TextAlign.Start);

          Image($r('app.media.right_black'))
            .width(this.s(12))
            .height(this.s(12))
            .margin({ left: this.s(4) });
        } else {
          TextInput({ text: this.getMonitorFieldValue(field), placeholder: '' })
            .layoutWeight(1)
            .height('100%')
            .fontSize(this.s(this.inputValueFontSize))
            .fontColor('#111111')
            .fontFamily(field.inputFontFamily)
            .backgroundColor('#00000000')
            .border({ width: 0 })
            .padding({ left: 0, right: 0, top: this.s(1), bottom: this.s(1) })
            .textAlign(TextAlign.Start)
            .onChange((value: string) => {
              this.setMonitorFieldValue(field, value);
            });
        }
      }
      .width(this.s(this.monitorFieldBoxWidth(field)))
      .height(this.s(this.inputBoxHeight))
      .padding({ left: this.s(5), right: this.s(5) })
      .backgroundColor('#FCFCFC')
      .border({ width: 1, color: '#C8C8C8' })
      .borderRadius(this.s(this.fieldBoxRadius))
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (field.kind === 'select') {
          this.openMonitorSelect(field);
        }
      });

      if (field.kind !== 'select' && field.unit !== '') {
        Text(field.unit)
          .fontSize(this.s(this.fieldUnitFontSize))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .margin({ left: this.s(6) });
      }
    }
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  SelectOverlay() {
    Stack() {
      Row() {
      }
        .width('100%')
        .height('100%')
        .backgroundColor('#55000000')
        .onClick(() => {
          this.closeSelectOverlay();
        });

      Column() {
        Text(this.selectOverlayTitle)
          .width('100%')
          .fontSize(this.s(this.sectionTitleFontSize))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        ForEach(this.selectOverlayOptions, (option: string) => {
          Button() {
            Text(option)
              .fontSize(this.s(this.fieldLabelFontSize))
              .fontColor('#000000')
              .fontFamily('STKaiti');
          }
          .width('100%')
          .height(this.s(42))
          .margin({ bottom: this.s(6) })
          .backgroundColor(option === this.selectOverlayValue ? '#D9E9F8' : '#FFFFFF')
          .border({ width: 1, color: option === this.selectOverlayValue ? '#7A9CC0' : '#BEBEBE' })
          .borderRadius(4)
          .onClick(() => {
            this.applySelectOverlayValue(option);
          });
        }, (option: string) => option)

        Button('取消')
          .width('100%')
          .height(this.s(40))
          .margin({ top: this.s(4) })
          .fontSize(this.s(this.fieldLabelFontSize))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .onClick(() => {
            this.closeSelectOverlay();
          });
      }
      .width(this.s(320))
      .padding({ left: this.s(14), right: this.s(14), top: this.s(14), bottom: this.s(14) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(8);
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  SubmitWaitingOverlay() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#55000000');

      Column() {
        Text('等待回应')
          .fontSize(this.s(this.sectionTitleFontSize))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .margin({ bottom: this.s(12) });

        Text(this.submitWaitingMessage)
          .width('100%')
          .fontSize(this.s(this.inputValueFontSize))
          .fontColor('#333333')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(16) });

        Button('确定')
          .width(this.s(120))
          .height(this.s(38))
          .fontSize(this.s(this.fieldLabelFontSize))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#D9D9D9')
          .border({ width: 0 })
          .borderRadius(this.s(8))
          .onClick(() => {
            this.closeSubmitWaiting();
          });
      }
      .width(this.s(360))
      .padding({ left: this.s(18), right: this.s(18), top: this.s(18), bottom: this.s(18) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(8)
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().layoutWeight(5);

      Button(this.vm.actions.defaultText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#C7C7C7')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .onClick(() => {
          this.resetCurrentZoneValues();
        });

      Blank().layoutWeight(10);

      Button(this.vm.actions.confirmText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#C7C7C7')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .onClick(() => {
          this.submitCurrentData();
        });

      Blank().layoutWeight(5);

      Button(this.vm.actions.closeText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#C7C7C7')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(5);

      Button(this.vm.actions.cancelText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#C7C7C7')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(10);

      Text(this.vm.timeText)
        .layoutWeight(25)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .padding({ top: 0, bottom: 0 });
    }
    .width('100%')
    .height(this.s(70))
    .padding({ left: this.s(8), right: this.s(8), top: this.s(6), bottom: this.s(5) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }
}
