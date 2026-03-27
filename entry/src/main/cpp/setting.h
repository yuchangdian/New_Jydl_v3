#ifndef __SETTING_H
#define __SETTING_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <iostream>
//#include <QString>
#include <complex.h>
#include <string>

#include "data.h"
#include "IEC104.h"
//#include "CommonToolkit.h"

#define SETTING_FILE_NAME "/data/RelaySetting_"
#define REPORT_SIGN_NAME "file.txt"
#define REPORT_ACTIVE_TXT "/data/report/"
#define SQLITE_HARMONIC_TABLE "harmonic"

#define SETTING_FILE_DIR "/data/"


#pragma pack(1)

extern std::string Password;


/*****************************************************************************/
/*----------------------------  一次系统参数定值  ----------------------------*/
/*****************************************************************************/
#define  Mode_CTConnectioin_3P 			0x00
#define  Mode_CTConnectioin_2P 			0x01

#define  Mode_Iosample_Exteral 			0x00
#define  Mode_Iosample_SelfGenerate 0x01

typedef struct
{
    uint32_t SystemGroundingMode;	// 系统中性点接地方式：SystemGroundingMode_SmallResistance(1)——小电阻接地方式
                                                                //										/SystemGroundingMode_SuppressionCoil(2)——消弧线圈接地方式
                                                                //									  /SystemGroundingMode_ResistanceAndCoil(3)——小电阻并消弧线圈接地方式

    float PTp_Bus_Primary;		// 母线相PT一次额定值：***.*kV
    float PTp_Bus_Secondary;	// 母线相PT二次额定值：****V
    float PTo_Bus_Primary;		// 母线零序PT一次额定值：***.*kV
    float PTo_Bus_Secondary;	// 母线零序PT二次额定值：****V

    float PT_Line_Primary;		// 线路PT一次额定值：***.*kV
    float PT_Line_Secondary;	// 线路PT二次额定值：****V
    uint32_t	PT_Line_Phase;	// 线路PT相别：Phase_A(1)——A相/Phase_B(2)——B相/Phase_C(3)——C相
                                                        //						/Phase_AB(4)——AB相/Phase_BC(5)——BC相/Phase_CA(6)——CA相/Phase_ABC(7)——三相

    float CTp_Protection_Primary;		// 保护CT一次额定值：****A
    float CTp_Protection_Secondary;	// 保护CT二次额定值：****A
    float CTo_Primary;							// 零序CT一次额定值：****A
    float CTo_Secondary;						// 零序CT二次额定值：****A

    float CTp_Measure_Primary;		// 测量CT一次额定值：****A
    float CTp_Measure_Secondary;	// 测量CT二次额定值：****A

    uint32_t 	Mode_CTConnectioin;	// CT接线方式：Mode_CTConnectioin_3P(0)——三相式/Mode_CTConnectioin_2P(1)——两相式
    uint32_t 	Mode_Iosample;			// 零序电流采集模式：Mode_Iosample_Exteral(0)——外部/Mode_Iosample_SelfGenerate(1)——自产
    float 		RatedPower_Line;		// 线路额定容量：****kVA

    uint32_t	CRC;	//校验码
}CommonSetting_PrimarySystem_Struct;
extern CommonSetting_PrimarySystem_Struct  PrimarySystemSetting;
extern bool PrimarySystemSettingReady;
extern uint32_t CommonSetting_PrimarySystem_Length_1Byte;			// 一次系统参数定值长度（单位：字节）
extern uint32_t CommonSetting_PrimarySystem_CRCLength_4Byte;	// 一次系统参数定值CRC长度（单位：4字节）

/*****************************************************************************/
/*-----------------------------  PT/CT变比定值  -----------------------------*/
/*****************************************************************************/
typedef struct
{
    float PTp_Bus;
    float PTo_Bus;
    float PT_Line;
    float CTp_Protection;
    float CTo;
    float CTp_Measure;
}CommonSetting_PTCT_Ratio_Struct;

/*****************************************************************************/
/*------------------------------  模拟量参数定值  ----------------------------*/
/*****************************************************************************/
typedef struct
{
    float Ua, Ub, Uc, Uo;
    float IA, IB, IC, Io;
    float	Ia, Ib, Ic, Is;
    float Ux, Iby1, Iby2, Iby3;
}CommonSetting_AnalogQuantity_Parameter_Struct;

typedef struct
{
    CommonSetting_AnalogQuantity_Parameter_Struct Reference;		// 模拟量——基准值
    CommonSetting_AnalogQuantity_Parameter_Struct Correction;		// 模拟量——修正值
    CommonSetting_AnalogQuantity_Parameter_Struct ZeroDrift;		// 模拟量——零漂值

    uint32_t CRC;	//校验码
}CommonSetting_AnalogQuantity_Struct;
extern CommonSetting_AnalogQuantity_Struct AnalogQuantitySetting;
extern bool AnalogQuantitySettingReady;
extern uint32_t CommonSetting_AnalogQuantity_Length_1Byte;		// 模拟量参数定值长度（单位：字节）;
extern uint32_t CommonSetting_AnalogQuantity_CRCLength_4Byte;	// 模拟量参数定值CRC长度（单位：4字节）;

/*****************************************************************************/
/*-------------------------------  遥测参数定值  -----------------------------*/
/*****************************************************************************/
typedef struct
{
    float Cycle_Detection;			// 遥测变化检测周期：**.**s
    float DeadBand_Frequency;		// 频率死区：**.**%
    float DeadBand_ACvoltage;		// 交流电压死区：**.**%
    float DeadBand_DCvoltage;		// 直流电压死区：**.**%
    float DeadBand_ACcurrent;		// 交流电流死区：**.**%
    float DeadBand_Power;				// 功率死区：**.**%
    float DeadBand_PowerFactor;	// 功率因数死区：**.**%

    uint32_t	Enable_PrimaryEnergy;			// 电度量上送值：0——二次值/1——一次值

    uint32_t	CRC;	//校验码
}CommonSetting_TeleMeasuring_Struct;
extern CommonSetting_TeleMeasuring_Struct TeleMeasuringSetting;
extern bool TeleMeasuringSettingReady;
extern uint32_t CommonSetting_YC_Length_1Byte;		// 遥测参数定值长度（单位：字节）;
extern uint32_t CommonSetting_YC_CRCLength_4Byte;	// 遥测参数定值CRC长度（单位：4字节）;

/*****************************************************************************/
/*-------------------------------  遥信参数定值  -----------------------------*/
/*****************************************************************************/
typedef struct
{
    uint32_t 	YX01_Time;		//遥信01防抖时限：***.**ms（级差：0.5ms）
    uint32_t 	YX02_Time;		//遥信02防抖时限：***.**ms（级差：0.5ms）
    uint32_t 	YX03_Time;		//遥信03防抖时限：***.**ms（级差：0.5ms）
    uint32_t 	YX04_Time;		//遥信04防抖时限：***.**ms（级差：0.5ms）
    uint32_t 	YX05_Time;		//遥信05防抖时限：***.**ms（级差：0.5ms）
    uint32_t 	YX06_Time;		//遥信06防抖时限：***.**ms（级差：0.5ms）
    uint32_t 	YX07_Time;		//遥信07防抖时限：***.**ms（级差：0.5ms）
    uint32_t 	YX08_Time;		//遥信08防抖时限：***.**ms（级差：0.5ms）

    uint32_t	Enable_Logic;	// 开入量采集逻辑：0-原值/1-取反/2-屏蔽（使能控制字）
                                                    // 								原值——遥信上送为原值；取反——遥信上送为原值取反

    uint32_t	CRC;	//校验码
}CommonSetting_TeleSignaling_Struct;
extern CommonSetting_TeleSignaling_Struct TeleSignalingSetting;
extern bool TeleSignalingSettingReady;
extern uint32_t CommonSetting_YX_Length_1Byte;		// 遥信参数定值长度（单位：字节）;
extern uint32_t CommonSetting_YX_CRCLength_4Byte;	// 遥信参数定值CRC长度（单位：4字节）;

/*****************************************************************************/
/*-------------------------------  遥控参数定值  -----------------------------*/
/*****************************************************************************/
typedef struct
{
    uint32_t 	HoldingTime_YK1_XZ;		// 遥控1选择保持时间：***.**ms
    uint32_t 	HoldingTime_YK1_TZ;		// 遥控1分闸保持时间：***.**ms
    uint32_t 	HoldingTime_YK1_HZ;		// 遥控1合闸保持时间：***.**ms
    uint32_t 	HoldingTime_YK2_XZ;		// 遥控2选择保持时间：***.**ms
    uint32_t 	HoldingTime_YK2_TZ;		// 遥控2分闸保持时间：***.**ms
    uint32_t 	HoldingTime_YK2_HZ;		// 遥控2合闸保持时间：***.**ms

    //同期参数:
    float 		Sync_NoVoltage;						//无压定值：***.**V（输入值范围：    ）
    float 		Sync_ThereVoltage;				//有压定值：***.**V（输入值范围：    ）
    float 		Sync_Volue_VoltageDifferenceBlock;		//同期压差闭锁定值：***.**V（输入值范围：    ）
    float 		Sync_Volue_AngleDifferenceBlock;			//同期角差闭锁定值：***.**°（输入值范围：    ）
    float 		Sync_Volue_FrequencyDifferenceBlock;	//同期频差闭锁定值：***.**Hz（输入值范围：    ）
    uint32_t	Sync_DelayTime;												//同期等待时间：***.**s（输入值范围：    ）
    uint32_t 	Sync_BreakerCloseTime;								//断路器合闸时间：***.**ms（输入值范围：    ）
    uint32_t 	Sync_Enable_CloseMode_YK;							//遥控合闸方式：ReclosureMode_DisableReclosure(0)—闭锁
                                                                                                    //						/ReclosureMode_General(1)—普通
                                                                                                    //						/ReclosureMode_Synchronism(2)—检同期
                                                                                                    //						/ReclosureMode_LineNV_and_BusEV(3)—检线无压且母有压
                                                                                                    //						/ReclosureMode_LineEV_and_BusNV(4)—检线有压且母无压
                                                                                                    //						/ReclosureMode_LineNV_and_BusNV(5)—检线无压且母无压
                                                                                                    //						/ReclosureMode_LineNV_or_BusNV(6)—检线无压或母无压（*使能控制字）
    uint32_t	CRC;	//校验码
}CommonSetting_TeleControlling_Struct;
extern CommonSetting_TeleControlling_Struct TeleControllingSetting;
extern bool TeleControllingSettingReady;
extern uint32_t CommonSetting_YK_Length_1Byte;		// 遥控参数定值长度（单位：字节）;
extern uint32_t CommonSetting_YK_CRCLength_4Byte;	// 遥控参数定值CRC长度（单位：4字节）;

//TCont_Sync_Volue_VoltageDifferenceBlock

/*****************************************************************************/
/*-----------------------------  越限报警参数定值  ---------------------------*/
/*****************************************************************************/
typedef struct
{
    uint32_t 	Enable_LineVoltageExceedingUpperLimit;	// 线电压越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_LineVoltageExceedingUpperLimit;		// 线电压报警上限值：***.**V
    uint32_t  Enable_LineVoltageExceedingLowerLimit;	// 线电压越下限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_LineVoltageExceedingLowerLimit;		// 线电压报警下限值：***.**V

    uint32_t  Enable_ZeroSequenceVoltageExceedingUpperLimit;	// 零序电压越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_ZeroSequenceVoltageExceedingUpperLimit;		// 零序电压报警上限值：***.**V

    uint32_t  Enable_VoltageImbalanceRateExceedingUpperLimit;	// 电压不平衡率越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_VoltageImbalanceRateExceedingUpperLimit;	// 电压不平衡率报警上限值：***.**%

    uint32_t  Enable_PhaseCurrentExceedingUpperLimit;					// 相电流越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_PhaseCurrentExceedingUpperLimit;					// 相电流报警上限值：***.**A

    uint32_t  Enable_ZeroSequenceCurrentExceedingUpperLimit;	// 零序电流越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_ZeroSequenceCurrentExceedingUpperLimit;		// 零序电流报警上限值：***.**A

    uint32_t  Enable_CurrentImbalanceRateExceedingUpperLimit;	// 电流不平衡率越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_CurrentImbalanceRateExceedingUpperLimit;	// 电流不平衡率报警上限值：***.**%

    uint32_t  Enable_PhaseDifferentialCurrentExceedingUpperLimit;					// 相差流越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_PhaseDifferentialCurrentExceedingUpperLimit;					// 相差流报警上限值：***.**A

    uint32_t  Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit;	// 零序差流越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit;		// 零序差流报警上限值：***.**A

    uint32_t  Enable_LoadRateExceedingUpperLimit;			// 负载率越上限报警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_LoadRateRateExceedingUpperLimit;	// 负载率报警上限值：***.**%

    uint32_t	Time_Delay;															// 越限报警延时时间：***.**s

    uint32_t	CRC;	//校验码
}CommonSetting_ExceedingLimit_Struct;
extern CommonSetting_ExceedingLimit_Struct ExceedingLimitSetting;
extern bool ExceedingLimitSettingReady;
extern uint32_t CommonSetting_ExceedingLimit_Length_1Byte;		// 越限报警参数定值长度（单位：字节）;
extern uint32_t CommonSetting_ExceedingLimit_CRCLength_4Byte;	// 越限报警参数定值CRC长度（单位：4字节）;

/*****************************************************************************/
/*-------------------------------  统计参数定值  -----------------------------*/
/*****************************************************************************/
typedef struct
{
    uint32_t Enable_Bus;		// 母线统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t Enable_Line;		// 线路统计：Yes(1)-投入/No(0)-退出（使能控制字）

    uint32_t Enable_VoltageMaxValue;				// 电压极大值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_VoltageMaxValue;		// 电压极大值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_VoltageMaxValue;	// 电压极大值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_VoltageMinValue;				// 电压极小值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_VoltageMinValue;		// 电压极小值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_VoltageMinValue;	// 电压极小值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_VoltageOnTimeValue;				// 电压整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_VoltageOnTimeValue;		// 电压整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_VoltageOnTimeValue;	// 电压整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_VoltageImbalanceMaxValue;				// 电压不平衡极大值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_VoltageImbalanceMaxValue;		// 电压不平衡极大值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_VoltageImbalanceMaxValue;	// 电压不平衡极大值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_VoltageQualifiedRateOnTimeValue;				// 电压合格率整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_VoltageQualifiedRateOnTimeValue;		// 电压合格率整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_VoltageQualifiedRateOnTimeValue;	// 电压合格率整点值统计周期长度：****（无单位）

    uint32_t Enable_CurrentMaxValue;				// 电流极大值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_CurrentMaxValue;		// 电流极大值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_CurrentMaxValue;	// 电流极大值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_CurrentMinValue;				// 电流极小值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_CurrentMinValue;		// 电流极小值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_CurrentMinValue;	// 电流极小值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_CurrentOnTimeValue;				// 电流整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_CurrentOnTimeValue;		// 电流整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_CurrentOnTimeValue;	// 电流整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_CurrentImbalanceMaxValue;				// 电流不平衡极大值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_CurrentImbalanceMaxValue;		// 电流不平衡极大值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_CurrentImbalanceMaxValue;	// 电流不平衡极大值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_PowerMaxValue;				// 功率极大值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_PowerMaxValue;		// 功率极大值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_PowerMaxValue;	// 功率极大值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_PowerOnTimeValue;				// 功率整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_PowerOnTimeValue;		// 功率整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_PowerOnTimeValue;	// 功率整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_PowerFactorMaxValue;				// 功率因数极大值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_PowerFactorMaxValue;		// 功率因数极大值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_PowerFactorMaxValue;	// 功率因数极大值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_PowerFactorOnTimeValue;				// 功率因数整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_PowerFactorrOnTimeValue;		// 功率因数整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_PowerFactorOnTimeValue;	// 功率因数整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_LoadRateOnTimeValue;				// 负载率整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_LoadRateOnTimeValue;		// 负载率整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_LoadRateOnTimeValue;	// 负载率整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_PositiveActivePowerOnTimeValue;				// 正向有功整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_PositiveActivePowerOnTimeValue;		// 正向有功整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_PositiveActivePowerOnTimeValue;	// 正向有功整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_PositiveReactivePowerOnTimeValue;				// 正向无功整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_PositiveReactivePowerOnTimeValue;		// 正向无功整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_PositiveReactivePowerOnTimeValue;	// 正向无功整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_ReverseActivePowerOnTimeValue;				// 反向有功整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_ReverseActivePowerOnTimeValue;		// 反向有功整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_ReverseActivePowerOnTimeValue;	// 反向有功整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t Enable_ReverseReactivePowerOnTimeValue;				// 反向无功整点值统计：Yes(1)-投入/No(0)-退出（使能控制字）
    uint32_t PeriodType_ReverseReactivePowerOnTimeValue;		// 反向无功整点值统计周期类型：1—分钟级/2—小时级/3—日级
    uint32_t PeriodLength_ReverseReactivePowerOnTimeValue;	// 反向无功整点值统计周期长度：****（无单位，范围：1-366）

    uint32_t CRC;	//校验码
}CommonSetting_Statistics_Struct;
extern CommonSetting_Statistics_Struct StatisticsSetting;
extern bool StatisticsSettingReady;
extern uint32_t CommonSetting_Statistics_Length_1Byte;		// 统计参数定值长度（单位：字节）;
extern uint32_t CommonSetting_Statistics_CRCLength_4Byte;	// 统计参数定值CRC长度（单位：4字节）;

/*****************************************************************************/
/*-----------------------------  电能质量-告警定值  --------------------------*/
/*****************************************************************************/
typedef struct
{
    uint32_t  Enable_FrequencyDeviation;	// 频率偏差告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_FrequencyDeviation;		// 频率偏差告警定值：**.**Hz

    uint32_t  Enable_VoltageDeviation;		// 电压偏差告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_VoltageDeviation;			// 电压偏差告警定值：**.**%

    uint32_t  Enable_VoltageUnbalance;		// 电压不平衡告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_VoltageUnbalance;			// 电压不平衡告警定值：**.**%

    uint32_t  Enable_VoltageFluct;				// 电压波动告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_VoltageFluct;					// 电压波动告警定值：**.**V

    uint32_t	Enable_VoltageFlicke;				// 电压闪变告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_VoltageFlicke;				// 电压闪变告警定值：**.**（无单位）

    uint32_t  Enable_VoltageSeg;					// 电压暂降告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_VoltageSeg;						// 电压暂降告警定值：**.**%

    uint32_t  Enable_VoltageTHD;					// 电压总谐波含量超标告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_VoltageTHD;						// 电压总谐波含量超标告警定值：**.**%

    uint32_t  Enable_VoltageHAR;					// 电压单次谐波含量超标告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_VoltageHAR;						// 电压单次谐波含量超标告警定值：**.**%

    uint32_t  Enable_CurrentUnbalance;		// 电流不平衡告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_CurrentUnbalance;			// 电流不平衡告警定值：**.**%

    uint32_t  Enable_CurrentTHD;					// 电流总谐波含量超标告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_CurrentTHD;						// 电流总谐波含量超标告警定值：**.**%

    uint32_t  Enable_CurrentHAR;					// 电流单次谐波含量超标告警：Yes(1)-投入/No(0)-退出（使能控制字）
    float 		Value_CurrentHAR;						// 电流单次谐波含量超标告警定值：**.**%

    uint32_t CRC;	//校验码
}CommonSetting_PowerQuality_Struct;

extern uint16_t CommonSetting_PowerQuality_Length_1Byte;		// 电能质量-告警定值长度（单位：字节）;
extern uint16_t CommonSetting_PowerQuality_CRCLength_4Byte;	// 电能质量-告警定值CRC长度（单位：4字节）;

//---------------------------------------------------------------
typedef struct
{
    CommonSetting_PrimarySystem_Struct 			PrimarySystem, PrimarySystem_Buf;
    CommonSetting_PTCT_Ratio_Struct					PTCT_Ratio;
    CommonSetting_AnalogQuantity_Struct 		AnalogQuantity, AnalogQuantity_Buf;
    CommonSetting_TeleMeasuring_Struct 			YC, YC_Buf;
    CommonSetting_TeleSignaling_Struct			YX, YX_Buf;
    CommonSetting_TeleControlling_Struct 		YK, YK_Buf;
    CommonSetting_ExceedingLimit_Struct 		ExceedingLimit, ExceedingLimit_Buf;
    CommonSetting_Statistics_Struct 				Statistics, Statistics_Buf;
    CommonSetting_PowerQuality_Struct				PowerQuality, PowerQuality_Buf;

}CommonSetting_Struct;
extern CommonSetting_Struct CommonSetting;

//---------------------------------------------------------------
typedef struct
{
    CommonSetting_PrimarySystem_Struct 			PrimarySystem;
    CommonSetting_PTCT_Ratio_Struct				PTCT_Ratio;
    CommonSetting_AnalogQuantity_Struct 		AnalogQuantity;
    CommonSetting_TeleMeasuring_Struct 			YC;
    CommonSetting_TeleSignaling_Struct			YX;
    CommonSetting_TeleControlling_Struct 		YK;
    CommonSetting_ExceedingLimit_Struct 		ExceedingLimit;
    CommonSetting_Statistics_Struct 			Statistics;
    CommonSetting_PowerQuality_Struct			PowerQuality;

}CommonSetting_All_Struct;
extern CommonSetting_All_Struct CommonSetting_All;

/*****************************************************************************/
/*-------------------------  保护软压板定值数据结构  --------------------------*/
/*****************************************************************************/
typedef struct
{
    uint32_t	Enble_YT_SoftStrap;	// 远方投退软压板：Yes(1)-投入/No(0)-退出（使能控制字）

  uint32_t	Enble_YK;						// 遥控：Yes(1)-投入/No(0)-退出（使能控制字）

    uint32_t	Enble_YT_ModifyingSetting;			// 远方修改定值：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_YT_ModifyingSettingZone;	// 远方切换定值区：Yes(1)-投入/No(0)-退出（*使能控制字）

    //---------------  纵联保护
    uint32_t	Enble_Pilot_Current;				// 分相电流差动保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_Pilot_Io;							// 零序纵联保护：Yes(1)-投入/No(0)-退出（*使能控制字）

    //---------------  过电流保护
    uint32_t	Enble_OverCurrent_Z1;				// 过电流保护Ⅰ段：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_OverCurrent_Z2;				// 过电流保护Ⅱ段：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_OverCurrent_Z3;				// 过电流保护Ⅲ段：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_OverCurrent_Inv;			// 反时限过电流保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_OverCurrent_PTBreak;	// PT断线相过电流保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_OverCurrent_Acc;			// 过电流保护加速段：Yes(1)-投入/No(0)-退出（*使能控制字）

    //---------------  零序过流保护
    uint32_t	Enble_Io_Z1;	// 零序过流保护Ⅰ段：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_Io_Z2;	// 零序过流保护Ⅱ段：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_Io_Z3;	// 零序过流保护Ⅲ段：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_Io_Inv;	// 反时限零序过流保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_Io_Acc;	// 零序过流保护加速段：Yes(1)-投入/No(0)-退出（*使能控制字）

    //---------------  母线保护
    uint32_t	Enble_Bus;	// 母线保护：Yes(1)-停用/No(0)-投入（*使能控制字）

    //---------------  重合闸保护
    uint32_t	Enble_DisableReclosure;	// 重合闸保护：Yes(1)-停用/No(0)-投入（*使能控制字）

    //---------------  其它保护
    uint32_t	Enble_OverLoad;					// 过负荷保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_LowVoltage;				// 低电压保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_OverVoltage;			// 过电压保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_LowFrequency;			// 低频保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_HighFrequency;		// 高频保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_InversePower;			// 逆功率保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_HarmonicCurrent;	// 谐波电流保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_HarmonicVoltage;	// 谐波电压保护：Yes(1)-投入/No(0)-退出（*使能控制字）

    //---------------  GOOSE保护
    uint32_t	Enble_OverLoad_GOOSE;					// GOOSE过负荷保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_LowVoltage_GOOSE;				// GOOSE低电压保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_OverVoltage_GOOSE;			// GOOSE过电压保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_LowFrequency_GOOSE;			// GOOSE低频保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_HighFrequency_GOOSE;		// GOOSE高频保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_InversePower_GOOSE;			// GOOSE逆功率保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_HarmonicCurrent_GOOSE;	// GOOSE谐波电流保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enble_HarmonicVoltage_GOOSE;	// GOOSE谐波电压保护：Yes(1)-投入/No(0)-退出（*使能控制字）

    uint32_t CRC;
}ProtectionSoftStrap_Struct;
extern ProtectionSoftStrap_Struct ProtectionSoftStrap;
extern ProtectionSoftStrap_Struct ProtectionSoftStrap_Buf;

extern uint32_t SoftStrap_DataLength;
extern uint32_t SoftStrap_CRCLength;


/******************************************************************************/
/*---------------------------------  设备参数  -------------------------------*/
/******************************************************************************/
typedef struct		//设备参数
{
    float PT_Bus_Pri;
    float PT_Bus_Sec;

    float PT_Line_Pri;
    float PT_Line_Sec;

    uint32_t PT_Line_Phase;

    float CT_Protection_Pri;
    float CT_Protection_Sec;

    float CT_Zero_Pri;
    float CT_Zero_Sec;

    float CT_Measure_Pri;
    float CT_Measure_Sec;
    uint32_t CT_Measure_2Phase;

    uint8_t Onside_A_MAC[6];
    uint8_t Offside_A_MAC[6];

    uint8_t Onside_B_MAC[6];
    uint8_t Offside_B_MAC[6];

    uint32_t CRC;
}DeviceSetting_Struct;
extern DeviceSetting_Struct  DeviceSetting;
extern float ProtectionIn_Sec;
#define DeviceSetting_CRCLength		18
#define DeviceSetting_DataLength	76

/******************************************************************************/
/*--------------------------------  测控参数  ----------------------------------*/
/******************************************************************************/
typedef struct		//测控参数
{
	uint32_t Flag_EnergyPri;	//电度量上送一次值，1-一次值/0-二次值
	
	uint32_t YX01_Time;		//遥信开入01确认时间,单位：0.5ms
	uint32_t YX02_Time;		//遥信开入02确认时间,单位：0.5ms
	uint32_t YX03_Time;		//遥信开入03确认时间,单位：0.5ms
	uint32_t YX04_Time;		//遥信开入04确认时间,单位：0.5ms
	uint32_t YX05_Time;		//遥信开入05确认时间,单位：0.5ms
	uint32_t YX06_Time;		//遥信开入06确认时间,单位：0.5ms
	uint32_t YX07_Time;		//遥信开入07确认时间,单位：0.5ms
	uint32_t YX08_Time;		//遥信开入08确认时间,单位：0.5ms

	uint32_t YK_TZ1_Time;	//遥控跳闸1脉宽,单位：0.5ms
	uint32_t YK_HZ1_Time;	//遥控合闸1脉宽,单位：0.5ms
	uint32_t YK_TZ2_Time;	//遥控跳闸2脉宽,单位：0.5ms
	uint32_t YK_HZ2_Time;	//遥控合闸2脉宽,单位：0.5ms

	//同期参数:
	float Sync_ExistVoltage;	//有压定值：***.**V————输入值范围（ ）
	float Sync_NoVoltage;		//无压定值: ***.**V————输入值范围（ ）
	float Sync_DiffVoltage;		//同期压差闭锁定值***.**V————输入值范围（ ）
	float Sync_DiffAngle;		//同期角差闭锁定值***.**°————输入值范围（ ）
	float Sync_DiffFreq;		//同期频差闭锁定值***.**°————输入值范围（ ）
	float Sync_DelayTime;		//同期等待时间***.**°————输入值范围（ ）
	float Sync_CloseTime;		//断路器合闸时间***.**°————输入值范围（ ）
	uint32_t Sync_Mode;			//遥合方式：1-检同期/2-检无压/3-普通
	uint32_t CRC;
}ControlSetting_Struct;
extern ControlSetting_Struct  ControlSetting;
#define ControlSetting_CRCLength	21
#define ControlSetting_DataLength		88


/*****************************************************************************/
/*-----------------------------  保护定值数据结构  ---------------------------*/
/*****************************************************************************/
//---------------------------------------------------------------
//---------------------------  公共定值  ------------------------
typedef struct
{
    uint32_t	Enable_FaultIndicatorLightReset;	// 故障指示灯复归：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_FaultIndicatorLightReset;		// 故障指示灯复归时间：***.**s（输入值范围：0-100000s）
    uint32_t 	Time_FaultTeleSignalingHolding;		// 故障遥信保持时间：***.**s（输入值范围：0-100000s）

    float	Value_NoVoltage;			// 无压定值：***.**V（*输入值范围：0-266V）
    float Value_ThereVoltage;		// 有压定值：***.**V（*输入值范围：0-266V）

    float	Value_NoCurrent;			// 无电流定值：***.**A（*输入值范围：0-100A）

    float	Kre_OverRelay;				// 过量继电器返回系数：***.**（*输入值范围：0.5-1.0）
    float	Kre_UnderRelay;				// 欠量继电器返回系数：***.**（*输入值范围：1.0-1.5）

    uint32_t	Enable_IoNeedConvert;	// 3Io折算至外接零序CT二次值：Yes(1)-折算/No(0)-不折算

}RelaySetting_Common_Struct;

//---------------------------------------------------------------
//----------------------------  通信定值  ------------------------
typedef struct	//通信定值
{
    uint32_t	ChannelA_MAC_ETU[6];			//通道A边缘终端单元MAC：**:**:**:**:**:**
    uint32_t	ChannelA_MAC_Onside[6];		//通道A本侧保护单元MAC：**:**:**:**:**:**
    uint32_t	ChannelA_MAC_Offside[6];	//通道A对侧保护单元MAC：**:**:**:**:**:**
    uint32_t	ChannelB_MAC_ETU[6];			//通道B边缘终端单元MAC：**:**:**:**:**:**
    uint32_t	ChannelB_MAC_Onside[6];		//通道B本侧保护单元MAC：**:**:**:**:**:**
    uint32_t	ChannelB_MAC_Offside[6];	//通道B对侧保护单元MAC：**:**:**:**:**:**
    uint32_t	IDcode_ETU;								//边缘终端单元识别码：********（输入值范围：0-0xFFFFFFFF）
    uint32_t	IDcode_Onside;						//本侧保护单元识别码：********（输入值范围：0-0xFFFFFFFF）
    uint32_t	IDcode_Offside;						//对侧保护单元识别码：********（输入值范围：0-0xFFFFFFFF）
}RelaySetting_Communication_Struct;

//---------------------------------------------------------------
//----------------------------  纵联保护  ------------------------
typedef struct	//纵联保护公共定值
{
    uint32_t	Enable_CTBreakBlock;				//CT断线闭锁纵联保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_CTSaturationBlock;		//CT饱和闭锁纵联保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_StartBlockEachOther;	//两侧启动相互闭锁：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_RemoteTripWithStart;	//远方跳闸受启动元件控制：Yes(1)-投入/No(0)-退出（*使能控制字）
}RelaySetting_PilotRelay_Common_Struct;

typedef struct	//纵联保护启动元件
{
    uint32_t	Enable_I_MutationStart;		//电流突变量启动元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_I_Mutation;					//电流突变量启动元件定值：***.**A（输入值范围：（0.04-3）In）
    uint32_t	Enable_I_RmsStart;				//相电流启动元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_I_Rms;							//相电流启动元件定值：***.**A（输入值范围：（0.04-3）In）
    uint32_t	Enable_Io_MutationStart;	//零序电流突变量启动元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_Io_Mutation;				//零序电流突变量启动元件定值：***.**A（输入值范围：（0.04-3）In）
    uint32_t	Enable_Io_RmsStart;				//零序电流启动元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_Io_Rms;							//零序电流启动元件定值：***.**A（输入值范围：（0.04-3）In）
}RelaySetting_PilotRelay_StartElement_Struct;

typedef struct	//分相电流差动保护元件
{
    uint32_t	Enable;									//分相电流差动保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;	//分相电流差动保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_Current;					//分相电流差动保护差流定值：***.**A（输入值范围：（0.05-20）In）
    float 		Value_HighCurrent;			//分相电流差动保护差流高定值：***.**A（输入值范围：（0.05-20）In）
}RelaySetting_PilotRelay_Current_Struct;

typedef struct	//零序纵联保护元件
{
    uint32_t	Enable;									//零序纵联保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;	//零序纵联保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_Current;					//零序纵联保护电流定值：***.**A（输入值范围：（0.05-20）In）
    float 		Value_HighCurrent;			//零序纵联保护电流高定值：***.**A（输入值范围：（0.05-20）In）
    float			Value_RatioCoeff;				//零序纵联保护电流比率系数：***.**（输入值范围：0.1-1.0）
}RelaySetting_PilotRelay_Io_Struct;

typedef struct	//纵联保护
{
    RelaySetting_PilotRelay_Common_Struct					Common;
    RelaySetting_PilotRelay_StartElement_Struct		StartElement;
    RelaySetting_PilotRelay_Current_Struct				Current;
    RelaySetting_PilotRelay_Io_Struct							Io;
}RelaySetting_PilotRelay_Struct;

//---------------------------------------------------------------
//---------------------------  过电流保护  -----------------------
typedef struct	//复压闭锁元件
{
    float	Value_LineVoltage;			//过电流保护线电压闭锁定值：***.**V（输入值范围：0-100V）
    float Value_NegativeVoltage;	//过电流保护负序电压闭锁定值：***.**V（输入值范围：0-100V）
}RelaySetting_OverCurrentRelay_VoltageBlockElement_Struct;

typedef struct	//涌流抑制元件
{
    float Value_Ratio;			//过电流保护涌流抑制比：***.**%
}RelaySetting_OverCurrentRelay_InrushRestrainElement_Struct;

typedef struct	//过电流保护元件
{
    uint32_t	Enable;														//过电流保护Ⅰ段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;						//过电流保护Ⅰ段保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    uint32_t	Enable_WithVoltageBlock;					//过电流保护Ⅰ段复压闭锁元件：Yes-投入/No-退出（*使能控制字）
    uint32_t	Enable_WithDirection;							//过电流保护Ⅰ段方向元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_WithInrushCurrentRestrain;	//过电流保护Ⅰ段涌流抑制：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_Current;										//过电流保护Ⅰ段电流定值：***.**A（输入值范围：（0.05-20）In）
    uint32_t 	Time_Delay;												//过电流保护Ⅰ段时间定值：***.**s（输入值范围：0-600.0s）
}RelaySetting_OverCurrentRelay_Zone_Struct;

typedef struct	//反时限过电流保护元件
{
    uint32_t	Enable;														//反时限过电流保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;						//反时限过电流保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    uint32_t	Enable_WithVoltageBlock; 					//反时限过电流保护复压闭锁元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_WithDirection;							//反时限过电流保护方向元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_WithInrushCurrentRestrain;	//反时限过电流保护涌流抑制：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Index;														//反时限过电流保护反时限特性：InverseCharacter_Standard(1)-一般反时限/InverseCharacter_Very(2)-非常反时限/InverseCharacter_Extremely(3)-极端反时限（*使能控制字）
    float			Value_Current;										//反时限过电流保护电流基准值：***.**A（输入值范围：（0.05-20）In）
    uint32_t	Time_Delay;												//反时限过电流保护反时限时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_OverCurrentRelay_Inv_Struct;

typedef struct	//PT断线过电流保护元件
{
    uint32_t	Enable;														//PT断线相过电流保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;						//PT断线相过电流保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_Current;										//PT断线相过电流保护电流定值：***.**A（输入值范围：（0.05-20）In）
    uint32_t 	Time_Delay;												//PT断线相过电流保护时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_OverCurrentRelay_PTBreak_Struct;

typedef struct	//过电流保护加速段元件
{
    uint32_t	Enable_ManualCloseAcc;		//过电流保护手合加速段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_ManualCloseAccEnble;	//过电流保护手合加速段投入时间：***.**s（输入值范围：0-600s）
    uint32_t	Enable_ReclosureAcc;			//过电流保护重合闸后加速段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_ReclosureAccEnble;		//过电流保护重合闸后加速段投入时间：***.**s（输入值范围：0-600s）
    uint32_t	Enable_WithVoltageBlock;	//过电流保护加速段复压闭锁元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    float 		Value_Current;						//过电流保护加速段电流定值：***.**A（输入值范围：（0.05-20）In）
    uint32_t	Time_Delay;								//过电流保护加速段时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_OverCurrentRelay_Acc_Struct;

typedef struct	//过电流保护
{
    RelaySetting_OverCurrentRelay_VoltageBlockElement_Struct		VoltageBlock;		//复电压闭锁元件
    RelaySetting_OverCurrentRelay_InrushRestrainElement_Struct	InrushCurrent;	//涌流抑制元件
    RelaySetting_OverCurrentRelay_Zone_Struct			Z1;				//过电流保护Ⅰ段
    RelaySetting_OverCurrentRelay_Zone_Struct			Z2;				//过电流保护Ⅱ段
    RelaySetting_OverCurrentRelay_Zone_Struct			Z3;				//过电流保护Ⅲ段
    RelaySetting_OverCurrentRelay_Inv_Struct			Inv;			//反时限过电流保护
    RelaySetting_OverCurrentRelay_PTBreak_Struct	PTBreak;	//PT断线过电流保护
    RelaySetting_OverCurrentRelay_Acc_Struct			Acc;			//过电流保护后加速段
}RelaySetting_OverCurrentRelay_Struct;

//---------------------------------------------------------------
//---------------------------  零序过流保护  ---------------------
typedef struct	//零序过流保护元件
{
    uint32_t	Enable;									//零序过流保护Ⅰ段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;	//零序过流保护Ⅰ段保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    uint32_t	Enable_WithDirection;		//零序过流保护Ⅰ段方向元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_Current;					//零序过流保护Ⅰ段电流定值：***.**A（输入值范围：（0.05-20）In）
    uint32_t	Time_Delay;							//零序过流保护Ⅰ段时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_IoRelay_Zone_Struct;

typedef struct	//反时限零序过流保护元件
{
    uint32_t	Enable;									//反时限零序过流保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;	//反时限零序过流保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    uint32_t	Enable_WithDirection;		//反时限零序过流保护方向元件：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Index;									//反时限零序过流保护反时限特性：InverseCharacter_Standard(1)-一般反时限/InverseCharacter_Very(2)-非常反时限/InverseCharacter_Extremely(3)-极端反时限（*使能控制字）
    float			Value_Current;					//反时限零序过流保护电流基准值：***.**A（输入值范围：（0.05-20）In）
    uint32_t	Time_Delay;							//反时限零序过流保护反时限时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_IoRelay_Inv_Struct;

typedef struct	//零序过流保护加速段元件
{
    uint32_t	Enable_ManualCloseAcc;		//零序过流保护手合加速段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_ManualCloseAccEnble;	//零序过流保护手合加速段投入时间：***.**s（输入值范围：0-600s）
    uint32_t	Enable_ReclosureAcc;			//零序过流保护重合闸后加速段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_ReclosureAccEnble;		//零序过流保护重合闸后加速段投入时间：***.**s（输入值范围：0-600s）
    float			Value_Current;						//零序过流保护加速段电流定值：***.**A（输入值范围：（0.05-20）In）
    uint32_t	Time_Delay;								//零序过流保护加速段时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_IoRelay_Acc_Struct;

typedef struct	//零序电流保护
{
    RelaySetting_IoRelay_Zone_Struct	Z1;		//零序过流保护Ⅰ段
    RelaySetting_IoRelay_Zone_Struct	Z2;		//零序过流保护Ⅱ段
    RelaySetting_IoRelay_Zone_Struct	Z3;		//零序过流保护Ⅲ段
    RelaySetting_IoRelay_Inv_Struct		Inv;	//反时限零序过流保护
    RelaySetting_IoRelay_Acc_Struct		Acc;	//零序过流保护加速段
}RelaySetting_IoRelay_Struct;

//---------------------------------------------------------------
//----------------------  自适应零序过流保护  --------------------
typedef struct	//自适应零序过流保护
{
    float	Value_MinCurrent;						//电流门槛值：***.**A（输入值范围：（0.05-20）In）
    float  Value_Ko_Re;					//零序补偿系数：***.** + j***.**
    float  Value_Ko_Im;					//零序补偿系数：***.** + j***.**
    float  Value_Zs_Re;					//系统阻抗：***.** + j***.**
    float  Value_Zs_Im;					//系统阻抗：***.** + j***.**
    uint32_t	Enable_Z1;							//自适应零序过流保护Ⅰ段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_Z2;							//自适应零序过流保护Ⅱ段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_Z3;							//自适应零序过流保护Ⅲ段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_Inv;							//反时限自适应零序过流保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ManualCloseAcc;	//自适应零序过流保护手合加速段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ReclosureAcc;		//自适应零序过流保护重合闸后加速段投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
}RelaySetting_adaptIoRelay_Struct;

//---------------------------------------------------------------
//--------------------------  母线保护  --------------------------
typedef struct		//母线保护
{
    uint32_t	Enable;								//母线保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
}RelaySetting_BusRelay_Struct;

//---------------------------------------------------------------
//--------------------------  重合闸保护  ------------------------
#define ReclosureMode_DisableReclosure	0	//闭锁
#define ReclosureMode_General						1	//普通
#define ReclosureMode_Synchronism				2	//检同期
#define ReclosureMode_LineNV_and_BusEV	3	//检线无压且母有压
#define ReclosureMode_LineEV_and_BusNV 	4	//检线有压且母无压
#define ReclosureMode_LineNV_and_BusNV 	5	//检线无压且母无压
#define ReclosureMode_LineNV_or_BusNV		6	//检线无压或母无压
typedef struct		//重合闸
{
    uint32_t	Enable;												//重合闸投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_Mode;									//重合闸方式：ReclosureMode_DisableReclosure(0)—闭锁
                                                                                    //					/ReclosureMode_General(1)—普通
                                                                                    //					/ReclosureMode_Synchronism(2)—检同期
                                                                                    //					/ReclosureMode_LineNV_and_BusEV(3)—检线无压且母有压
                                                                                    //					/ReclosureMode_LineEV_and_BusNV(4)—检线有压且母无压
                                                                                    //					/ReclosureMode_LineNV_and_BusNV(5)—检线无压且母无压
                                                                                    //					/ReclosureMode_LineNV_or_BusNV(6)—检线无压或母无压（*使能控制字）
    uint32_t 	Time_Charge;									//重合闸充电时间：***.**s（单位：0.5ms）
    uint32_t	Enable_MisTripStartReclosure;	//开关偷跳：Yes(1)-重合/No(0)-不重合（*使能控制字）
    uint32_t	Enable_BigCurrentBlock;				//大电流闭锁：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_BigCurrent;							//大电流闭锁值：***.**A（输入值范围：（0.05-20）In）
    float			Value_Angle;									//检同期角度：***.**°（输入值范围：0-90°）
    uint32_t	Time_OpenCheckSynchronism;		//检同期开放时间定值：***.**s(输入值范围：0-10.0s）
    uint32_t	Time_OpenCheckNoVoltage;			//检无压开放时间定值：***.**s(输入值范围：0-10.0s）
    uint32_t	Time_Delay;										//重合闸时间定值：***.**s(输入值范围：0-10.0s）
}RelaySetting_ReclosureRelay_Struct;


//---------------------------------------------------------------
//-------------------------  过负荷保护  -------------------------
typedef struct	//过负荷保护
{
    uint32_t	Enable;									//过负荷保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;	//过负荷保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_Current;					//过负荷保护电流定值：***.**A（输入值范围：（0.05-20）In）
    uint32_t	Time_TripDelay;					//过负荷保护跳闸时间定值：***.**s（输入值范围：0-600s）
    uint32_t	Time_AlarmDelay;				//过负荷保护告警时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_OverLoadRelay_Struct;

//---------------------------------------------------------------
//-------------------------  低电压保护  -------------------------
typedef struct	//低电压保护
{
    uint32_t	Enable;											//低电压保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;			//低电压保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_Voltage;							//低电压保护电压定值：***.**V（输入值范围：0-266.0V，线电压）
    uint32_t	Time_Delay;									//低电压保护时间定值：***.**s（输入值范围：0-600s）
    float			Value_LowVoltageBlock;			//低电压保护低压闭锁定值：***.**V（输入值范围：30.0-120.0V，线电压）
    uint32_t	Enable_WithSlipBlock;				//低电压保护电压滑差闭锁：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_SlipBlock;						//低电压保护电压滑差闭锁定值:***.**V/s（输入值范围：1.0-100.0V/s，线电压）
    float			Value_SlipClearBlock;				//低电压保护滑差解除闭锁定值:***.**V/s（输入值范围：1.0-100.0V/s，线电压）
    uint32_t	Enable_WithNoCurrentBlock;	//低电压保护无流闭锁：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_NoCurrent;						//低电压保护无流闭锁定值：***.**A（输入值范围：（0.05-20）In）
}RelaySetting_LowVoltageRelay_Struct;

//---------------------------------------------------------------
//-------------------------  过电压保护  -------------------------
typedef struct	//过电压保护
{
    uint32_t	Enable;											//过电压保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;			//过电压保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_Voltage;							//过电压保护电压定值：***.**V（输入值范围：0-266.0V，线电压）
    uint32_t	Time_Delay;									//过电压保护时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_OverVoltageRelay_Struct;

//---------------------------------------------------------------
//--------------------------  低频保护  --------------------------
typedef struct	//低频保护
{
    uint32_t	Enable;											//低频保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;			//低频保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    uint32_t	Enable_TripMode;						//低频保护跳闸模式：TripMode_NetworkSplitting(1)-解列/TripMode_LoadShedding(0)-减载（*使能控制字）
    float			Value_Frequency;						//低频保护频率定值：***.**Hz（输入值范围：45.0-50.0Hz）
    uint32_t	Time_Delay;									//低频保护时间定值：***.**s（输入值范围：0.1-32.0s）
    uint32_t	Enable_WithSlipBlock;				//低频保护频率滑差闭锁：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_SlipBlock;						//低频保护频率滑差闭锁定值：***.**Hz/s（输入值范围：0.3-20.0Hz/s）
    uint32_t	Enable_WithNoCurrentBlock;	//低频保护无流闭锁：Yes(1)-投入/No(0)-退出（*使能控制字）
    float			Value_NoCurrentBlock;				//低频保护无流闭锁定值：***.**A（输入值范围：（0.05-20）In）
    float			Value_LowVoltageBlock;			//低频保护低压闭锁定值：***.**V（输入值范围：30.0-120.0V，线电压）
}RelaySetting_LowFrequencyRelay_Struct;

//---------------------------------------------------------------
//--------------------------  高频保护  -------------------------
typedef struct	//高频保护
{
    uint32_t	Enable;											//高频保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;			//高频保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_Frequency;						//高频保护频率定值：***.**Hz（输入值范围：50.0-55.0Hz）
    uint32_t	Time_Delay;									//高频保护时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_HighFrequencyRelay_Struct;

//---------------------------------------------------------------
//--------------------------  逆功率保护  ------------------------
typedef struct	//逆功率保护
{
    uint32_t	Enable;									//逆功率保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;	//逆功率保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_Power;						//逆功率保护功率定值：***.**kW（输入值范围：0.0-10000.0kW）
    uint32_t	Time_Delay;							//逆功率保护时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_InversePowerRelay_Struct;

//---------------------------------------------------------------
//------------------------  谐波电流保护  ------------------------
typedef struct	//谐波电流保护
{
    uint32_t	Enable;									//谐波电流保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;	//谐波电流保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_THDi;							//谐波电流保护THDi定值：***.**%（输入值范围：0.0-30.0%）
    uint32_t	Time_Delay;							//谐波电流保护时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_HarmonicCurrentRelay_Struct;

//---------------------------------------------------------------
//------------------------  谐波电压保护  ------------------------
typedef struct	//谐波电压保护
{
    uint32_t	Enable;									//谐波电压保护投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_ProtectionMode;	//谐波电压保护保护模式：ProtectionMode_Trip(1)-跳闸/ProtectionMode_Alarm(0)-告警（*使能控制字）
    float			Value_THDu;							//谐波电压保护THDu定值：***.**%（输入值范围：0.0-30.0%）
    uint32_t	Time_Delay;							//谐波电压保护时间定值：***.**s（输入值范围：0-600s）
}RelaySetting_HarmonicVoltageRelay_Struct;

//---------------------------------------------------------------
//---------------------------  异常监测  -------------------------
typedef struct	//母线PT断线监测
{
    uint32_t	Enable;									//母线PT断线监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_BlockProtection;	//母线PT断线闭锁相关保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;							//母线PT断线告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_BusPTBreak_Struct;

typedef struct	//线路PT断线监测
{
    uint32_t	Enable;									//线路PT断线监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Enable_BlockProtection;	//线路PT断线闭锁相关保护：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;							//线路PT断线告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_LinePTBreak_Struct;

typedef struct	//CT断线监测
{
    uint32_t	Enable;			//CT断线监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;	//CT断线告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_CTBreak_Struct;

typedef struct	//控制回路断线监测
{
    uint32_t	Enable;			//控制回路断线监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;	//控制回路断线告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_CtrlCircuitBreak_Struct;

typedef struct	//弹簧未储能监测
{
    uint32_t	Enable;			//弹簧未储能监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;	//弹簧未储能告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_SpringLessEnergy_Struct;

typedef struct	//TWJ异常监测
{
    uint32_t	Enable;			//TWJ异常监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;	//TWJ异常告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_TWJ_Struct;

typedef struct	//HWJ异常监测
{
    uint32_t	Enable;			//HTWJ异常监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;	//HWJ异常告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_HWJ_Struct;

typedef struct	//频率异常监测
{
    uint32_t	Enable;			//频率异常监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;	//频率异常告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_Frequency_Struct;

typedef struct	//接地监测
{
    uint32_t	Enable;			//接地监测投/退：Yes(1)-投入/No(0)-退出（*使能控制字）
    uint32_t	Time_Delay;	//接地告警延时定值：***.**s（输入值范围：0-600s）
}RelaySetting_AbnormalMonitoringElement_Grounding_Struct;

typedef struct
{
    RelaySetting_AbnormalMonitoringElement_BusPTBreak_Struct				BusPTBreak;  			// 母线PT断线监测
    RelaySetting_AbnormalMonitoringElement_LinePTBreak_Struct				LinePTBreak;  		// 线路PT断线监测
    RelaySetting_AbnormalMonitoringElement_CTBreak_Struct						CTBreak;					// CT断线监测
    RelaySetting_AbnormalMonitoringElement_CtrlCircuitBreak_Struct	CtrlCircuitBreak;	// 控制回路断线监测
    RelaySetting_AbnormalMonitoringElement_SpringLessEnergy_Struct	SpringLessEnergy;	// 弹簧未储能监测
    RelaySetting_AbnormalMonitoringElement_TWJ_Struct								TWJ;							// TWJ异常监测
    RelaySetting_AbnormalMonitoringElement_HWJ_Struct								HWJ;							// HWJ异常监测
    RelaySetting_AbnormalMonitoringElement_Frequency_Struct					Frequency;				// 频率异常监测
    RelaySetting_AbnormalMonitoringElement_Grounding_Struct					Grounding;				// 接地监测

}RelaySetting_AbnormalMonitoring_Struct;

//---------------------------------------------------------------
typedef struct
{
    RelaySetting_Common_Struct Common;	// 公共定值

    RelaySetting_Communication_Struct Communication;	//通信定值

    RelaySetting_PilotRelay_Struct Pilot;		// 上游多端纵联保护

    RelaySetting_OverCurrentRelay_Struct OverCurrent;	// 过电流保护

    RelaySetting_IoRelay_Struct Io;						// 零序过流保护
    RelaySetting_adaptIoRelay_Struct adaptIo;	// 自适应零序过流保护

    RelaySetting_ReclosureRelay_Struct Reclosure;	// 重合闸：

    RelaySetting_OverLoadRelay_Struct  				OverLoad;					// 过负荷保护
    RelaySetting_LowVoltageRelay_Struct				LowVoltage;				// 低电压保护
    RelaySetting_OverVoltageRelay_Struct			OverVoltage;			// 过电压保护
    RelaySetting_LowFrequencyRelay_Struct 		LowFrequency;			// 低频保护
    RelaySetting_HighFrequencyRelay_Struct		HighFrequency;		// 高频保护
    RelaySetting_InversePowerRelay_Struct			InversePower;			// 逆功率保护
    RelaySetting_HarmonicCurrentRelay_Struct	HarmonicCurrent;	// 谐波电流保护
    RelaySetting_HarmonicVoltageRelay_Struct	HarmonicVoltage;	// 谐波电压保护

    RelaySetting_AbnormalMonitoring_Struct	AbnormalMonitoring;	//异常监测

    uint32_t	CRC;	//校验码
}RelaySetting_Struct;

extern uint32_t RelaySetting_CRCLength;
extern uint32_t RelaySetting_DataLength;
extern RelaySetting_Struct RelaySetting[20];
extern RelaySetting_Struct Setting_Buf;

extern uint32_t SettingCode_Now;
typedef struct
{
    uint16_t Code;
    RelaySetting_Struct Setting;
}RemoteAdjust_Setting_Struct;	//定值遥调数据结构

/******************************************************************************/
/*--------------------------  电能质量-告警定值 ------------------------*/
/******************************************************************************/
typedef struct
{
    uint32_t Enable;
    float ActValue;
}PowerQualitySettingUnit;

typedef struct
{
    PowerQualitySettingUnit  FreqDeviation;		//频率偏差定值 （  )Hz

    PowerQualitySettingUnit  VoltageDeviation;	//电压偏差定值 （  )%
    PowerQualitySettingUnit  VoltageUnbalance;	//电压不平衡定值 （  )%
    PowerQualitySettingUnit  VoltageFluct;		//电压波动定值 （  )V
    PowerQualitySettingUnit  VoltageFlicke;		//电压闪变定值 （  )无单位
    PowerQualitySettingUnit  VoltageSeg;		//电压暂降定值 （  )%

    PowerQualitySettingUnit  VoltageTHD;		//电压总谐波含量定值 （  )%
    PowerQualitySettingUnit  VoltageHAR;		//电压单次谐波含量定值 （  )%

    PowerQualitySettingUnit  CurrentUnbalance;	//电流不平衡定值 （  )%
    PowerQualitySettingUnit  CurrentTHD;		//电流总谐波含量定值 （  )%
    PowerQualitySettingUnit  CurrentHAR;		//电流单次谐波含量定值 （  )%

    uint32_t CRC;
}PowerQualitySetting_struct;
#define QualitySetting_Length		92
#define QualitySetting_CRCLength	22
extern PowerQualitySetting_struct QualitySetting;

//通道系数数据结构
typedef struct AI_coeff
{
    float Ua;
    float Ub;
    float Uc;
    float Uo;
    float Ux;
    float IA;
    float IB;
    float IC;
    float Ia;
    float Ib;
    float Ic;
    float Io;
    float Is;
    float Iby1;
    float Iby2;
    float Iby3;
    unsigned int CRC;
}AnalogCoeff_Struct;		//长度0x0044
#define AnalogCoeff_DataLength	68
#define AnalogCoeff_CRCLength	16
extern AnalogCoeff_Struct AnalogCoeff;
extern AnalogCoeff_Struct coeff;

typedef struct
{
    uint16_t Common_addr;	//Common_Addr_RemoteAdjust
    uint16_t Object_addr;	//设备参数遥调地址（自定义）
    uint16_t Length;
    DeviceSetting_Struct DeviceSetting;
}RemoteAdjust_DeviceSetting_Struct;	//设备参数遥调数据结构

typedef struct
{
    uint16_t Common_addr;	//Common_Addr_RemoteAdjust
    uint16_t Object_addr;	//系统定值遥调地址（自定义）
    uint16_t Length;
    CommonSetting_PrimarySystem_Struct PrimarySystem;
}RemoteAdjust_PrimarySystem_Struct;	//系统定值遥调数据结构

typedef struct
{
    uint16_t Common_addr;	//Common_Addr_RemoteAdjust
    uint16_t Object_addr;	//测控参数遥调地址（自定义）
    uint16_t Length;
    ControlSetting_Struct ControlSetting;
}RemoteAdjust_ControlSetting_Struct;	//测控参数遥调数据结构

typedef struct
{
    uint16_t Common_addr;	//Common_Addr_RemoteAdjust
    uint16_t Object_addr;	//系统定值遥调地址（自定义）
    uint16_t Length;
    ProtectionSoftStrap_Struct SoftStrap;
}RemoteAdjust_SoftStrap_Struct;	//系统定值遥调数据结构

typedef struct
{
    uint16_t Common_addr;	//Common_Addr_RemoteAdjust
    uint16_t Object_addr;	//定值遥调地址（自定义）
    uint16_t Length;
    uint16_t Code;
    RelaySetting_Struct Setting;
}RemoteAdjust_RelaySetting_Struct;	//定值遥调数据结构

typedef struct
{
    uint16_t Common_addr;	//Common_Addr_RemoteAdjust
    uint16_t Object_addr;	//通道系数遥调地址（自定义）
    uint16_t Length;
    CommonSetting_AnalogQuantity_Struct AnalogQuantity;
}RemoteAdjust_AnalogQuantity_Struct;	//通道系数遥调数据结构

typedef struct
{
    uint16_t Common_addr;	//Common_Addr_RemoteAdjust
    uint16_t Object_addr;	//修改定值套号遥调地址（自定义）
    uint16_t Length;
    uint16_t SettingCode;	//定值套号
    uint16_t CodeConfirm;	//定值确认
}RemoteAdjust_SettingCode_Struct;	//定值套号遥调数据结构

#pragma pack()
#endif
