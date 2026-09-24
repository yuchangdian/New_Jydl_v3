// 根据 Qt BPMU_JYBSMR131.h 移植；字段顺序与类型保持原样。
#pragma once
#include <cstdint>

namespace jybsmr131 {

#pragma pack(push, 1)
struct RecordSettingUnit {
    uint32_t Enable;
    float ActValue;
};

struct BroadbandPhasorSetting_Struct {
    float CrossoverFrequency;             //高低频段分频点	Hz 100~2500
    RecordSettingUnit VoltageSubsynOsc;	        //电压次同步振荡启动定值	%UN	2~100
    RecordSettingUnit VoltageSupersynOsc;	//电压超同步振荡启动定值	%UN	2~100
    RecordSettingUnit VoltageLowFreqHar;	//电压低频段谐波启动定值	%UN	2~100
    RecordSettingUnit VoltageHighFreqHar;	//电压高频段谐波启动定值	%UN	2~100
    RecordSettingUnit CurrentSubsynOsc;	        //电流次同步振荡启动定值	%IN	2~100
    RecordSettingUnit CurrentSupersynOsc;	//电流超同步振荡启动定值	%IN	2~100
    RecordSettingUnit CurrentLowFreqHar;	//电流低频段谐波启动定值	%IN	2~100
    RecordSettingUnit CurrentHighFreqHar;	//电流高频段谐波启动定值	%IN	2~100
    uint32_t CRC;                         //校验码
};

struct BroadbandPhasorRecordCode_Struct {
    uint16_t Start_UaSubsynOsc;					//A相电压次同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_UbSubsynOsc;					//B相电压次同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_UcSubsynOsc;					//C相电压次同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_UaSupersynOsc;				//A相电压超同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_UbSupersynOsc;				//B相电压超同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_UcSupersynOsc;				//C相电压超同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_UaLowFreqHar;				//A相电压低频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_UbLowFreqHar;				//B相电压低频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_UcLowFreqHar;				//C相电压低频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_UaHighFreqHar;				//A相电压高频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_UbHighFreqHar;				//B相电压高频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_UcHighFreqHar;				//C相电压高频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_IaSubsynOsc;					//A相电流次同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_IbSubsynOsc;					//B相电流次同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_IcSubsynOsc;					//C相电流次同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_IaSupersynOsc;				//A相电流超同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_IbSupersynOsc;				//B相电流超同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_IcSupersynOsc;				//C相电流超同步振荡启动录波：**年**月**日**：**：**：**
    uint16_t Start_IaLowFreqHar;				//A相电流低频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_IbLowFreqHar;				//B相电流低频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_IcLowFreqHar;				//C相电流低频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_IaHighFreqHar;				//A相电流高频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_IbHighFreqHar;				//B相电流高频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Start_IcHighFreqHar;				//C相电流高频段谐波启动录波：**年**月**日**：**：**：**
    uint16_t Freq_VoltageSubsynOsc;				//电压次同步振荡频率：A相xx.xxHz  B相xx.xxHz  C相xx.xxHz
    uint16_t Freq_VoltageSupersynOsc;			//电压超同步振荡频率：A相xx.xxHz  B相xx.xxHz  C相xx.xxHz
    uint16_t Freq_VoltageLowFreqHar;			//电压低频段谐波频率：A相xx.xxHz  B相xx.xxHz  C相xx.xxHz
    uint16_t Freq_VoltageHighFreqHar;			//电压高频段谐波频率：A相xx.xxHz  B相xx.xxHz  C相xx.xxHz
    uint16_t Freq_CurrentSubsynOsc;				//电流次同步振荡频率：A相xx.xxHz  B相xx.xxHz  C相xx.xxHz
    uint16_t Freq_CurrentSupersynOsc;			//电流超同步振荡频率：A相xx.xxHz  B相xx.xxHz  C相xx.xxHz
    uint16_t Freq_CurrentLowFreqHar;			//电流低频段谐波频率：A相xx.xxHz  B相xx.xxHz  C相xx.xxHz
    uint16_t Freq_CurrentHighFreqHar;			//电流高频段谐波频率：A相xx.xxHz  B相xx.xxHz  C相xx.xxHz
    uint16_t Value_VoltageSubsynOsc;			//电压次同步振荡幅值：A相xx.xxV		B相xx.xxV   C相xx.xxV
    uint16_t Value_VoltageSupersynOsc;		//电压超同步振荡幅值：A相xx.xxV		B相xx.xxV   C相xx.xxV
    uint16_t Value_VoltageLowFreqHar;			//电压低频段谐波幅值：A相xx.xxV		B相xx.xxV   C相xx.xxV
    uint16_t Value_VoltageHighFreqHar;		//电压高频段谐波幅值：A相xx.xxV		B相xx.xxV   C相xx.xxV
    uint16_t Value_CurrentSubsynOsc;			//电流次同步振荡幅值：A相xx.xxA		B相xx.xxA   C相xx.xxA
    uint16_t Value_CurrentSupersynOsc;		//电流超同步振荡幅值：A相xx.xxA		B相xx.xxA   C相xx.xxA
    uint16_t Value_CurrentLowFreqHar;			//电流低频段谐波幅值：A相xx.xxA		B相xx.xxA   C相xx.xxA
    uint16_t Value_CurrentHighFreqHar;		//电流高频段谐波幅值：A相xx.xxA		B相xx.xxA   C相xx.xxA
};
#pragma pack(pop)
} // namespace jybsmr131
