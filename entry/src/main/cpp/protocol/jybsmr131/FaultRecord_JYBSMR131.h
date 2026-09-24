// 根据 Qt FaultRecord_JYBSMR131.h 移植；字段顺序与类型保持原样。
#pragma once
#include <cstdint>
#include "BPMU_JYBSMR131.h"
namespace jybsmr131 {

#pragma pack(push, 1)
struct FaultRecordSetting_Struct {
    uint32_t SampleRate;                  //故障录波频率，显示50kHz/25kHz/12.5kHz/10kHz/5kHz，分别对应值1/2/4/5/10
    uint32_t LengthBefore;                //启动前记录长度，单位ms
    uint32_t LengthAfter;                 //启动后记录长度，单位ms
    uint32_t LengthDynamic;               //动态过程记录长度，单位s
    RecordSettingUnit VoltageMutation;          //相电压突变量启动定值	%UN	5~100
    RecordSettingUnit ZeroVoltageMutation;      //零序电压突变量启动定值	%UN	2~100
    RecordSettingUnit CurrentMutation;          //相电流突变量启动启动定值	%IN	10~200
    RecordSettingUnit ZeroCurrentMutation;      //零序电流突变量启动启动定值	%IN	10~200
    RecordSettingUnit VoltageLowerLimit;        //相电压越低限启动定值	%UN	50~90
    RecordSettingUnit VoltageUpperLimit;        //相电压越高限启动定值	%UN	110~130
    RecordSettingUnit NegativeVoltageLimit;     //负序电压启动定值	%UN	2~50
    RecordSettingUnit ZeroVoltageLimit;         //零序电压启动定值	%UN	2~50
    RecordSettingUnit CurrentUpperLimit;        //相电流越高限启动定值	%IN	110~200
    RecordSettingUnit NegativeCurrentLimit;     //负序电流启动定值	%IN	3~50
    RecordSettingUnit ZeroCurrentLimit;         //零序电流启动定值	%IN	3~50
    RecordSettingUnit FrequencyLowerLimit;      //频率越低限启动定值	Hz	45~49.9
    RecordSettingUnit FrequencyUpperLimit;      //频率越高限启动定值	Hz	50.1~55
    RecordSettingUnit FrequencyGradientLimit;   //频率变化率越限启动定值	Hz/s	0.3~3.0
    RecordSettingUnit HarmonicVoltageLimit;     //2/3/5/7次谐波电压启动定值	%UN	2~50
    RecordSettingUnit HarmonicCurrentLimit;     //2/3/5/7次谐波电流启动定值	%IN	3~50
    RecordSettingUnit ReversePowerLimit;        //逆功率启动定值	%PN	5~50
    RecordSettingUnit OverExcitation;           //过励磁V/f启动定值	pu	1.1~1.5
    uint32_t CRC;                         //校验码
};

struct FaultRecordCode_Struct {
    uint16_t Start_VoltageMutation;				//相电压突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_UaMutation;					//A相电压突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_UbMutation;					//B相电压突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_UcMutation;					//C相电压突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_UoMutation;					//零序电压突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_CurrentMutation;				//相电流突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_IaMutation;					//A相电流突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_IbMutation;					//B相电流突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_IcMutation;					//C相电流突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_IoMutation;					//零序电流突变量启动录波：**年**月**日**：**：**：**
    uint16_t Start_VoltageUnderLimit;			//相电压越低限启动录波：**年**月**日**：**：**：**
    uint16_t Start_UaUnderLimit;				//A相电压越低限启动录波：**年**月**日**：**：**：**
    uint16_t Start_UbUnderLimit;				//B相电压越低限启动录波：**年**月**日**：**：**：**
    uint16_t Start_UcUnderLimit;				//C相电压越低限启动录波：**年**月**日**：**：**：**
    uint16_t Start_VoltageOverLimit;			//相电压越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_UaOverLimit;					//A相电压越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_UbOverLimit;					//B相电压越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_UcOverLimit;					//C相电压越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_UoOverLimit;					//零序电压越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_U2OverLimit;					//负序电压越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_CurrentOverLimit;			//相电流越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_IaOverLimit;					//A相电流越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_IbOverLimit;					//B相电流越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_IcOverLimit;					//C相电流越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_IoOverLimit;					//零序电流越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_I2OverLimit;					//负序电流越高限启动录波：**年**月**日**：**：**：**
    uint16_t Start_LowFrequency;				//频率越低限启动录波	Hz	45~49.9
    uint16_t Start_HighFrequency;				//频率越高限启动录波	Hz	50.1~55
    uint16_t Start_FrequencyGradient;		//频率变化率越限启动录波	Hz/s	0.3~3.0
    uint16_t Start_HarmonicU_Order2;		//2次谐波电压启动录波	%UN	2~50
    uint16_t Start_HarmonicU_Order3;		//3次谐波电压启动录波	%UN	2~50
    uint16_t Start_HarmonicU_Order5;		//5次谐波电压启动录波	%UN	2~50
    uint16_t Start_HarmonicU_Order7;		//5次谐波电压启动录波	%UN	2~50
    uint16_t Start_HarmonicI_Order2;		//2次谐波电流启动录波	%UN	2~50
    uint16_t Start_HarmonicI_Order3;		//3次谐波电流启动录波	%UN	2~50
    uint16_t Start_HarmonicI_Order5;		//5次谐波电流启动录波	%UN	2~50
    uint16_t Start_HarmonicI_Order7;		//5次谐波电流启动录波	%UN	2~50
    uint16_t Start_ReversePowerLimit;		//逆功率启动录波	%PN	5~50
    uint16_t Start_OverExcitation;			//过励磁V/f启动录波	pu	1.1~1.5
    uint16_t ActValue_VoltageMutation;  // 电压突变量：A相xxx.xxV   B相xxx.xxV   C相xxx.xxV
    uint16_t ActValue_CurrentMutation;  // 电流突变量：A相xxx.xxA   B相xxx.xxA   C相xxx.xxA
    uint16_t ActValue_UoMutation;     	// 零序电压突变量：xxx.xxV
    uint16_t ActValue_IoMutation;     	// 零序电流突变量：xxx.xxA
    uint16_t ActValue_3PhaseVoltage;    // 三相电压：A相xxx.xxV   B相xxx.xxV   C相xxx.xxV
    uint16_t ActValue_Uo;     					// 零序电压：xxx.xxV
    uint16_t ActValue_U2;     					// 负序电压：xxx.xxV
    uint16_t ActValue_3PhaseCurrent;    // 三相电流：A相xxx.xxA   B相xxx.xxA   C相xxx.xxA
    uint16_t ActValue_Io;     					// 零序电流：xxx.xxA
    uint16_t ActValue_I2;     					// 负序电流：xxx.xxA
    uint16_t ActValue_Frequency;    		// 三相电压频率：A相xx.xxxHz   B相xx.xxxHz   C相xx.xxxHz
    uint16_t ActValue_DeltaFrequency;      // 三相电压频率变化率：A相xx.xxxHz/s   B相xx.xxxHz/s   C相xx.xxxHz/s
    uint16_t ActValue_HarmonicU_Order2; // 三相电压2次谐波含量：A相xx.x%   B相xx.x%   C相xx.x%
    uint16_t ActValue_HarmonicU_Order3; // 三相电压3次谐波含量：A相xx.x%   B相xx.x%   C相xx.x%
    uint16_t ActValue_HarmonicU_Order5; // 三相电压5次谐波含量：A相xx.x%   B相xx.x%   C相xx.x%
    uint16_t ActValue_HarmonicU_Order7; // 三相电压7次谐波含量：A相xx.x%   B相xx.x%   C相xx.x%
    uint16_t ActValue_HarmonicI_Order2; // 三相电流2次谐波含量：A相xx.x%   B相xx.x%   C相xx.x%
    uint16_t ActValue_HarmonicI_Order3; // 三相电流3次谐波含量：A相xx.x%   B相xx.x%   C相xx.x%
    uint16_t ActValue_HarmonicI_Order5; // 三相电流5次谐波含量：A相xx.x%   B相xx.x%   C相xx.x%
    uint16_t ActValue_HarmonicI_Order7; // 三相电流7次谐波含量：A相xx.x%   B相xx.x%   C相xx.x%
    uint16_t ActValue_3PhasePower;    	// 三相有功功率：A相±xxx.xxKW   B相±xxx.xxKW   C相±xxx.xxKW
    uint16_t ActValue_Excitation;    	  // 励磁V/f： xx.xxxPU
};
#pragma pack(pop)
} // namespace jybsmr131
