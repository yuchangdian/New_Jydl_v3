export const RELAY_SETTING_PROFILES_STORE_KEY: string = 'relay_setting_profiles_store_v2';
export const RELAY_SETTING_STORE_VERSION: number = 2;
export const RELAY_PROFILE_COUNT: number = 20;

export type RelayStoredFieldValueType = 'number' | 'enum' | 'string';
export type RelayGroupKey =
  'common' |
  'communication' |
  'pilot' |
  'overCurrent' |
  'io' |
  'adaptIo' |
  'reclosure' |
  'overLoad' |
  'lowVoltage' |
  'overVoltage' |
  'lowFrequency' |
  'highFrequency' |
  'inversePower' |
  'harmonicCurrent' |
  'harmonicVoltage' |
  'abnormalMonitoring';


export interface RelayCellLike {
  id: string;
  kind: string;
  text: string;
}

export interface RelayRowItemLike {
  cells: RelayCellLike[];
}

export interface RelayRowLike {
  items: RelayRowItemLike[];
}

export interface RelaySectionLike {
  id: string;
  rows: RelayRowLike[];
}

export interface RelayMonitorFieldLike {
  id: string;
  value: string;
  unit: string;
  kind: string;
}

export interface RelayMonitorSectionLike {
  id: string;
  fields: RelayMonitorFieldLike[];
}

export class RelayEnumOption {
  label: string;
  value: number;

  constructor(label: string, value: number) {
    this.label = label;
    this.value = value;
  }
}

export class RelayStoredField {
  valueType: RelayStoredFieldValueType;
  textValue: string;
  numberValue: number;
  enumValue: number;

  constructor(
    valueType: RelayStoredFieldValueType,
    textValue: string = '',
    numberValue: number = 0,
    enumValue: number = 0
  ) {
    this.valueType = valueType;
    this.textValue = textValue;
    this.numberValue = numberValue;
    this.enumValue = enumValue;
  }
}

export class RelayStoredFieldEntry {
  key: string;
  field: RelayStoredField;

  constructor(key: string, field: RelayStoredField) {
    this.key = key;
    this.field = field;
  }
}

export class RelaySettingFieldGroup {
  fields: RelayStoredFieldEntry[] = [];
}

export class RelaySettingCommonStruct extends RelaySettingFieldGroup {
}

export class RelaySettingCommunicationStruct extends RelaySettingFieldGroup {
}

export class RelaySettingPilotRelayStruct extends RelaySettingFieldGroup {
}

export class RelaySettingOverCurrentStruct extends RelaySettingFieldGroup {
}

export class RelaySettingIoStruct extends RelaySettingFieldGroup {
}

export class RelaySettingAdaptIoStruct extends RelaySettingFieldGroup {
}

export class RelaySettingReclosureStruct extends RelaySettingFieldGroup {
}

export class RelaySettingOverLoadStruct extends RelaySettingFieldGroup {
}

export class RelaySettingLowVoltageStruct extends RelaySettingFieldGroup {
}

export class RelaySettingOverVoltageStruct extends RelaySettingFieldGroup {
}

export class RelaySettingLowFrequencyStruct extends RelaySettingFieldGroup {
}

export class RelaySettingHighFrequencyStruct extends RelaySettingFieldGroup {
}

export class RelaySettingInversePowerStruct extends RelaySettingFieldGroup {
}

export class RelaySettingHarmonicCurrentStruct extends RelaySettingFieldGroup {
}

export class RelaySettingHarmonicVoltageStruct extends RelaySettingFieldGroup {
}

export class RelaySettingAbnormalMonitoringStruct extends RelaySettingFieldGroup {
}

export class RelaySettingProfile {
  zoneCode: string;
  common: RelaySettingCommonStruct = new RelaySettingCommonStruct();
  communication: RelaySettingCommunicationStruct = new RelaySettingCommunicationStruct();
  pilot: RelaySettingPilotRelayStruct = new RelaySettingPilotRelayStruct();
  overCurrent: RelaySettingOverCurrentStruct = new RelaySettingOverCurrentStruct();
  io: RelaySettingIoStruct = new RelaySettingIoStruct();
  adaptIo: RelaySettingAdaptIoStruct = new RelaySettingAdaptIoStruct();
  reclosure: RelaySettingReclosureStruct = new RelaySettingReclosureStruct();
  overLoad: RelaySettingOverLoadStruct = new RelaySettingOverLoadStruct();
  lowVoltage: RelaySettingLowVoltageStruct = new RelaySettingLowVoltageStruct();
  overVoltage: RelaySettingOverVoltageStruct = new RelaySettingOverVoltageStruct();
  lowFrequency: RelaySettingLowFrequencyStruct = new RelaySettingLowFrequencyStruct();
  highFrequency: RelaySettingHighFrequencyStruct = new RelaySettingHighFrequencyStruct();
  inversePower: RelaySettingInversePowerStruct = new RelaySettingInversePowerStruct();
  harmonicCurrent: RelaySettingHarmonicCurrentStruct = new RelaySettingHarmonicCurrentStruct();
  harmonicVoltage: RelaySettingHarmonicVoltageStruct = new RelaySettingHarmonicVoltageStruct();
  abnormalMonitoring: RelaySettingAbnormalMonitoringStruct = new RelaySettingAbnormalMonitoringStruct();

  constructor(zoneCode: string) {
    this.zoneCode = zoneCode;
  }
}

export class RelaySettingProfilesStore {
  version: number = RELAY_SETTING_STORE_VERSION;
  profiles: RelaySettingProfile[] = [];
}

export class RelayFieldBinding {
  fieldId: string;
  bindingIndex: number;
  group: RelayGroupKey;
  fieldKey: string;
  valueType: RelayStoredFieldValueType;
  defaultText: string;
  unit: string;
  labelText: string;
  options: RelayEnumOption[];

  constructor(
    fieldId: string,
    bindingIndex: number,
    group: RelayGroupKey,
    fieldKey: string,
    valueType: RelayStoredFieldValueType,
    defaultText: string,
    unit: string = '',
    options: RelayEnumOption[] = [],
    labelText: string = '请选择'
  ) {
    this.fieldId = fieldId;
    this.bindingIndex = bindingIndex;
    this.group = group;
    this.fieldKey = fieldKey;
    this.valueType = valueType;
    this.defaultText = defaultText;
    this.unit = unit;
    this.labelText = labelText;
    this.options = options;
  }
}

class RelayProfilesSessionCache {
  serializedStore: string = '';
  hasStore: boolean = false;
  store: RelaySettingProfilesStore = new RelaySettingProfilesStore();
}

const RELAY_PROFILES_SESSION_CACHE: RelayProfilesSessionCache = new RelayProfilesSessionCache();

function relayDefaultNumber(text: string): number {
  let parsed = Number(text);
  return isNaN(parsed) ? 0 : parsed;
}

function relaySpecialEnumValueForLabel(label: string): number {
  switch (label) {
    case '投入':
      return 1;
    case '退出':
      return 0;
    case '折算':
      return 1;
    case '不折算':
      return 0;
    case '跳闸':
      return 1;
    case '告警':
      return 0;
    case '不重合':
      return 0;
    case '重合':
      return 1;
    case '解列':
      return 0;
    case '减载':
      return 1;
    default:
      return -1;
  }
}

function relayEnumValueForLabel(label: string, options: RelayEnumOption[], fallbackValue: number): number {
  for (let i = 0; i < options.length; i++) {
    if (options[i].label === label) {
      return options[i].value;
    }
  }
  let specialValue = relaySpecialEnumValueForLabel(label);
  return specialValue >= 0 ? specialValue : fallbackValue;
}

function relayLabelForEnumValue(value: number, options: RelayEnumOption[], fallbackText: string): string {
  for (let i = 0; i < options.length; i++) {
    if (options[i].value === value) {
      return options[i].label;
    }
  }
  return fallbackText;
}

function relayFieldValueTypeForSpec(
  group: RelayGroupKey,
  kind: string,
  defaultText: string,
  unit: string
): RelayStoredFieldValueType {
  if (kind === 'select') {
    return 'enum';
  }
  if (group === 'communication') {
    return 'string';
  }
  if (defaultText.indexOf(':') !== -1) {
    return 'string';
  }
  if (/^-?\d+(\.\d+)?$/.test(defaultText) || unit.length > 0) {
    return 'number';
  }
  return 'string';
}

function relayUnitTextInCells(cells: RelayCellLike[]): string {
  for (let i = 0; i < cells.length; i++) {
    if (cells[i].kind === 'unit') {
      return cells[i].text;
    }
  }
  return '';
}

function relayLabelTextInCells(cells: RelayCellLike[]): string {
  for (let i = 0; i < cells.length; i++) {
    if (cells[i].kind === 'label') {
      return cells[i].text;
    }
  }
  return '';
}

function relayItemHasFieldContent(item: RelayRowItemLike): boolean {
  for (let i = 0; i < item.cells.length; i++) {
    let kind = item.cells[i].kind;
    if (kind === 'label' || kind === 'input' || kind === 'select') {
      return true;
    }
  }
  return false;
}

function relayFindUnitForItem(row: RelayRowLike, itemIndex: number): string {
  let item = row.items[itemIndex];
  let localUnit = relayUnitTextInCells(item.cells);
  if (localUnit.length > 0) {
    return localUnit;
  }
  for (let nextItemIndex = itemIndex + 1; nextItemIndex < row.items.length; nextItemIndex++) {
    let nextItem = row.items[nextItemIndex];
    let nextUnit = relayUnitTextInCells(nextItem.cells);
    if (nextUnit.length > 0) {
      return nextUnit;
    }
    if (relayItemHasFieldContent(nextItem)) {
      break;
    }
  }
  return '';
}

function relayFindLabelForItem(row: RelayRowLike, itemIndex: number): string {
  let item = row.items[itemIndex];
  let localLabel = relayLabelTextInCells(item.cells);
  if (localLabel.length > 0) {
    return localLabel;
  }
  for (let prevItemIndex = itemIndex - 1; prevItemIndex >= 0; prevItemIndex--) {
    let previousLabel = relayLabelTextInCells(row.items[prevItemIndex].cells);
    if (previousLabel.length > 0) {
      return previousLabel;
    }
  }
  return '请选择';
}

function relayGroupForSectionId(sectionId: string): RelayGroupKey {
  let match = /^section-(\d+)$/.exec(sectionId);
  let sectionIndex = match ? Number(match[1]) : 0;
  if (sectionIndex === 1) {
    return 'common';
  }
  if (sectionIndex === 2) {
    return 'communication';
  }
  if (sectionIndex >= 3 && sectionIndex <= 6) {
    return 'pilot';
  }
  if (sectionIndex >= 7 && sectionIndex <= 13) {
    return 'overCurrent';
  }
  if (sectionIndex >= 14 && sectionIndex <= 18) {
    return 'io';
  }
  if (sectionIndex === 19) {
    return 'adaptIo';
  }
  if (sectionIndex === 20) {
    return 'reclosure';
  }
  if (sectionIndex === 21) {
    return 'overLoad';
  }
  if (sectionIndex === 22) {
    return 'lowVoltage';
  }
  if (sectionIndex === 23) {
    return 'overVoltage';
  }
  if (sectionIndex === 24) {
    return 'lowFrequency';
  }
  if (sectionIndex === 25) {
    return 'highFrequency';
  }
  if (sectionIndex === 26) {
    return 'inversePower';
  }
  if (sectionIndex === 27) {
    return 'harmonicCurrent';
  }
  if (sectionIndex === 28) {
    return 'harmonicVoltage';
  }
  return 'common';
}

export function relayDefaultSelectOptions(defaultValue: string): string[] {
  if (defaultValue === '投入' || defaultValue === '退出') {
    return ['投入', '退出'];
  }
  if (defaultValue === '折算' || defaultValue === '不折算') {
    return ['折算', '不折算'];
  }
  if (defaultValue === '跳闸' || defaultValue === '告警') {
    return ['跳闸', '告警'];
  }
  if (
    defaultValue === '一般反时限' ||
    defaultValue === '非常反时限' ||
    defaultValue === '极端反时限'
  ) {
    return ['一般反时限', '非常反时限', '极端反时限'];
  }
  if (
    defaultValue === '闭锁' ||
    defaultValue === '普通' ||
    defaultValue === '检同期' ||
    defaultValue === '检线路无压且母有压' ||
    defaultValue === '检线路有压且母无压' ||
    defaultValue === '检线路无压且母无压' ||
    defaultValue === '检线路无压或母无压'
  ) {
    return [
      '闭锁',
      '普通',
      '检同期',
      '检线路无压且母有压',
      '检线路有压且母无压',
      '检线路无压且母无压',
      '检线路无压或母无压'
    ];
  }
  if (defaultValue === '不重合' || defaultValue === '重合') {
    return ['不重合', '重合'];
  }
  if (defaultValue === '解列' || defaultValue === '减载') {
    return ['解列', '减载'];
  }
  return [defaultValue];
}

function relayEnumOptionsForDefault(defaultValue: string): RelayEnumOption[] {
  let labels = relayDefaultSelectOptions(defaultValue);
  let options: RelayEnumOption[] = [];
  for (let i = 0; i < labels.length; i++) {
    let label = labels[i];
    let specialValue = relaySpecialEnumValueForLabel(label);
    options.push(new RelayEnumOption(label, specialValue >= 0 ? specialValue : i));
  }
  return options;
}

export function buildRelayFieldBindings(
  mainSections: RelaySectionLike[],
  monitorSections: RelayMonitorSectionLike[]
): RelayFieldBinding[] {
  let bindings: RelayFieldBinding[] = [];
  let nextBindingIndex = 0;

  for (let sectionIndex = 0; sectionIndex < mainSections.length; sectionIndex++) {
    let section = mainSections[sectionIndex];
    let group = relayGroupForSectionId(section.id);
    for (let rowIndex = 0; rowIndex < section.rows.length; rowIndex++) {
      let row = section.rows[rowIndex];
      for (let itemIndex = 0; itemIndex < row.items.length; itemIndex++) {
        let item = row.items[itemIndex];
        let unit = relayFindUnitForItem(row, itemIndex);
        let labelText = relayFindLabelForItem(row, itemIndex);
        for (let cellIndex = 0; cellIndex < item.cells.length; cellIndex++) {
          let cell = item.cells[cellIndex];
          if (cell.kind !== 'input' && cell.kind !== 'select') {
            continue;
          }
          let valueType = relayFieldValueTypeForSpec(group, cell.kind, cell.text, unit);
          bindings.push(new RelayFieldBinding(
            cell.id,
            nextBindingIndex,
            group,
            cell.id,
            valueType,
            cell.text,
            cell.kind === 'input' ? unit : '',
            cell.kind === 'select' ? relayEnumOptionsForDefault(cell.text) : [],
            labelText
          ));
          nextBindingIndex++;
        }
      }
    }
  }

  for (let sectionIndex = 0; sectionIndex < monitorSections.length; sectionIndex++) {
    let section = monitorSections[sectionIndex];
    for (let fieldIndex = 0; fieldIndex < section.fields.length; fieldIndex++) {
      let field = section.fields[fieldIndex];
      let valueType = relayFieldValueTypeForSpec('abnormalMonitoring', field.kind, field.value, field.unit);
      bindings.push(new RelayFieldBinding(
        field.id,
        nextBindingIndex,
        'abnormalMonitoring',
        field.id,
        valueType,
        field.value,
        field.kind === 'input' ? field.unit : '',
        field.kind === 'select' ? relayEnumOptionsForDefault(field.value) : [],
        field.value
      ));
      nextBindingIndex++;
    }
  }

  return bindings;
}

export function relayFindFieldBinding(bindings: RelayFieldBinding[], fieldId: string): RelayFieldBinding | undefined {
  for (let i = 0; i < bindings.length; i++) {
    if (bindings[i].fieldId === fieldId) {
      return bindings[i];
    }
  }
  return undefined;
}

export function relayNormalizeZoneCode(zoneCode: string | undefined): string {
  let normalized = zoneCode ? zoneCode.trim() : '';
  if (!/^\d{1,2}$/.test(normalized)) {
    return '00';
  }
  normalized = normalized.padStart(2, '0');
  let zoneIndex = Number(normalized);
  if (isNaN(zoneIndex) || zoneIndex < 0 || zoneIndex >= RELAY_PROFILE_COUNT) {
    return '00';
  }
  return normalized;
}

export function relayZoneCodeToIndex(zoneCode: string | undefined): number {
  return Number(relayNormalizeZoneCode(zoneCode));
}

export function relayZoneCodeForIndex(index: number): string {
  return index.toString().padStart(2, '0');
}

export function relayStripUnitSuffix(value: string, unit: string): string {
  let normalized = value.trim();
  if (unit.length === 0 || normalized.length === 0) {
    return normalized;
  }
  let spacedSuffix = ' ' + unit;
  if (normalized.endsWith(spacedSuffix)) {
    return normalized.substring(0, normalized.length - spacedSuffix.length).trim();
  }
  if (normalized.endsWith(unit)) {
    return normalized.substring(0, normalized.length - unit.length).trim();
  }
  return normalized;
}

function relayGroupContainer(profile: RelaySettingProfile, group: RelayGroupKey): RelaySettingFieldGroup {
  switch (group) {
    case 'common':
      return profile.common;
    case 'communication':
      return profile.communication;
    case 'pilot':
      return profile.pilot;
    case 'overCurrent':
      return profile.overCurrent;
    case 'io':
      return profile.io;
    case 'adaptIo':
      return profile.adaptIo;
    case 'reclosure':
      return profile.reclosure;
    case 'overLoad':
      return profile.overLoad;
    case 'lowVoltage':
      return profile.lowVoltage;
    case 'overVoltage':
      return profile.overVoltage;
    case 'lowFrequency':
      return profile.lowFrequency;
    case 'highFrequency':
      return profile.highFrequency;
    case 'inversePower':
      return profile.inversePower;
    case 'harmonicCurrent':
      return profile.harmonicCurrent;
    case 'harmonicVoltage':
      return profile.harmonicVoltage;
    case 'abnormalMonitoring':
    default:
      return profile.abnormalMonitoring;
  }
}

export function relayGroupFields(profile: RelaySettingProfile, group: RelayGroupKey): RelayStoredFieldEntry[] {
  let container = relayGroupContainer(profile, group);
  if (!container.fields) {
    container.fields = [];
  }
  return container.fields;
}

function relayCloneStoredField(source: RelayStoredField): RelayStoredField {
  return new RelayStoredField(
    source.valueType,
    source.textValue,
    source.numberValue,
    source.enumValue
  );
}

function relayFindFieldEntryIndex(fields: RelayStoredFieldEntry[], key: string): number {
  for (let i = 0; i < fields.length; i++) {
    if (fields[i].key === key) {
      return i;
    }
  }
  return -1;
}

function relayReadStoredField(fields: RelayStoredFieldEntry[], key: string): RelayStoredField | undefined {
  let index = relayFindFieldEntryIndex(fields, key);
  if (index === -1) {
    return undefined;
  }
  return fields[index].field;
}

function relayWriteStoredField(fields: RelayStoredFieldEntry[], key: string, field: RelayStoredField): void {
  let index = relayFindFieldEntryIndex(fields, key);
  let nextField = relayCloneStoredField(field);
  if (index === -1) {
    fields.push(new RelayStoredFieldEntry(key, nextField));
    return;
  }
  fields[index].field = nextField;
}

export function relayReadProfileField(profile: RelaySettingProfile | undefined, binding: RelayFieldBinding): RelayStoredField | undefined {
  if (!profile) {
    return undefined;
  }
  return relayReadStoredField(relayGroupFields(profile, binding.group), binding.fieldKey);
}

export function relayWriteProfileField(profile: RelaySettingProfile, binding: RelayFieldBinding, field: RelayStoredField): void {
  relayWriteStoredField(relayGroupFields(profile, binding.group), binding.fieldKey, field);
}

function relayCloneFieldEntries(source: RelayStoredFieldEntry[]): RelayStoredFieldEntry[] {
  let target: RelayStoredFieldEntry[] = [];
  for (let i = 0; i < source.length; i++) {
    let entry = source[i];
    if (!entry || !entry.field) {
      continue;
    }
    target.push(new RelayStoredFieldEntry(entry.key, relayCloneStoredField(entry.field)));
  }
  return target;
}

function relayAssignGroupClone(profile: RelaySettingProfile, group: RelayGroupKey, source: RelayStoredFieldEntry[]): void {
  let container = relayGroupContainer(profile, group);
  container.fields = relayCloneFieldEntries(source);
}

export function cloneRelaySettingProfile(profile: RelaySettingProfile): RelaySettingProfile {
  let nextProfile = new RelaySettingProfile(profile.zoneCode);
  relayAssignGroupClone(nextProfile, 'common', relayGroupFields(profile, 'common'));
  relayAssignGroupClone(nextProfile, 'communication', relayGroupFields(profile, 'communication'));
  relayAssignGroupClone(nextProfile, 'pilot', relayGroupFields(profile, 'pilot'));
  relayAssignGroupClone(nextProfile, 'overCurrent', relayGroupFields(profile, 'overCurrent'));
  relayAssignGroupClone(nextProfile, 'io', relayGroupFields(profile, 'io'));
  relayAssignGroupClone(nextProfile, 'adaptIo', relayGroupFields(profile, 'adaptIo'));
  relayAssignGroupClone(nextProfile, 'reclosure', relayGroupFields(profile, 'reclosure'));
  relayAssignGroupClone(nextProfile, 'overLoad', relayGroupFields(profile, 'overLoad'));
  relayAssignGroupClone(nextProfile, 'lowVoltage', relayGroupFields(profile, 'lowVoltage'));
  relayAssignGroupClone(nextProfile, 'overVoltage', relayGroupFields(profile, 'overVoltage'));
  relayAssignGroupClone(nextProfile, 'lowFrequency', relayGroupFields(profile, 'lowFrequency'));
  relayAssignGroupClone(nextProfile, 'highFrequency', relayGroupFields(profile, 'highFrequency'));
  relayAssignGroupClone(nextProfile, 'inversePower', relayGroupFields(profile, 'inversePower'));
  relayAssignGroupClone(nextProfile, 'harmonicCurrent', relayGroupFields(profile, 'harmonicCurrent'));
  relayAssignGroupClone(nextProfile, 'harmonicVoltage', relayGroupFields(profile, 'harmonicVoltage'));
  relayAssignGroupClone(nextProfile, 'abnormalMonitoring', relayGroupFields(profile, 'abnormalMonitoring'));
  return nextProfile;
}

export function cloneRelaySettingProfilesStoreForProfileUpdate(
  store: RelaySettingProfilesStore,
  profileIndex: number
): RelaySettingProfilesStore {
  let nextStore = new RelaySettingProfilesStore();
  nextStore.version = store.version;
  nextStore.profiles = [];
  for (let i = 0; i < store.profiles.length; i++) {
    nextStore.profiles.push(i === profileIndex ? cloneRelaySettingProfile(store.profiles[i]) : store.profiles[i]);
  }
  return nextStore;
}

export function cloneRelaySettingProfilesStore(store: RelaySettingProfilesStore): RelaySettingProfilesStore {
  let nextStore = new RelaySettingProfilesStore();
  nextStore.version = store.version;
  nextStore.profiles = [];
  for (let i = 0; i < store.profiles.length; i++) {
    nextStore.profiles.push(cloneRelaySettingProfile(store.profiles[i]));
  }
  return nextStore;
}

export function relayDefaultStoredField(binding: RelayFieldBinding): RelayStoredField {
  if (binding.valueType === 'enum') {
    let enumValue = relayEnumValueForLabel(binding.defaultText, binding.options, 0);
    return new RelayStoredField('enum', relayLabelForEnumValue(enumValue, binding.options, binding.defaultText), 0, enumValue);
  }
  if (binding.valueType === 'number') {
    return new RelayStoredField('number', binding.defaultText, relayDefaultNumber(binding.defaultText), 0);
  }
  return new RelayStoredField('string', binding.defaultText, 0, 0);
}

export function createDefaultRelaySettingProfile(
  zoneCode: string,
  bindings: RelayFieldBinding[]
): RelaySettingProfile {
  let profile = new RelaySettingProfile(relayNormalizeZoneCode(zoneCode));
  for (let i = 0; i < bindings.length; i++) {
    relayWriteProfileField(profile, bindings[i], relayDefaultStoredField(bindings[i]));
  }
  return profile;
}

export function createDefaultRelaySettingProfilesStore(
  bindings: RelayFieldBinding[]
): RelaySettingProfilesStore {
  let store = new RelaySettingProfilesStore();
  store.profiles = [];
  for (let i = 0; i < RELAY_PROFILE_COUNT; i++) {
    store.profiles.push(createDefaultRelaySettingProfile(relayZoneCodeForIndex(i), bindings));
  }
  return store;
}

function relayNormalizeNumberText(rawField: RelayStoredField, binding: RelayFieldBinding, fallbackField: RelayStoredField): RelayStoredField {
  let textValue = typeof rawField.textValue === 'string' && rawField.textValue.length > 0 ? rawField.textValue : fallbackField.textValue;
  textValue = relayStripUnitSuffix(textValue, binding.unit);
  let numberValue = typeof rawField.numberValue === 'number' && !isNaN(rawField.numberValue)
    ? rawField.numberValue
    : relayDefaultNumber(textValue);
  return new RelayStoredField('number', textValue, numberValue, 0);
}

function relayNormalizeEnumText(rawField: RelayStoredField, binding: RelayFieldBinding, fallbackField: RelayStoredField): RelayStoredField {
  let fallbackValue = fallbackField.enumValue;
  let enumValue = typeof rawField.enumValue === 'number' && !isNaN(rawField.enumValue)
    ? rawField.enumValue
    : relayEnumValueForLabel(rawField.textValue, binding.options, fallbackValue);
  let textValue = relayLabelForEnumValue(enumValue, binding.options, fallbackField.textValue);
  return new RelayStoredField('enum', textValue, 0, enumValue);
}

function relayNormalizeStringText(rawField: RelayStoredField, fallbackField: RelayStoredField): RelayStoredField {
  let textValue = typeof rawField.textValue === 'string' && rawField.textValue.length > 0 ? rawField.textValue : fallbackField.textValue;
  return new RelayStoredField('string', textValue, 0, 0);
}

function relayReadFieldFromProfile(profile: RelaySettingProfile | undefined, binding: RelayFieldBinding): RelayStoredField | undefined {
  return relayReadProfileField(profile, binding);
}

function relayNormalizeStoredField(rawField: RelayStoredField | undefined, binding: RelayFieldBinding): RelayStoredField {
  let fallbackField = relayDefaultStoredField(binding);
  if (!rawField) {
    return fallbackField;
  }
  if (binding.valueType === 'number') {
    return relayNormalizeNumberText(rawField, binding, fallbackField);
  }
  if (binding.valueType === 'enum') {
    return relayNormalizeEnumText(rawField, binding, fallbackField);
  }
  return relayNormalizeStringText(rawField, fallbackField);
}

export function relayParseStoredField(
  rawValue: string,
  binding: RelayFieldBinding,
  previousField?: RelayStoredField
): RelayStoredField {
  let fallbackField = previousField ? previousField : relayDefaultStoredField(binding);
  let normalizedValue = relayStripUnitSuffix(rawValue, binding.unit);

  if (binding.valueType === 'number') {
    let numberValue = normalizedValue.length > 0 ? relayDefaultNumber(normalizedValue) : fallbackField.numberValue;
    return new RelayStoredField('number', normalizedValue, numberValue, 0);
  }

  if (binding.valueType === 'enum') {
    let enumValue = relayEnumValueForLabel(normalizedValue, binding.options, fallbackField.enumValue);
    return new RelayStoredField('enum', relayLabelForEnumValue(enumValue, binding.options, fallbackField.textValue), 0, enumValue);
  }

  return new RelayStoredField('string', normalizedValue, 0, 0);
}

export function relayFormatStoredField(field: RelayStoredField | undefined, binding: RelayFieldBinding): string {
  let normalizedField = relayNormalizeStoredField(field, binding);
  if (binding.valueType === 'enum') {
    return relayLabelForEnumValue(normalizedField.enumValue, binding.options, binding.defaultText);
  }
  return normalizedField.textValue;
}

export function relaySerializeProfilesStore(store: RelaySettingProfilesStore): string {
  return JSON.stringify(store);
}

export function relayDeserializeProfilesStore(
  raw: string,
  bindings: RelayFieldBinding[]
): RelaySettingProfilesStore | undefined {
  if (raw.trim().length === 0) {
    return undefined;
  }

  try {
    let parsed = JSON.parse(raw) as RelaySettingProfilesStore;
    let store = createDefaultRelaySettingProfilesStore(bindings);
    if (!parsed || !Array.isArray(parsed.profiles)) {
      return store;
    }

    for (let i = 0; i < RELAY_PROFILE_COUNT; i++) {
      let sourceProfile = parsed.profiles[i] as RelaySettingProfile;
      if (!sourceProfile) {
        continue;
      }
      let targetProfile = store.profiles[i];
      targetProfile.zoneCode = relayNormalizeZoneCode(sourceProfile.zoneCode);
      for (let bindingIndex = 0; bindingIndex < bindings.length; bindingIndex++) {
        let binding = bindings[bindingIndex];
        let rawField = relayReadFieldFromProfile(sourceProfile, binding);
        relayWriteProfileField(targetProfile, binding, relayNormalizeStoredField(rawField, binding));
      }
    }

    return store;
  } catch (error) {
    return undefined;
  }
}

export function relayRememberProfilesStoreInSession(raw: string, store: RelaySettingProfilesStore): void {
  RELAY_PROFILES_SESSION_CACHE.serializedStore = raw;
  RELAY_PROFILES_SESSION_CACHE.store = cloneRelaySettingProfilesStore(store);
  RELAY_PROFILES_SESSION_CACHE.hasStore = true;
}

export function relayLoadProfilesStoreFromSession(
  raw: string,
  bindings: RelayFieldBinding[]
): RelaySettingProfilesStore | undefined {
  if (raw.trim().length === 0) {
    return undefined;
  }
  if (RELAY_PROFILES_SESSION_CACHE.hasStore && RELAY_PROFILES_SESSION_CACHE.serializedStore === raw) {
    return cloneRelaySettingProfilesStore(RELAY_PROFILES_SESSION_CACHE.store);
  }
  let nextStore = relayDeserializeProfilesStore(raw, bindings);
  if (!nextStore) {
    return undefined;
  }
  relayRememberProfilesStoreInSession(raw, nextStore);
  return cloneRelaySettingProfilesStore(nextStore);
}
