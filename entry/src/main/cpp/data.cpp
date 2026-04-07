#include "setting.h"

#include <deque>
#include <iomanip>
#include <sstream>
#include <string>

uint32_t SettingCode_Now = 1;
uint8_t  BreakerState_Now = SW_UnCertain;
float ProtectionIn_Sec=5.0;
std::string Password = "123456";//密码

std::deque<YC_BaseFreq_Struct> BaseFreq_Queue;      //!!!!!!!!!!!!!设置队列的最大长度
std::deque<YC_Energy_Struct> Energy_Queue;      //!!!!!!!!!!!!!设置队列的最大长度
std::deque<YC_HarmonicU_Struct> HarmonicU_Queue;      //!!!!!!!!!!!!!设置队列的最大长度
std::deque<YC_HarmonicI_Struct> HarmonicI_Queue;      //!!!!!!!!!!!!!设置队列的最大长度
std::deque<RemoteSignal_Change_Struct> YX_Change_Queue;
std::deque<SOE_Node_Struct> SOE_Node_Queue;

RelaySetting_Struct RelaySetting[20];
bool RelaySettingReady[20] = { false };
uint32_t RelaySetting_DataLength = sizeof(RelaySetting_Struct);
uint32_t RelaySetting_CRCLength = sizeof(RelaySetting_Struct)/4-1;

CommonSetting_PrimarySystem_Struct PrimarySystemSetting;
bool PrimarySystemSettingReady = false;
uint32_t CommonSetting_PrimarySystem_Length_1Byte = sizeof(CommonSetting_PrimarySystem_Struct);
uint32_t CommonSetting_PrimarySystem_CRCLength_4Byte = sizeof(CommonSetting_PrimarySystem_Struct)/4-1;

CommonSetting_AnalogQuantity_Struct AnalogQuantitySetting;
bool AnalogQuantitySettingReady = false;
uint32_t CommonSetting_AnalogQuantity_Length_1Byte = sizeof(CommonSetting_AnalogQuantity_Struct);
uint32_t CommonSetting_AnalogQuantity_CRCLength_4Byte = sizeof(CommonSetting_AnalogQuantity_Struct)/4-1;

//CommonSetting_AnalogQuantity_Struct AnalogQuantitySetting;
//uint32_t CommonSetting_AnalogQuantity_Length_1Byte = sizeof(CommonSetting_AnalogQuantity_Struct);
//uint32_t CommonSetting_AnalogQuantity_CRCLength_4Byte = sizeof(CommonSetting_AnalogQuantity_Struct)/4-1;

CommonSetting_ExceedingLimit_Struct ExceedingLimitSetting;
bool ExceedingLimitSettingReady = false;
uint32_t CommonSetting_ExceedingLimit_Length_1Byte = sizeof(CommonSetting_ExceedingLimit_Struct);
uint32_t CommonSetting_ExceedingLimit_CRCLength_4Byte = sizeof(CommonSetting_ExceedingLimit_Struct)/4-1;

CommonSetting_Statistics_Struct StatisticsSetting;
bool StatisticsSettingReady = false;
uint32_t CommonSetting_Statistics_Length_1Byte = sizeof(CommonSetting_Statistics_Struct);
uint32_t CommonSetting_Statistics_CRCLength_4Byte = sizeof(CommonSetting_Statistics_Struct)/4-1;

CommonSetting_PowerQuality_Struct PowerQualitySetting;
bool PowerQualitySettingReady = false;
uint32_t CommonSetting_PowerQuality_Length_1Byte = sizeof(CommonSetting_PowerQuality_Struct);
uint32_t CommonSetting_PowerQuality_CRCLength_4Byte = sizeof(CommonSetting_PowerQuality_Struct)/4-1;

CommonSetting_TeleControlling_Struct TeleControllingSetting;
bool TeleControllingSettingReady = false;
uint32_t CommonSetting_TeleControlling_Length_1Byte = sizeof(CommonSetting_TeleControlling_Struct);
uint32_t CommonSetting_TeleControlling_CRCLength_4Byte = sizeof(CommonSetting_TeleControlling_Struct)/4-1;

CommonSetting_TeleMeasuring_Struct TeleMeasuringSetting;
bool TeleMeasuringSettingReady = false;
uint32_t CommonSetting_TeleMeasuring_Length_1Byte = sizeof(CommonSetting_TeleMeasuring_Struct);
uint32_t CommonSetting_TeleMeasuring_CRCLength_4Byte = sizeof(CommonSetting_TeleMeasuring_Struct)/4-1;

 CommonSetting_TeleSignaling_Struct TeleSignalingSetting;
 bool TeleSignalingSettingReady = false;
 uint32_t CommonSetting_TeleSignaling_Length_1Byte = sizeof(CommonSetting_TeleSignaling_Struct);
 uint32_t CommonSetting_TeleSignaling_CRCLength_4Byte = sizeof(CommonSetting_TeleSignaling_Struct)/4-1;

//CommonSetting.PrimarySystem = PrimarySystemSetting;
CommonSetting_All_Struct CommonSetting_All;


DeviceSetting_Struct DeviceSetting;
ControlSetting_Struct ControlSetting;
ProtectionSoftStrap_Struct ProtectionSoftStrap;
ProtectionSoftStrap_Struct ProtectionSoftStrap_Buf;
uint32_t SoftStrap_DataLength = sizeof(ProtectionSoftStrap_Struct);
uint32_t SoftStrap_CRCLength = sizeof(ProtectionSoftStrap_Struct)/4-1;
AnalogCoeff_Struct AnalogCoeff;

PowerQualitySetting_struct LegacyPowerQualitySetting;
PowerQualitySetting_struct LegacyPowerQualitySetting_Buf;

YC_BaseFreq_Struct BaseFreq_Dsip;
bool BaseFreqDisplayReady = false;
YC_Energy_Struct Energy_Dsip;
YC_HarmonicU_Struct HarmonicU_Dsip;
bool HarmonicVoltageDisplayReady = false;
YC_HarmonicI_Struct HarmonicI_Dsip;
bool HarmonicCurrentDisplayReady = false;

DigitalInputData_Struct DigitalInputData;


static std::string ToFixedString(float value, int precision = 2)
{
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(precision) << value;
    return oss.str();
}

static void ReplaceFirst(std::string &text, const std::string &from, const std::string &to)
{
    std::size_t pos = text.find(from);
    if (pos != std::string::npos) {
        text.replace(pos, from.length(), to);
    }
}

static std::string Format1(const char *pattern, float v1)
{
    std::string text(pattern);
    ReplaceFirst(text, "%1", ToFixedString(v1));
    return text;
}

static std::string Format2(const char *pattern, float v1, float v2)
{
    std::string text(pattern);
    ReplaceFirst(text, "%1", ToFixedString(v1));
    ReplaceFirst(text, "%2", ToFixedString(v2));
    return text;
}

static std::string Format3(const char *pattern, float v1, float v2, float v3)
{
    std::string text(pattern);
    ReplaceFirst(text, "%1", ToFixedString(v1));
    ReplaceFirst(text, "%2", ToFixedString(v2));
    ReplaceFirst(text, "%3", ToFixedString(v3));
    return text;
}

std::string SOE_StartString(uint16_t StartCode)
{
    std::string  content;
    switch(StartCode)
    {
    case Cd_CurrentMutationStartMoment              : content = "电流突变量启动元件动作";break;
    case Cd_CurrentStartMoment                      : content = "电流启动元件动作";break;
    case Cd_ZeroSequenceCurrentMutationStartMoment  : content = "零序电流突变量启动元件动作";break;
    case Cd_ZeroSequenceCurrentStartMoment          : content = "零序电流启动元件动作";break;
    case Cd_OverLoad_StartMoment                    : content = "过负荷元件启动";break;
    case Cd_LowFrequency_StartMoment                : content = "低周减载元件启动";break;
    case Cd_LowVoltage_StartMoment                  : content = "低电压元件启动";break;
    case Cd_RemoteTripMoment                        : content = "远方跳闸";break;
    case Cd_RemoteCloseMoment                       : content = "远方合闸";break;
    case Cd_MisTripStartReclosureMoment             : content = "开关不对称启动重合闸";break;

    case Cd_OverLoad_ReturnMoment                   : content = "过负荷元件返回";break;
    case Cd_LowFrequency_ReturnMoment               : content = "低周减载元件返回";break;
    case Cd_LowVoltage_ReturnMoment                 : content = "低电压元件返回";break;
    }
    return content;
}

std::string SOE_ActString(uint16_t StartCode)
{
    std::string content;
    switch(StartCode)
    {
    case Cd_FaultChoicePhase				: content = "故障选相";break;
    case Cd_FaultPhase 	 					: content = "故障相别";break;
    case Cd_I_Z1_Act        				: content = "电流I段保护动作";break;
    case Cd_I_Z2_Act          				: content = "电流II段保护动作";break;
    case Cd_I_Z3_Act          				: content = "电流III段保护动作";break;
    case Cd_I_PtBreak_Act       			: content = "PT断线相过流保护动作";break;
    case Cd_I_InverseTime_Act				: content = "电流反时限保护动作";break;
    case Cd_I_RecloseAcc_Act   				: content = "重合闸后加速电流保护动作";break;
    case Cd_I_ManCloseAcc_Act				: content = "手合加速电流保护动作";break;
    case Cd_Io_Z1_Act         				: content = "零序电流I段保护动作";break;
    case Cd_Io_Z2_Act         				: content = "零序电流II段保护动作";break;
    case Cd_Io_Z3_Act         				: content = "零序电流III段保护动作";break;
    case Cd_Io_InverseTime_Act				: content = "零序电流反时限保护动作";break;
    case Cd_Io_RecloseAcc_Act   			: content = "重合闸后加速零序电流保护动作";break;
    case Cd_Io_ManCloseAcc_Act  			: content = "手合加速零序电流保护动作";break;
    case Cd_Io_Z1_Alarm     				: content = "零序电流I段保护告警";break;
    case Cd_Io_Z2_Alarm         			: content = "零序电流II段保护告警";break;
    case Cd_Io_Z3_Alarm         			: content = "零序电流III段保护告警";break;
    case Cd_Io_InverseTime_Alarm			: content = "零序电流反时限保护告警";break;
    case Cd_IoSelfAdapt_Z1_Act  			: content = "自适应零序电流I段保护动作";break;
    case Cd_IoSelfAdapt_Z2_Act  			: content = "自适应零序电流II段保护动作";break;
    case Cd_IoSelfAdapt_Z3_Act  			: content = "自适应零序电流III段保护动作";break;
    case Cd_IoSelfAdapt_InverseTime_Act		: content = "自适应零序电流反时限保护动作";break;
    case Cd_IoSelfAdapt_RecloseAcc_Act  	: content = "重合闸后加速自适应零序电流保护动作";break;
    case Cd_IoSelfAdapt_ManCloseAcc_Act 	: content = "手合加速自适应零序电流保护动作";break;
    case Cd_IoSelfAdapt_Z1_Alarm  			: content = "自适应零序电流I段保护告警";break;
    case Cd_IoSelfAdapt_Z2_Alarm  			: content = "自适应零序电流II段保护告警";break;
    case Cd_IoSelfAdapt_Z3_Alarm  			: content = "自适应零序电流III段保护告警";break;
    case Cd_IoSelfAdapt_InverseTime_Alarm	: content = "自适应零序电流反时限保护告警";break;
    case Cd_BusProtection_Act				: content = "闭锁式母线保护动作";break;
    case Cd_ProtectionStartReclosure_Act	: content = "保护启动重合闸";break;
    case Cd_Reclosure_Act					: content = "重合闸动作";break;
    case Cd_ResetTripOrderTime				: content = "跳闸继电器返回";break;
    case Cd_ResetCloseOrderTime				: content = "合闸继电器返回";break;
    case Cd_TripNotSuccess					: content = "跳闸不成功";break;
    case Cd_RecloseNotSuccess				: content = "合闸不成功";break;
    case Cd_OverLoad_Trip					: content = "过负荷动作";break;
    case Cd_OverLoad_Alarm					: content = "过负荷告警";break;
    case Cd_LowFrequency_Trip				: content = "低周保护动作";break;
    case Cd_LowFrequency_Alarm				: content = "低周保护告警";break;
    case Cd_LowVoltage_Trip					: content = "低压保护动作";break;
    case Cd_LowVoltage_Alarm				: content = "低压保护告警";break;
    case Cd_ProtectionGlobalReset_Act		: content = "保护整组复归";break;
    case Cd_Idiff_Act_A        				: content = "A相电流差动保护动作";break;
    case Cd_Idiff_Act_B        				: content = "B相电流差动保护动作";break;
    case Cd_Idiff_Act_C        				: content = "C相电流差动保护动作";break;
    case Cd_IdiffCombined_Act_C 			: content = "C相电流差动保护动作";break;
    case Cd_IoPilot_Act        				: content = "零序电流纵联保护动作";break;
    case Cd_IoPilotCombined_Act 			: content = "零序电流纵联保护联跳动作";break;
    case Cd_UoPilot_Act        				: content = "线路断线零序纵联保护动作";break;
    case Cd_UoPilotCombined_Act 			: content = "线路断线零序纵联保护联跳动作";break;
    }
    return content;
}

std::string SOE_PhaseString(uint8_t PhaseInfo)
{
    std::string content;
    switch(PhaseInfo)
    {
    case Phase_A		: content = "A相";break;
    case Phase_B 	 	: content = "B相";break;
    case Phase_C        : content = "C相";break;
    case Phase_AB       : content = "AB相";break;
    case Phase_BC       : content = "BC相";break;
    case Phase_CA       : content = "CA相";break;
    case Phase_ABC		: content = "ABC相";break;
    }
    return content;
}

std::string SOE_3ValString(SOE_Node_Struct tNode)
{
    std::string content;
    switch(tNode.Object_addr)
    {
    case Cd_Act_Uabc_RMS			: content = Format3("ABC三相电压动作值：%1V，%2V，%3V", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    case Cd_Return_Uabc_RMS			: content = Format3("ABC三相电压返回值：%1V，%2V，%3V", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    case Cd_Act_IABC_RMS			: content = Format3("ABC三相电流动作值：%1A，%2A，%3A", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    case Cd_Return_IABC_RMS			: content = Format3("ABC三相电流返回值：%1A，%2A，%3A", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    case Cd_Act_Iabc_RMS			: content = Format3("ABC三相测量电流动作值：%1A，%2A，%3A", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    case Cd_Return_Iabc_RMS			: content = Format3("ABC三相测量电流返回值：%1A，%2A，%3A", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    case Cd_Act_UabUbcUca_RMS   	: content = Format3("三相线电压动作值：%1V，%2V，%3V", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    case Cd_Return_UabUbcUca_RMS   	: content = Format3("三相线电压返回值：%1V，%2V，%3V", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    case Cd_Act_IoUoSelfAdapt_RMS	: content = Format3("零序电流=%1A，零序电流修正值=%2A, 零序电压=%3V", tNode.Value1, tNode.Value2, tNode.Value3);
        break;
    }
    return content;
}

std::string SOE_2ValString(SOE_Node_Struct tNode)
{
    std::string content;
    switch(tNode.Object_addr)
    {
    case Cd_Act_IoUo_RMS			: content = Format2("零序电流电压动作值：%1A,%2V", tNode.Value1, tNode.Value2);
        break;
    case Cd_IA_OnSide				: content = Format2("本侧A相电流：%1 + j%2A", tNode.Value1, tNode.Value2);
        break;
    case Cd_IA_OffSide				: content = Format2("对侧A相电流：%1 + j%2A", tNode.Value1, tNode.Value2);
        break;
    case Cd_IB_OnSide				: content = Format2("本侧B相电流：%1 + j%2A", tNode.Value1, tNode.Value2);
        break;
    case Cd_IB_OffSide				: content = Format2("对侧B相电流：%1 + j%2A", tNode.Value1, tNode.Value2);
        break;
    case Cd_IC_OnSide				: content = Format2("本侧C相电流：%1 + j%2A", tNode.Value1, tNode.Value2);
        break;
    case Cd_IC_OffSide				: content = Format2("对侧C相电流：%1 + j%2A", tNode.Value1, tNode.Value2);
        break;
    case Cd_Io_OnSide				: content = Format2("本侧零序电流：%1 + j%2A", tNode.Value1, tNode.Value2);
        break;
    case Cd_Io_OffSide				: content = Format2("对侧零序电流：%1 + j%2A", tNode.Value1, tNode.Value2);
        break;
    case Cd_Uo_OnSide				: content = Format2("本侧零序电压：%1 + j%2V", tNode.Value1, tNode.Value2);
        break;
    case Cd_Uo_OffSide				: content = Format2("对侧零序电压：%1 + j%2V", tNode.Value1, tNode.Value2);
        break;
    }
    return content;
}

std::string SOE_1ValString(SOE_Node_Struct tNode)
{
    std::string content;
    switch(tNode.Object_addr)
    {
    case Cd_Act_Ua_RMS				: content = Format1("A相电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_Ua_RMS			: content = Format1("A相电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_Ub_RMS				: content = Format1("B相电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_Ub_RMS			: content = Format1("B相电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_Uc_RMS				: content = Format1("C相电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_Uc_RMS			: content = Format1("B相电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_Uo_RMS				: content = Format1("零序电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_Uo_RMS			: content = Format1("零序电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_IA_RMS				: content = Format1("A相电流动作值：%1A", tNode.Value1);break;
    case Cd_Return_IA_RMS			: content = Format1("A相电流返回值：%1A", tNode.Value1);break;
    case Cd_Act_IB_RMS				: content = Format1("B相电流动作值：%1A", tNode.Value1);break;
    case Cd_Return_IB_RMS			: content = Format1("B相电流返回值：%1A", tNode.Value1);break;
    case Cd_Act_IC_RMS				: content = Format1("C相电流动作值：%1A", tNode.Value1);break;
    case Cd_Return_IC_RMS			: content = Format1("C相电流返回值：%1A", tNode.Value1);break;
    case Cd_Act_Io_RMS				: content = Format1("零序电流动作值：%1A", tNode.Value1);break;
    case Cd_Return_Io_RMS			: content = Format1("零序电流返回值：%1A", tNode.Value1);break;
    case Cd_Act_Ux_RMS				: content = Format1("线路电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_Ux_RMS			: content = Format1("线路电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_IoSelfAdapt_RMS		: content = Format1("自适应零序电流动作值：%1A", tNode.Value1);break;
    case Cd_Return_IoSelfAdapt_RMS	: content = Format1("自适应零序电流返回值：%1A", tNode.Value1);break;
    case Cd_Act_Uab_RMS   			: content = Format1("AB相电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_Uab_RMS   		: content = Format1("AB相电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_Ubc_RMS   			: content = Format1("BC相电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_Ubc_RMS   		: content = Format1("BC相电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_Uca_RMS   			: content = Format1("CA相电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_Uca_RMS   		: content = Format1("CA相电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_U2_RMS				: content = Format1("负序电压动作值：%1V", tNode.Value1);break;
    case Cd_Return_U2_RMS			: content = Format1("负序电压返回值：%1V", tNode.Value1);break;
    case Cd_Act_I2_RMS				: content = Format1("负序电流动作值：%1V", tNode.Value1);break;
    case Cd_Return_I2_RMS			: content = Format1("负序电流返回值：%1V", tNode.Value1);break;
    case Cd_Act_FrequencyValue		: content = Format1("频率动作值：%1Hz", tNode.Value1);break;
    case Cd_Return_FrequencyValue	: content = Format1("频率返回值：%1Hz", tNode.Value1);break;
    }
    return content;
}
