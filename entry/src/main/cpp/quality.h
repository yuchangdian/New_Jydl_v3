#ifndef QUALITY_H
#define QUALITY_H

#include <cstdint>
#include <iostream>
//#include <QString>

typedef struct
{
    //频率偏差
    float  FreqDeviation_A;		//A相：xx.xxxHz
    float  FreqDeviation_B;		//B相：xx.xxxHz
    float  FreqDeviation_C;		//C相：xx.xxxHz
    float  FreqQualified_Rate;		//频率合格率：xx.xxxHz

    //电压偏差
    float  VoltageDeviation_A;	//A相：xx.xx%
    float  VoltageDeviation_B;	//A相：xx.xx%
    float  VoltageDeviation_C;	//A相：xx.xx%
    float  VoltageQualified_Rate;	//电压合格率：xx.xx%

    //不平衡度
    float  Voltage_U2_Unbalance;	//电压负序不平衡度
    float  Voltage_Uo_Unbalance;	//电压零序不平衡度
    float  Current_I2_Unbalance;	//电流负序不平衡度
    float  Current_Io_Unbalance;	//电流零序不平衡度

    //电压波动
    float  VoltageFluct_A;		//A相：xx.xxV，波动频率xx.xxHz
    float  VoltageFluct_B;		//A相：xx.xxV，波动频率xx.xxHz
    float  VoltageFluct_C;		//A相：xx.xxV，波动频率xx.xxHz
    float  VoltageFluctFreq_A;	//波动频率
    float  VoltageFluctFreq_B;	//波动频率
    float  VoltageFluctFreq_C;	//波动频率

    //电压闪变
    float  VoltageShortFlicke_A;	//A相：xx.xxx
    float  VoltageShortFlicke_B;	//A相：xx.xxx
    float  VoltageShortFlicke_C;	//A相：xx.xxx

    //电压总谐波含量
    float  VoltageTHD_A;	//A相：xx.xx%
    float  VoltageTHD_B;	//B相：xx.xx%
    float  VoltageTHD_C;	//C相：xx.xx%

    //电压最大单次谐波含量
    float  VoltageHAR_A;		//A相：xx.xx%，谐波频率xx.xxxHz
    float  VoltageHARFreq_A;	//谐波频率
    float  VoltageHAR_B;		//B相：xx.xx%，谐波频率xx.xxxHz
    float  VoltageHARFreq_B;	//谐波频率
    float  VoltageHAR_C;		//C相：xx.xx%，谐波频率xx.xxxHz
    float  VoltageHARFreq_C;	//谐波频率

    //电流总谐波含量
    float  CurrentTHD_A;
    float  CurrentTHD_B;
    float  CurrentTHD_C;

    //电流最大单次谐波含量
    float  CurrentHAR_A;		//A相：xx.xx%，谐波频率xx.xxxHz
    float  CurrentHARFreq_A;	//谐波频率
    float  CurrentHAR_B;		//B相：xx.xx%，谐波频率xx.xxxHz
    float  CurrentHARFreq_B;	//谐波频率
    float  CurrentHAR_C;		//C相：xx.xx%，谐波频率xx.xxxHz
    float  CurrentHARFreq_C;	//谐波频率
}PowerQuality_struct;
extern PowerQuality_struct PowerQuality;

/******************************************************************************/
/*************************电能质量定值数据结构**********************************/
/******************************************************************************/
typedef struct
{
    uint32_t Enable;
    float ActValue;
}PQSettingUnit;

// 保留旧名称，避免已有代码在迁移期间失效。
typedef PQSettingUnit PowerQualitySettingUnit;

typedef struct
{
    uint32_t VoltageRef_SegSwell;       // 暂降/暂升参考值：0 额定电压，1 滑动参考电压
    uint32_t RecoedSize_Normal;         // 正常状态录波长度，ms
    uint32_t RecoedSize_Violation;      // 越限状态录波长度，ms

    PQSettingUnit VoltageUnbalance;
    PQSettingUnit VoltageDeviation;
    PQSettingUnit FreqDeviation;
    PQSettingUnit VoltageShortFlicke;
    PQSettingUnit VoltageLongFlicke;
    PQSettingUnit VoltageFluct;
    PQSettingUnit VoltageSeg;
    PQSettingUnit VoltageSwell;
    PQSettingUnit VoltageTHD;
    PQSettingUnit VoltageOddTHD;
    PQSettingUnit VoltageEvenTHD;
    PQSettingUnit VoltageOddHAR;
    PQSettingUnit VoltageEvenHAR;
    PQSettingUnit VoltageInterTHD;
    PQSettingUnit VoltageInterHAR;
    PQSettingUnit CurrentUnbalance;
    PQSettingUnit CurrentTHD;
    PQSettingUnit CurrentOddTHD;
    PQSettingUnit CurrentEvenTHD;
    PQSettingUnit CurrentOddHAR;
    PQSettingUnit CurrentEvenHAR;
    PQSettingUnit CurrentInterTHD;
    PQSettingUnit CurrentInterHAR;

    uint32_t CRC;
}PowerQualitySetting_struct;
extern PowerQualitySetting_struct LegacyPowerQualitySetting;
extern PowerQualitySetting_struct LegacyPowerQualitySetting_Buf;

#endif // QUALITY_H
