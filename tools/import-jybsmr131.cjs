// 用法：node tools/import-jybsmr131.cjs <Qt 最新结构体目录>
// 只提取协议类型和数值常量，不引入 Qt、全局变量、文件路径或界面尺寸。
const fs = require('node:fs');
const path = require('node:path');
const source = process.argv[2];
if (!source) throw new Error('请提供 Qt 最新结构体目录');
const target = path.join(__dirname, '../entry/src/main/cpp/protocol/jybsmr131');
fs.mkdirSync(target, { recursive: true });
function read(name) {
  return fs.readFileSync(path.join(source, name), 'utf8').replace(/\/\*[\s\S]*?\*\//g, '');
}
function structs(text) {
  const clean = text.replace(/\/\/[^\n]*/g, comment => ' '.repeat(comment.length));
  return [...clean.matchAll(/typedef\s+struct[^\{]*\{([^}]+)\}\s*(?:__attribute__\s*\(\(.*?\)\)\s*)?(\w+)\s*;/g)]
    .map(m => {
      const start = text.indexOf('{', m.index) + 1;
      const body = text.slice(start, start + m[1].length);
      return { name: m[2], body: body.trim().split('\n').map(l => l.trim()).filter(Boolean).join('\n    ') };
    });
}
function write(name, includes, types, constants = '', sourceName = name) {
  const body = types.map(t => {
    let prefix = '';
    for (const missing of ['PowerQualityIndicator_struct', 'HarmonicDistortion_struct']) {
      if (t.body.includes(missing)) prefix = `// 缺少 powerquality.h：必须提供真实载荷类型后才能实例化。\ntemplate <typename ${missing}>\n`;
    }
    return `${prefix}struct ${t.name} {\n    ${t.body}\n};`;
  }).join('\n\n');
  fs.writeFileSync(path.join(target, name), `// 根据 Qt ${sourceName} 移植；字段顺序与类型保持原样。\n#pragma once\n#include <cstdint>\n${includes}\nnamespace jybsmr131 {\n${constants}\n#pragma pack(push, 1)\n${body}\n#pragma pack(pop)\n} // namespace jybsmr131\n`);
}
const allTypes = [];
// powerquality.h 没有包含在 Qt“最新结构体”目录中；项目内的 quality.h
// 保存了告警定值页面实际使用的完整载荷布局。
const qualityTypes = structs(fs.readFileSync(path.join(__dirname, '../entry/src/main/cpp/quality.h'), 'utf8'))
  .filter(t => t.name === 'PQSettingUnit' || t.name === 'PowerQualitySetting_struct');
allTypes.push(...qualityTypes);
const dataTypes = structs(read('data.h'));
write('data_types.h', '', dataTypes, '', 'data.h');
allTypes.push(...dataTypes);
for (const name of ['setting.h', 'BPMU_JYBSMR131.h', 'FaultRecord_JYBSMR131.h']) {
  let types = structs(read(name));
  if (name === 'FaultRecord_JYBSMR131.h') types = types.filter(t => t.name !== 'RecordSettingUnit');
  write(name, name === 'FaultRecord_JYBSMR131.h' ? '#include "BPMU_JYBSMR131.h"' : '', types);
  allTypes.push(...types);
}
const systemTypes = structs(read('SystemSetting_JYBSMR131.h'));
// 此文件的一次系统结构没有 RatedCurrent_Primary，与 setting.h 的版本独立命名。
write('SystemSetting_JYBSMR131.h', '#include "setting.h"', [
  { ...systemTypes[0], name: 'SystemSettingWithoutRatedCurrent' }
]);
allTypes.push({ ...systemTypes[0], name: 'SystemSettingWithoutRatedCurrent' });
const iec = read('IEC104.h');
const constants = new Map();
for (const m of iec.replace(/\/\/[^\n]*/g, '').matchAll(/^\s*#define\s+(\w+)\s+(0x[\dA-Fa-f]+|\d+)\s*$/gm)) {
  // 后面的新版定义覆盖参考文件中遗留的 MeterageInit / DateTimeSet 重复定义。
  constants.set(m[1], m[2]);
}
// 源文件里这些旧定值名称与新定值地址冲突，只保留在已有旧协议头文件中。
for (const key of [...constants.keys()]) if (/^YT_ObjectAddr_(CommonSetting_|ProtectionSoftStrap|RelaySetting)/.test(key)) constants.delete(key);
// 原来的 SOE 长度包含旧版分组号，改由本版实际包结构计算。
for (const key of [...constants.keys()]) if (/DataLen(th)?$/.test(key)) constants.delete(key);
const iecTypes = structs(iec);
write('IEC104.h', '#include "setting.h"\n#include "BPMU_JYBSMR131.h"\n#include "FaultRecord_JYBSMR131.h"\n#include "../../quality.h"', iecTypes,
  [...constants].map(([k,v]) => `constexpr std::uint16_t k${k} = ${v};`).join('\n'));
allTypes.push(...iecTypes);

// 生成解包字段描述，偏移始终由编译器 offsetof 决定，避免手工维护魔数。
const typeMap = new Map(allTypes.map(t => [t.name, t]));
function fields(type, base = '0', prefix = '') {
  const result = [];
  for (const declaration of typeMap.get(type).body.replace(/\/\/[^\n]*/g, '').split(';').map(s => s.trim()).filter(Boolean)) {
    const m = declaration.match(/^(\w+)\s+([\s\S]+)$/);
    if (!m) throw new Error(declaration);
    for (const variable of m[2].split(',')) {
      const v = variable.trim().match(/^(\w+)(?:\[(\d+)\])?$/);
      if (!v) throw new Error(variable);
      const offset = `${base} + offsetof(${type}, ${v[1]})`;
      const name = `${prefix}${v[1]}`;
      if (typeMap.has(m[1])) result.push(...fields(m[1], offset, `${name}.`));
      else result.push(`    {"${name}", ${offset}, Scalar::${m[1] === 'float' ? 'Float32' : m[1] === 'int16_t' ? 'Int16' : 'Uint' + m[1].match(/\d+/)[0]}, ${v[2] || 1}, ${name === 'Value' ? '0.01' : '1.0'}},`);
    }
  }
  return result;
}
const decodedTypes = ['Package_YC_BaseValue_Struct', 'YC_HarmonicU_Struct', 'YC_HarmonicI_Struct',
  'Package_YC_PlotBuf_Struct', 'RemoteSignal_Change_Struct', 'RemoteSignalALL_Struct', 'CommonSetting_PrimarySystem_Struct',
  'SystemSettingWithoutRatedCurrent', 'CommonSetting_AnalogQuantity_Struct', 'FaultRecordSetting_Struct',
  'BroadbandPhasorSetting_Struct', 'PowerQualitySetting_struct'];
fs.writeFileSync(path.join(target, 'fields.inc'), '// 由 tools/import-jybsmr131.cjs 生成。\n' + decodedTypes.map(type => {
  const f = fields(type).filter(line => !/"(Common_addr|Object_addr|Length)"/.test(line));
  return `const FieldDescriptor fields_${type}[] = {\n${f.join('\n')}\n};`;
}).join('\n\n') + '\n');
console.log(`已移植 ${allTypes.length} 个类型、${constants.size} 个协议常量及 ${decodedTypes.length} 组解包描述。`);
