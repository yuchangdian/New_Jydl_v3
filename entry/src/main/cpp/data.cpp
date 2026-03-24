#include <iostream>
#include <QString>
#include <QQueue>
#include "def.h"
#include "setting.h"

uint32_t SettingCode_Now = 1;
uint8_t  BreakerState_Now = SW_UnCertain;
float ProtectionIn_Sec=5.0;
QString Password = "123456";//密码

QQueue<YC_BaseFreq_Struct> BaseFreq_Queue;      //!!!!!!!!!!!!!设置队列的最大长度
QQueue<YC_Energy_Struct> Energy_Queue;      //!!!!!!!!!!!!!设置队列的最大长度
QQueue<YC_HarmonicU_Struct> HarmonicU_Queue;      //!!!!!!!!!!!!!设置队列的最大长度
QQueue<YC_HarmonicI_Struct> HarmonicI_Queue;      //!!!!!!!!!!!!!设置队列的最大长度
QQueue<RemoteSignal_Change_Struct> YX_Change_Queue;
QQueue<SOE_Node_Struct> SOE_Node_Queue;

RelaySetting_Struct RelaySetting[20];
uint32_t RelaySetting_DataLength = sizeof(RelaySetting_Struct);
uint32_t RelaySetting_CRCLength = sizeof(RelaySetting_Struct)/4-1;

CommonSetting_PrimarySystem_Struct PrimarySystemSetting;
uint32_t CommonSetting_PrimarySystem_Length_1Byte = sizeof(CommonSetting_PrimarySystem_Struct);
uint32_t CommonSetting_PrimarySystem_CRCLength_4Byte = sizeof(CommonSetting_PrimarySystem_Struct)/4-1;

CommonSetting_AnalogQuantity_Struct AnalogQuantitySetting;
uint32_t CommonSetting_AnalogQuantity_Length_1Byte = sizeof(CommonSetting_AnalogQuantity_Struct);
uint32_t CommonSetting_AnalogQuantity_CRCLength_4Byte = sizeof(CommonSetting_AnalogQuantity_Struct)/4-1;

//CommonSetting_AnalogQuantity_Struct AnalogQuantitySetting;
//uint32_t CommonSetting_AnalogQuantity_Length_1Byte = sizeof(CommonSetting_AnalogQuantity_Struct);
//uint32_t CommonSetting_AnalogQuantity_CRCLength_4Byte = sizeof(CommonSetting_AnalogQuantity_Struct)/4-1;

CommonSetting_ExceedingLimit_Struct ExceedingLimitSetting;
uint32_t CommonSetting_ExceedingLimit_Length_1Byte = sizeof(CommonSetting_ExceedingLimit_Struct);
uint32_t CommonSetting_ExceedingLimit_CRCLength_4Byte = sizeof(CommonSetting_ExceedingLimit_Struct)/4-1;

CommonSetting_Statistics_Struct StatisticsSetting;
uint32_t CommonSetting_Statistics_Length_1Byte = sizeof(CommonSetting_Statistics_Struct);
uint32_t CommonSetting_Statistics_CRCLength_4Byte = sizeof(CommonSetting_Statistics_Struct)/4-1;

CommonSetting_TeleControlling_Struct TeleControllingSetting;
uint32_t CommonSetting_YK_Length_1Byte = sizeof(CommonSetting_TeleControlling_Struct);
uint32_t CommonSetting_YK_CRCLength_4Byte = sizeof(CommonSetting_TeleControlling_Struct)/4-1;

CommonSetting_TeleMeasuring_Struct TeleMeasuringSetting;
uint32_t CommonSetting_YC_Length_1Byte = sizeof(CommonSetting_TeleMeasuring_Struct);
uint32_t CommonSetting_YC_CRCLength_4Byte = sizeof(CommonSetting_TeleMeasuring_Struct)/4-1;

 CommonSetting_TeleSignaling_Struct TeleSignalingSetting;
 uint32_t CommonSetting_YX_Length_1Byte = sizeof(CommonSetting_TeleSignaling_Struct);
 uint32_t CommonSetting_YX_CRCLength_4Byte = sizeof(CommonSetting_TeleSignaling_Struct)/4-1;

//CommonSetting.PrimarySystem = PrimarySystemSetting;
CommonSetting_All_Struct CommonSetting_All;


DeviceSetting_Struct DeviceSetting;
ControlSetting_Struct ControlSetting;
ProtectionSoftStrap_Struct ProtectionSoftStrap;
ProtectionSoftStrap_Struct ProtectionSoftStrap_Buf;
uint32_t SoftStrap_DataLength = sizeof(ProtectionSoftStrap_Struct);
uint32_t SoftStrap_CRCLength = sizeof(ProtectionSoftStrap_Struct)/4-1;
AnalogCoeff_Struct AnalogCoeff;

PowerQualitySetting_struct PowerQualitySetting;
PowerQualitySetting_struct PowerQualitySetting_Buf;

YC_BaseFreq_Struct BaseFreq_Dsip;
YC_Energy_Struct Energy_Dsip;
YC_HarmonicU_Struct HarmonicU_Dsip;
YC_HarmonicI_Struct HarmonicI_Dsip;

DigitalInputData_Struct DigitalInputData;

QString SOE_StartString(uint16_t StartCode)
{
    QString content;
    switch(StartCode)
    {
    case Cd_CurrentMutationStartMoment              : content = QString("电流突变量启动元件动作");break;
    case Cd_CurrentStartMoment                      : content = QString("电流启动元件动作");break;
    case Cd_ZeroSequenceCurrentMutationStartMoment  : content = QString("零序电流突变量启动元件动作");break;
    case Cd_ZeroSequenceCurrentStartMoment          : content = QString("零序电流启动元件动作");break;
    case Cd_OverLoad_StartMoment                    : content = QString("过负荷元件启动");break;
    case Cd_LowFrequency_StartMoment                : content = QString("低周减载元件启动");break;
    case Cd_LowVoltage_StartMoment                  : content = QString("低电压元件启动");break;
    case Cd_RemoteTripMoment                        : content = QString("远方跳闸");break;
    case Cd_RemoteCloseMoment                       : content = QString("远方合闸");break;
    case Cd_MisTripStartReclosureMoment             : content = QString("开关不对称启动重合闸");break;

    case Cd_OverLoad_ReturnMoment                   : content = QString("过负荷元件返回");break;
    case Cd_LowFrequency_ReturnMoment               : content = QString("低周减载元件返回");break;
    case Cd_LowVoltage_ReturnMoment                 : content = QString("低电压元件返回");break;
    }
    return content;
}

QString SOE_ActString(uint16_t StartCode)
{
    QString content;
    switch(StartCode)
    {
    case Cd_FaultChoicePhase				: content = QString("故障选相");break;
    case Cd_FaultPhase 	 					: content = QString("故障相别");break;
    case Cd_I_Z1_Act        				: content = QString("电流I段保护动作");break;
    case Cd_I_Z2_Act          				: content = QString("电流II段保护动作");break;
    case Cd_I_Z3_Act          				: content = QString("电流III段保护动作");break;
    case Cd_I_PtBreak_Act       			: content = QString("PT断线相过流保护动作");break;
    case Cd_I_InverseTime_Act				: content = QString("电流反时限保护动作");break;
    case Cd_I_RecloseAcc_Act   				: content = QString("重合闸后加速电流保护动作");break;
    case Cd_I_ManCloseAcc_Act				: content = QString("手合加速电流保护动作");break;
    case Cd_Io_Z1_Act         				: content = QString("零序电流I段保护动作");break;
    case Cd_Io_Z2_Act         				: content = QString("零序电流II段保护动作");break;
    case Cd_Io_Z3_Act         				: content = QString("零序电流III段保护动作");break;
    case Cd_Io_InverseTime_Act				: content = QString("零序电流反时限保护动作");break;
    case Cd_Io_RecloseAcc_Act   			: content = QString("重合闸后加速零序电流保护动作");break;
    case Cd_Io_ManCloseAcc_Act  			: content = QString("手合加速零序电流保护动作");break;
    case Cd_Io_Z1_Alarm     				: content = QString("零序电流I段保护告警");break;
    case Cd_Io_Z2_Alarm         			: content = QString("零序电流II段保护告警");break;
    case Cd_Io_Z3_Alarm         			: content = QString("零序电流III段保护告警");break;
    case Cd_Io_InverseTime_Alarm			: content = QString("零序电流反时限保护告警");break;
    case Cd_IoSelfAdapt_Z1_Act  			: content = QString("自适应零序电流I段保护动作");break;
    case Cd_IoSelfAdapt_Z2_Act  			: content = QString("自适应零序电流II段保护动作");break;
    case Cd_IoSelfAdapt_Z3_Act  			: content = QString("自适应零序电流III段保护动作");break;
    case Cd_IoSelfAdapt_InverseTime_Act		: content = QString("自适应零序电流反时限保护动作");break;
    case Cd_IoSelfAdapt_RecloseAcc_Act  	: content = QString("重合闸后加速自适应零序电流保护动作");break;
    case Cd_IoSelfAdapt_ManCloseAcc_Act 	: content = QString("手合加速自适应零序电流保护动作");break;
    case Cd_IoSelfAdapt_Z1_Alarm  			: content = QString("自适应零序电流I段保护告警");break;
    case Cd_IoSelfAdapt_Z2_Alarm  			: content = QString("自适应零序电流II段保护告警");break;
    case Cd_IoSelfAdapt_Z3_Alarm  			: content = QString("自适应零序电流III段保护告警");break;
    case Cd_IoSelfAdapt_InverseTime_Alarm	: content = QString("自适应零序电流反时限保护告警");break;
    case Cd_BusProtection_Act				: content = QString("闭锁式母线保护动作");break;
    case Cd_ProtectionStartReclosure_Act	: content = QString("保护启动重合闸");break;
    case Cd_Reclosure_Act					: content = QString("重合闸动作");break;
    case Cd_ResetTripOrderTime				: content = QString("跳闸继电器返回");break;
    case Cd_ResetCloseOrderTime				: content = QString("合闸继电器返回");break;
    case Cd_TripNotSuccess					: content = QString("跳闸不成功");break;
    case Cd_RecloseNotSuccess				: content = QString("合闸不成功");break;
    case Cd_OverLoad_Trip					: content = QString("过负荷动作");break;
    case Cd_OverLoad_Alarm					: content = QString("过负荷告警");break;
    case Cd_LowFrequency_Trip				: content = QString("低周保护动作");break;
    case Cd_LowFrequency_Alarm				: content = QString("低周保护告警");break;
    case Cd_LowVoltage_Trip					: content = QString("低压保护动作");break;
    case Cd_LowVoltage_Alarm				: content = QString("低压保护告警");break;
    case Cd_ProtectionGlobalReset_Act		: content = QString("保护整组复归");break;
    case Cd_Idiff_Act_A        				: content = QString("A相电流差动保护动作");break;
    case Cd_Idiff_Act_B        				: content = QString("B相电流差动保护动作");break;
    case Cd_Idiff_Act_C        				: content = QString("C相电流差动保护动作");break;
    case Cd_IdiffCombined_Act_C 			: content = QString("C相电流差动保护动作");break;
    case Cd_IoPilot_Act        				: content = QString("零序电流纵联保护动作");break;
    case Cd_IoPilotCombined_Act 			: content = QString("零序电流纵联保护联跳动作");break;
    case Cd_UoPilot_Act        				: content = QString("线路断线零序纵联保护动作");break;
    case Cd_UoPilotCombined_Act 			: content = QString("线路断线零序纵联保护联跳动作");break;
    }
    return content;
}

QString SOE_PhaseString(uint8_t PhaseInfo)
{
    QString content;
    switch(PhaseInfo)
    {
    case Phase_A		: content = QString("A相");break;
    case Phase_B 	 	: content = QString("B相");break;
    case Phase_C        : content = QString("C相");break;
    case Phase_AB       : content = QString("AB相");break;
    case Phase_BC       : content = QString("BC相");break;
    case Phase_CA       : content = QString("CA相");break;
    case Phase_ABC		: content = QString("ABC相");break;
    }
    return content;
}

QString SOE_3ValString(SOE_Node_Struct tNode)
{
    QString content;
    switch(tNode.Object_addr)
    {
    case Cd_Act_Uabc_RMS			: content = QString("ABC三相电压动作值：%1V，%2V，%3V").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    case Cd_Return_Uabc_RMS			: content = QString("ABC三相电压返回值：%1V，%2V，%3V").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    case Cd_Act_IABC_RMS			: content = QString("ABC三相电流动作值：%1A，%2A，%3A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    case Cd_Return_IABC_RMS			: content = QString("ABC三相电流返回值：%1A，%2A，%3A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    case Cd_Act_Iabc_RMS			: content = QString("ABC三相测量电流动作值：%1A，%2A，%3A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    case Cd_Return_Iabc_RMS			: content = QString("ABC三相测量电流返回值：%1A，%2A，%3A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    case Cd_Act_UabUbcUca_RMS   	: content = QString("三相线电压动作值：%1V，%2V，%3V").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    case Cd_Return_UabUbcUca_RMS   	: content = QString("三相线电压返回值：%1V，%2V，%3V").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    case Cd_Act_IoUoSelfAdapt_RMS	: content = QString("零序电流=%1A，零序电流修正值=%2A, 零序电压=%3V").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2)).arg(QString::number(tNode.Value3, 'f', 2));
        break;
    }
    return content;
}

QString SOE_2ValString(SOE_Node_Struct tNode)
{
    QString content;
    switch(tNode.Object_addr)
    {
    case Cd_Act_IoUo_RMS			: content = QString("零序电流电压动作值：%1A,%2V").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_IA_OnSide				: content = QString("本侧A相电流：%1 + j%2A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_IA_OffSide				: content = QString("对侧A相电流：%1 + j%2A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_IB_OnSide				: content = QString("本侧B相电流：%1 + j%2A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_IB_OffSide				: content = QString("对侧B相电流：%1 + j%2A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_IC_OnSide				: content = QString("本侧C相电流：%1 + j%2A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_IC_OffSide				: content = QString("对侧C相电流：%1 + j%2A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_Io_OnSide				: content = QString("本侧零序电流：%1 + j%2A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_Io_OffSide				: content = QString("对侧零序电流：%1 + j%2A").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_Uo_OnSide				: content = QString("本侧零序电压：%1 + j%2V").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    case Cd_Uo_OffSide				: content = QString("对侧零序电压：%1 + j%2V").arg(QString::number(tNode.Value1, 'f', 2)).arg(QString::number(tNode.Value2, 'f', 2));
        break;
    }
    return content;
}

QString SOE_1ValString(SOE_Node_Struct tNode)
{
    QString content;
    switch(tNode.Object_addr)
    {
    case Cd_Act_Ua_RMS				: content = QString("A相电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Ua_RMS			: content = QString("A相电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_Ub_RMS				: content = QString("B相电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Ub_RMS			: content = QString("B相电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_Uc_RMS				: content = QString("C相电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Uc_RMS			: content = QString("B相电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_Uo_RMS				: content = QString("零序电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Uo_RMS			: content = QString("零序电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_IA_RMS				: content = QString("A相电流动作值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_IA_RMS			: content = QString("A相电流返回值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_IB_RMS				: content = QString("B相电流动作值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_IB_RMS			: content = QString("B相电流返回值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_IC_RMS				: content = QString("C相电流动作值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_IC_RMS			: content = QString("C相电流返回值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_Io_RMS				: content = QString("零序电流动作值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Io_RMS			: content = QString("零序电流返回值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_Ux_RMS				: content = QString("线路电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Ux_RMS			: content = QString("线路电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_IoSelfAdapt_RMS		: content = QString("自适应零序电流动作值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_IoSelfAdapt_RMS	: content = QString("自适应零序电流返回值：%1A").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_Uab_RMS   			: content = QString("AB相电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Uab_RMS   		: content = QString("AB相电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_Ubc_RMS   			: content = QString("BC相电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Ubc_RMS   		: content = QString("BC相电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_Uca_RMS   			: content = QString("CA相电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_Uca_RMS   		: content = QString("CA相电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_U2_RMS				: content = QString("负序电压动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_U2_RMS			: content = QString("负序电压返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_I2_RMS				: content = QString("负序电流动作值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_I2_RMS			: content = QString("负序电流返回值：%1V").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Act_FrequencyValue		: content = QString("频率动作值：%1Hz").arg(QString::number(tNode.Value1, 'f', 2));break;
    case Cd_Return_FrequencyValue	: content = QString("频率返回值：%1Hz").arg(QString::number(tNode.Value1, 'f', 2));break;
    }
    return content;
}



