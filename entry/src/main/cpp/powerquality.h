#ifndef POWERQUALITY_H
#define POWERQUALITY_H

#include <iostream>
#include "quality.h"

typedef struct
{
    // 频率偏差
    float FreqDeviation_A;        // A相：xx.xxxHz
    float FreqDeviation_B;        // B相：xx.xxxHz
    float FreqDeviation_C;        // C相：xx.xxxHz
    float FreqDeviation_All;      // 总频率偏差：xx.xxxHz
    float FreqQualifiRate_A;      // 频率日合格率：xx.xxx% 数据库中每日存一次，用于统计周/月/季/年合格率
    float FreqQualifiRate_B;      // 频率日合格率：xx.xxx% 数据库中每日存一次，用于统计周/月/季/年合格率
    float FreqQualifiRate_C;      // 频率日合格率：xx.xxx% 数据库中每日存一次，用于统计周/月/季/年合格率
    float FreqQualifiRate_All;    // 频率日合格率：xx.xxx% 数据库中每日存一次，用于统计周/月/季/年合格率

    // 电压偏差
    float VoltageDeviation_A;     // A相：xx.xx%
    float VoltageDeviation_B;     // B相：xx.xx%
    float VoltageDeviation_C;     // C相：xx.xx%
    float VoltageDeviation_AB;    // AB相：xx.xx%
    float VoltageDeviation_BC;    // BC相：xx.xx%
    float VoltageDeviation_CA;    // CA相：xx.xx%
    float VoltageQualifiRate_A;   // 电压日合格率：xx.xx% 数据库中每日存一次，用于统计周/月/季/年合格率
    float VoltageQualifiRate_B;   // 电压日合格率：xx.xx% 数据库中每日存一次，用于统计周/月/季/年合格率
    float VoltageQualifiRate_C;   // 电压日合格率：xx.xx% 数据库中每日存一次，用于统计周/月/季/年合格率
    float VoltageQualifiRate_All; // 电压日合格率：xx.xx% 数据库中每日存一次，用于统计周/月/季/年合格率

    // 不平衡度
    float Voltage_U1;       // 正序电压
    float Voltage_U2;       // 负序电压
    float Voltage_Uo;       // 零序电压
    float Current_I1;       // 正序电流
    float Current_I2;       // 负序电流
    float Current_Io;       // 零序电流

    float Voltage_U2_Unbalance;    // 电压负序不平衡度
    float Voltage_Uo_Unbalance;    // 电压零序不平衡度
    float Current_I2_Unbalance;    // 电流负序不平衡度
    float Current_In_Unbalance;    // 电流零序不平衡度

    // 电压波动
    float VoltageFluct_A;        // A相：xx.xx%
    float VoltageFluct_B;        // B相：xx.xx%
    float VoltageFluct_C;        // C相：xx.xx%
    float VoltageFluctFreq_A;    // 波动频次:xxxx次/小时
    float VoltageFluctFreq_B;    // 波动频次:xxxx次/小时
    float VoltageFluctFreq_C;    // 波动频次:xxxx次/小时

    // 电压闪变
    float VoltageShortFlicke_A;    // A相短闪变：xx.xxx
    float VoltageShortFlicke_B;    // B相短闪变：xx.xxx
    float VoltageShortFlicke_C;    // C相短闪变：xx.xxx
    float VoltageLongFlicke_A;     // A相长闪变：xx.xxx
    float VoltageLongFlicke_B;     // B相长闪变：xx.xxx
    float VoltageLongFlicke_C;     // C相长闪变：xx.xxx

    // 电流总谐波含量
    float CurrentTHD_A;       //A相总谐波畸变率
    float CurrentTHD_B;       //B相总谐波畸变率
    float CurrentTHD_C;       //C相总谐波畸变率
    float CurrentOddTHD_A;    //A相总奇次谐波畸变率
    float CurrentOddTHD_B;    //B相总奇次谐波畸变率
    float CurrentOddTHD_C;    //C相总奇次谐波畸变率
    float CurrentEvenTHD_A;   //A相总偶次谐波畸变率
    float CurrentEvenTHD_B;   //B相总偶次谐波畸变率
    float CurrentEvenTHD_C;   //C相总偶次谐波畸变率
    float CurrentInterTHD_A;  //A相总间谐波畸变率
    float CurrentInterTHD_B;  //B相总间谐波畸变率
    float CurrentInterTHD_C;  //C相总间谐波畸变率

    //全波有效值
    float FullWave_Ua;        //A相全波电压有效值
    float FullWave_Ub;        //B相全波电压有效值
    float FullWave_Uc;        //C相全波电压有效值
    float FullWave_Uab;       //AB相全波电压有效值
    float FullWave_Ubc;       //BC相全波电压有效值
    float FullWave_Uca;       //CA相全波电压有效值
    float FullWave_Ia;        //A相全波电流有效值
    float FullWave_Ib;        //B相全波电流有效值
    float FullWave_Ic;        //C相全波电流有效值

    // 电压总谐波含量
    float VoltageTHD_A;       //A相总谐波畸变率
    float VoltageTHD_B;       //B相总谐波畸变率
    float VoltageTHD_C;       //C相总谐波畸变率
    float VoltageOddTHD_A;    //A相总奇次谐波畸变率
    float VoltageOddTHD_B;    //B相总奇次谐波畸变率
    float VoltageOddTHD_C;    //C相总奇次谐波畸变率
    float VoltageEvenTHD_A;   //A相总偶次谐波畸变率
    float VoltageEvenTHD_B;   //B相总偶次谐波畸变率
    float VoltageEvenTHD_C;   //C相总偶次谐波畸变率
    float VoltageInterTHD_A;  //A相总间谐波畸变率
    float VoltageInterTHD_B;  //B相总间谐波畸变率
    float VoltageInterTHD_C;  //C相总间谐波畸变率

    // 谐波峰值因子
    float PeakFactor_Ua;      //A相电压峰值因子
    float PeakFactor_Ub;      //B相电压峰值因子
    float PeakFactor_Uc;      //C相电压峰值因子
    float PeakFactor_Ia;      //A相电流峰值因子
    float PeakFactor_Ib;      //B相电流峰值因子
    float PeakFactor_Ic;      //C相电流峰值因子

    //总谐波功率
    float PowerP_THD_A;       //A相总谐波有功功率
    float PowerP_THD_B;       //B相总谐波有功功率
    float PowerP_THD_C;       //C相总谐波有功功率
    float PowerQ_THD_A;       //A相总谐波无功功率
    float PowerQ_THD_B;       //B相总谐波无功功率
    float PowerQ_THD_C;       //C相总谐波无功功率
    float PowerS_THD_A;       //A相总谐波视在功率
    float PowerS_THD_B;       //B相总谐波视在功率
    float PowerS_THD_C;       //C相总谐波视在功率
    float PowerF_THD_A;       //A相总谐波功率因数
    float PowerF_THD_B;       //B相总谐波功率因数
    float PowerF_THD_C;       //C相总谐波功率因数

    // 全波功率
    float FullWave_Pa;       //A相全波有功功率
    float FullWave_Pb;       //B相全波有功功率
    float FullWave_Pc;       //C相全波有功功率
    float FullWave_Pt;       //合相全波有功功率

    float FullWave_Qa;       //A相全波无功功率
    float FullWave_Qb;       //B相全波无功功率
    float FullWave_Qc;       //C相全波无功功率
    float FullWave_Qt;       //合相全波无功功率

    float FullWave_Sa;       //A相全波视在功率
    float FullWave_Sb;       //B相全波视在功率
    float FullWave_Sc;       //C相全波视在功率
    float FullWave_St;       //合相全波视在功率

    float FullWave_Fa;       //A相全波功率因数
    float FullWave_Fb;       //B相全波功率因数
    float FullWave_Fc;       //C相全波功率因数
    float FullWave_Ft;       //合相全波功率因数
}PowerQualityIndicator_struct;
//extern PowerQualityIndicator_struct PowerQualityIndicator;

//谐波数据结构，谐波功率计算得到，所有数据在数据库中每3s存一个记录
typedef struct {
    float Rms[63];
    float Angle[63];
} HarmonicDistortion_struct;
extern HarmonicDistortion_struct HD_Ua1,HD_Ub1,HD_Uc1;		//谐波,0~62为1~63次谐波,1为线路1
extern HarmonicDistortion_struct HD_Ia1,HD_Ib1,HD_Ic1;		//谐波
extern HarmonicDistortion_struct IHD_Ua1,IHD_Ub1,IHD_Uc1;	//间谐波
extern HarmonicDistortion_struct IHD_Ia1,IHD_Ib1,IHD_Ic1;	//间谐波


typedef struct {
  float P;			//有功功率
  float Q;			//无功功率
  float S;			//视在功率
  float F;			//功率因数
} HarmonicPower_struct;

/******************************************************************************/
/*************************电能质量定值数据结构**********************************/
/******************************************************************************/
// PQSettingUnit、PowerQualitySetting_struct 使用 quality.h 中已有的同名定义。
//#define PowerQualitySetting_DataLen 200;



/******************************************************************************/
/*************************电能质量报告数据结构*********************************/
/******************************************************************************/
typedef struct
{
  uint16_t Start_VoltageUnbalance;      // 电压不平衡越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageDeviation;      // 电压偏差越限启动：**年**月**日**：**：**：**
  uint16_t Start_FreqDeviation;         // 频率偏差越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageShortFlicke;    // 电压短闪变越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageLongFlicke;     // 电压长闪变越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageFluct;          // 电压波动越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageSeg;            // 电压暂降启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageSwell;          // 电压暂升启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageTHD;            // 电压总谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageOddTHD;         // 电压总奇次谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageEvenTHD;        // 电压总偶次谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageOddHAR;         // 电压单一奇次谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageEvenHAR;        // 电压单一偶次谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageInterTHD;       // 电压总间谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_VoltageInterHAR;       // 电压单一间谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_CurrentUnbalance;      // 电流不平衡越限启动：**年**月**日**：**：**：**
  uint16_t Start_CurrentTHD;            // 电流总谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_CurrentOddTHD;         // 电流总奇次谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_CurrentEvenTHD;        // 电流总偶次谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_CurrentOddHAR;         // 电流单一奇次谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_CurrentEvenHAR;        // 电流单一偶次谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_CurrentInterTHD;       // 电流总间谐波含量越限启动：**年**月**日**：**：**：**
  uint16_t Start_CurrentInterHAR;       // 电流单一间谐波含量越限启动：**年**月**日**：**：**：**

  uint16_t SetAlarm_VoltageUnbalance;   // 电压不平衡越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageDeviation;   // 电压偏差越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_FreqDeviation;      // 频率偏差越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageShortFlicke; // 电压短闪变越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageLongFlicke;  // 电压长闪变越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageFluct;       // 电压波动越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageSeg;         // 电压暂降告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageSwell;       // 电压暂升告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageTHD;         // 电压总谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageOddTHD;      // 电压总奇次谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageEvenTHD;     // 电压总偶次谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageOddHAR;      // 电压单一奇次谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageEvenHAR;     // 电压单一偶次谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageInterTHD;    // 电压总间谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_VoltageInterHAR;    // 电压单一间谐波含量越限告警：**年**月**日**：**：**：**

  uint16_t SetAlarm_CurrentUnbalance; // 电流不平衡越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_CurrentTHD;       // 电流总谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_CurrentOddTHD;    // 电流总奇次谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_CurrentEvenTHD;   // 电流总偶次谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_CurrentOddHAR;    // 电流单一奇次谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_CurrentEvenHAR;   // 电流单一偶次谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_CurrentInterTHD;  // 电流总间谐波含量越限告警：**年**月**日**：**：**：**
  uint16_t SetAlarm_CurrentInterHAR;  // 电流单一间谐波含量越限告警：**年**月**日**：**：**：**

  uint16_t ResetAlarm_VoltageUnbalance;   // 电压不平衡越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageDeviation;   // 电压偏差越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_FreqDeviation;      // 频率偏差越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageShortFlicke; // 电压短闪变越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageLongFlicke;  // 电压长闪变越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageFluct;       // 电压波动越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageSeg;         // 电压暂降告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageSwell;       // 电压暂升告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageTHD;         // 电压总谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageOddTHD;      // 电压总奇次谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageEvenTHD;     // 电压总偶次谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageOddHAR;      // 电压单一奇次谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageEvenHAR;     // 电压单一偶次谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageInterTHD;    // 电压总间谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_VoltageInterHAR;    // 电压单一间谐波含量越限告警返回：**年**月**日**：**：**：**

  uint16_t ResetAlarm_CurrentUnbalance;   // 电流不平衡越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_CurrentTHD;         // 电流总谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_CurrentOddTHD;      // 电流总奇次谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_CurrentEvenTHD;     // 电流总偶次谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_CurrentOddHAR;      // 电流单一奇次谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_CurrentEvenHAR;     // 电流单一偶次谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_CurrentInterTHD;    // 电流总间谐波含量越限告警返回：**年**月**日**：**：**：**
  uint16_t ResetAlarm_CurrentInterHAR;    // 电流单一间谐波含量越限告警返回：**年**月**日**：**：**：**

  uint16_t ActValue_VoltageUnbalance;     // 电压不平衡度：负序不平衡度：xx.xx%   零序不平衡度：xx.xx%
  uint16_t ActValue_SequenceVoltage;      // 电压序分量：正序电压：xxx.xxV  负序电压：xxx.xxV  零序电压：xxx.xxV
  uint16_t ActValue_FreqDeviation;        // 三相电压频率：A相xx.xxxHz   A相xx.xxxHz   A相xx.xxxHz
  uint16_t ActValue_VoltageDeviation;     // 三相电压：A相xx.xxxV   A相xx.xxxV   A相xx.xxxV
  uint16_t ActValue_VoltageFluct;         // 三相电压波动值：A相xx.xx%   A相xx.xx%   A相xx.xx%
  uint16_t ActValue_VoltageFluct_Freq;    // 三相电压波动频次：A相xxxx次/小时   A相xxxx次/小时   A相xxxx次/小时
  uint16_t ActValue_VoltageSegValue;      // 三相电压暂降值：A相xx.xx%   A相xx.xx%   A相xx.xx%
  uint16_t ActValue_VoltageSegTime;       // 电压暂降持续时间：xxxxms
  uint16_t ActValue_VoltageSwellValue;    // 三相电压暂升值：A相xx.xx%   A相xx.xx%   A相xx.xx%
  uint16_t ActValue_VoltageSwellTime;     // 电压暂升持续时间：xxxxms
  uint16_t ActValue_VoltageShortFlicke;   // 三相电压短闪变值：A相xx.xx   A相xx.xx   A相xx.xx
  uint16_t ActValue_VoltageLongFlicke;    // 三相电压长闪变值：A相xx.xx   A相xx.xx   A相xx.xx
  uint16_t ActValue_VoltageTHD;           // 三相电压总谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_VoltageOddTHD;        // 三相电压总奇次谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_VoltageEvenTHD;       // 三相电压总偶次谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_VoltageOddHAR;        // 三相电压最大奇次谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_VoltageEvenHAR;       // 三相电压最大偶次谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_VoltageHAR_Order;     // 三相电压最大谐波频率：xx.xxHz   xx.xxHz   xx.xxHz
  uint16_t ActValue_VoltageInterTHD;      // 三相电压总间谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_VoltageInterHAR;      // 三相电压最大间谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_VoltageInterHAR_Order;// 三相电压最大间谐波频率：xx.xxHz   xx.xxHz   xx.xxHz

  uint16_t ActValue_CurrentUnbalance;     // 电流不平衡度：负序不平衡度：xx.xx%   零序不平衡度：xx.xx%
  uint16_t ActValue_SequenceCurrent;      // 电流序分量：正序电流：xxx.xxA  负序电流：xxx.xxA  零序电流：xxx.xxA
  uint16_t ActValue_CurrentTHD;           // 三相电流总谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_CurrentOddTHD;        // 三相电流总奇次谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_CurrentEvenTHD;       // 三相电流总偶次谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_CurrentOddHAR;        // 三相电流最大奇次谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_CurrentEvenHAR;       // 三相电流最大偶次谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_CurrentHAR_Order;     // 三相电流最大谐波频率：xx.xxHz   xx.xxHz   xx.xxHz
  uint16_t ActValue_CurrentInterTHD;      // 三相电流总间谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_CurrentInterHAR;      // 三相电流最大间谐波含量：xx.xx%   xx.xx%   xx.xx%
  uint16_t ActValue_CurrentInterHAR_Order;// 三相电流最大间谐波频率：xx.xxHz   xx.xxHz   xx.xxHz
} PowerQualityReportCode_Struct;
extern PowerQualityReportCode_Struct PowerQualityCode;
/*
void init_PowerQualityReportCode(void)
{
  PowerQualityCode.Start_VoltageUnbalance = 0x8001;   // 电压不平衡越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageDeviation = 0x8002;   // 电压偏差越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_FreqDeviation = 0x8003;      // 频率偏差越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageShortFlicke = 0x8004; // 电压短闪变越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageLongFlicke = 0x8005;  // 电压长闪变越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageFluct = 0x8006;       // 电压波动越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageSeg = 0x8007;         // 电压暂降启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageSwell = 0x8008;       // 电压暂升启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageTHD = 0x8009;         // 电压总谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageOddTHD = 0x800A;      // 电压总奇次谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageEvenTHD = 0x800B;     // 电压总偶次谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageOddHAR = 0x800C;      // 电压单一奇次谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageEvenHAR = 0x800D;     // 电压单一偶次谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageInterTHD = 0x800E;    // 电压总间谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_VoltageInterHAR = 0x800F;    // 电压单一间谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_CurrentUnbalance = 0x8010;   // 电流不平衡越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_CurrentTHD = 0x8011;         // 电流总谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_CurrentOddTHD = 0x8012;      // 电流总奇次谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_CurrentEvenTHD = 0x8013;     // 电流总偶次谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_CurrentOddHAR = 0x8014;      // 电流单一奇次谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_CurrentEvenHAR = 0x8015;     // 电流单一偶次谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_CurrentInterTHD = 0x8016;    // 电流总间谐波含量越限启动：**年**月**日**：**：**：**
  PowerQualityCode.Start_CurrentInterHAR = 0x8017;    // 电流单一间谐波含量越限启动：**年**月**日**：**：**：**

  PowerQualityCode.SetAlarm_VoltageUnbalance = 0x8101;   // 电压不平衡越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageDeviation = 0x8102;   // 电压偏差越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_FreqDeviation = 0x8103;      // 频率偏差越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageShortFlicke = 0x8104; // 电压短闪变越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageLongFlicke = 0x8105;  // 电压长闪变越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageFluct = 0x8106;       // 电压波动越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageSeg = 0x8107;         // 电压暂降告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageSwell = 0x8108;       // 电压暂升告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageTHD = 0x8109;         // 电压总谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageOddTHD = 0x810A;      // 电压总奇次谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageEvenTHD = 0x810B;     // 电压总偶次谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageOddHAR = 0x810C;      // 电压单一奇次谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageEvenHAR = 0x810D;     // 电压单一偶次谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageInterTHD = 0x810E;    // 电压总间谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_VoltageInterHAR = 0x810F;    // 电压单一间谐波含量越限告警：**年**月**日**：**：**：**

  PowerQualityCode.SetAlarm_CurrentUnbalance = 0x8110; // 电流不平衡越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_CurrentTHD = 0x8111;       // 电流总谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_CurrentOddTHD = 0x8112;    // 电流总奇次谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_CurrentEvenTHD = 0x8113;   // 电流总偶次谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_CurrentOddHAR = 0x8114;    // 电流单一奇次谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_CurrentEvenHAR = 0x8115;   // 电流单一偶次谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_CurrentInterTHD = 0x8116;  // 电流总间谐波含量越限告警：**年**月**日**：**：**：**
  PowerQualityCode.SetAlarm_CurrentInterHAR = 0x8117;  // 电流单一间谐波含量越限告警：**年**月**日**：**：**：**

  PowerQualityCode.ResetAlarm_VoltageUnbalance = 0x8201;   // 电压不平衡越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageDeviation = 0x8202;   // 电压偏差越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_FreqDeviation = 0x8203;      // 频率偏差越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageShortFlicke = 0x8204; // 电压短闪变越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageLongFlicke = 0x8205;  // 电压长闪变越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageFluct = 0x8206;       // 电压波动越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageSeg = 0x8207;         // 电压暂降告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageSwell = 0x8208;       // 电压暂升告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageTHD = 0x8209;         // 电压总谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageOddTHD = 0x820A;      // 电压总奇次谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageEvenTHD = 0x820B;     // 电压总偶次谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageOddHAR = 0x820C;      // 电压单一奇次谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageEvenHAR = 0x820D;     // 电压单一偶次谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageInterTHD = 0x820E;    // 电压总间谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_VoltageInterHAR = 0x820F;    // 电压单一间谐波含量越限告警返回：**年**月**日**：**：**：**

  PowerQualityCode.ResetAlarm_CurrentUnbalance = 0x8210; // 电流不平衡越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_CurrentTHD = 0x8211;       // 电流总谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_CurrentOddTHD = 0x8212;    // 电流总奇次谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_CurrentEvenTHD = 0x8213;   // 电流总偶次谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_CurrentOddHAR = 0x8214;    // 电流单一奇次谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_CurrentEvenHAR = 0x8215;   // 电流单一偶次谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_CurrentInterTHD = 0x8216;  // 电流总间谐波含量越限告警返回：**年**月**日**：**：**：**
  PowerQualityCode.ResetAlarm_CurrentInterHAR = 0x8217;  // 电流单一间谐波含量越限告警返回：**年**月**日**：**：**：**

  PowerQualityCode.ActValue_VoltageUnbalance = 0x8301;      // 电压不平衡度：负序不平衡度：xx.xx%   零序不平衡度：xx.xx%
  PowerQualityCode.ActValue_SequenceVoltage = 0x8302;       // 电压序分量：正序电压：xxx.xxV  负序电压：xxx.xxV  零序电压：xxx.xxV
  PowerQualityCode.ActValue_FreqDeviation = 0x8303;         // 三相电压频率：A相xx.xxxHz   A相xx.xxxHz   A相xx.xxxHz
  PowerQualityCode.ActValue_VoltageDeviation = 0x8304;      // 三相电压：A相xx.xxxV   A相xx.xxxV   A相xx.xxxV
  PowerQualityCode.ActValue_VoltageFluct = 0x8305;          // 三相电压波动值：A相xx.xx%   A相xx.xx%   A相xx.xx%
  PowerQualityCode.ActValue_VoltageFluct_Freq = 0x8306;     // 三相电压波动频次：A相xxxx次/小时   A相xxxx次/小时   A相xxxx次/小时
  PowerQualityCode.ActValue_VoltageShortFlicke = 0x8307;    // 三相电压短闪变值：A相xx.xx   A相xx.xx   A相xx.xx
  PowerQualityCode.ActValue_VoltageLongFlicke = 0x8308;     // 三相电压长闪变值：A相xx.xx   A相xx.xx   A相xx.xx
  PowerQualityCode.ActValue_VoltageTHD = 0x8309;            // 三相电压总谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_VoltageOddTHD = 0x830A;         // 三相电压总奇次谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_VoltageEvenTHD = 0x830B;        // 三相电压总偶次谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_VoltageOddHAR = 0x830C;         // 三相电压最大奇次谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_VoltageEvenHAR = 0x830D;        // 三相电压最大偶次谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_VoltageHAR_Order = 0x830E;      // 三相电压最大谐波次数：xxx次   xxx次   xxx次
  PowerQualityCode.ActValue_VoltageInterTHD = 0x830F;       // 三相电压总间谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_VoltageInterHAR = 0x8310;       // 三相电压最大间谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_VoltageInterHAR_Order = 0x8311; // 三相电压最大间谐波频率：xx.xxHz   xx.xxHz   xx.xxHz
  PowerQualityCode.ActValue_VoltageSegValue = 0x8312;       // 三相电压暂降值：A相xx.xx%   A相xx.xx%   A相xx.xx%
  PowerQualityCode.ActValue_VoltageSegTime = 0x8313;        // 电压暂降持续时间：xxxxms
  PowerQualityCode.ActValue_VoltageSwellValue = 0x8314;     // 三相电压暂升值：A相xx.xx%   A相xx.xx%   A相xx.xx%
  PowerQualityCode.ActValue_VoltageSwellTime = 0x8315;      // 电压暂升持续时间：xxxxms

  PowerQualityCode.ActValue_CurrentUnbalance = 0x8412;      // 电流不平衡度：负序不平衡度：xx.xx%   零序不平衡度：xx.xx%
  PowerQualityCode.ActValue_SequenceCurrent = 0x8413;       // 电流序分量：正序电流：xxx.xxA  负序电流：xxx.xxA  零序电流：xxx.xxA
  PowerQualityCode.ActValue_CurrentTHD = 0x8414;            // 三相电流总谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_CurrentOddTHD = 0x8415;         // 三相电流总奇次谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_CurrentEvenTHD = 0x8416;        // 三相电流总偶次谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_CurrentOddHAR = 0x8417;         // 三相电流最大奇次谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_CurrentEvenHAR = 0x8418;        // 三相电流最大偶次谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_CurrentHAR_Order = 0x8419;      // 三相电流最大谐波次数：xxx次   xxx次   xxx次
  PowerQualityCode.ActValue_CurrentInterTHD = 0x841A;       // 三相电流总间谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_CurrentInterHAR = 0x841B;       // 三相电流最大间谐波含量：xx.xx%   xx.xx%   xx.xx%
  PowerQualityCode.ActValue_CurrentInterHAR_Order = 0x841C; // 三相电流最大间谐波频率：xx.xxHz   xx.xxHz   xx.xxHz
}
*/
/****************************************************************************/
/*-----------------  电能质量数据交换格式(PQDIF)定值  -----------------------*/
/****************************************************************************/
// 设置电能质量数据是否写入 PQDIF 文件：0——不写入，1——写入
typedef struct
{
    uint8_t PowerFrequencyEnable;		// 工频量测量
    uint8_t HarmonicVoltageEnable;		// 谐波电压测量
    uint8_t HarmonicCurrentEnable;		// 谐波电流测量
    uint8_t FrequencyEnable;			// 频率测量
    uint8_t VoltageUnbalanceEnable;		// 三相电压不平衡度
    uint8_t CurrentUnbalanceEnable;		// 三相电流不平衡度
    uint8_t VoltageFlickerEnable;		// 电压闪变
    uint8_t VoltageSagEnable;			// 电压暂降
    uint8_t VoltageInterruptionEnable;	// 电压短时中断
    uint8_t VoltageSwellEnable;			// 电压暂升
    uint16_t Reserved;					// 保留，补齐 4 字节对齐
    uint32_t CRC;						// 校验码
} CommonSetting_PQDIF_BSMR130;
extern CommonSetting_PQDIF_BSMR130 PQDIF_BSMR130;

#endif // POWERQUALITY_H
