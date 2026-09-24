// 根据 Qt IEC104.h 移植；字段顺序与类型保持原样。
#pragma once
#include <cstdint>
#include "setting.h"
#include "BPMU_JYBSMR131.h"
#include "FaultRecord_JYBSMR131.h"
#include "../../quality.h"
namespace jybsmr131 {
constexpr std::uint16_t kCommon_Addr_RemoteMetry = 0x1311;
constexpr std::uint16_t kCommon_Addr_RemoteControl = 0x1322;
constexpr std::uint16_t kCommon_Addr_RemoteSignal = 0x1333;
constexpr std::uint16_t kCommon_Addr_RemoteAdjust = 0x1344;
constexpr std::uint16_t kCommon_Addr_SOE = 0x1355;
constexpr std::uint16_t kCommon_Addr_Record = 0x1366;
constexpr std::uint16_t kCommon_Addr_PQ_Event = 0x1377;
constexpr std::uint16_t kRemoteMetry_BaseValue = 0x0011;
constexpr std::uint16_t kRemoteMetry_HarmonicU = 0x0033;
constexpr std::uint16_t kRemoteMetry_HarmonicI = 0x0044;
constexpr std::uint16_t kRemoteMetry_PowerQuality = 0x0055;
constexpr std::uint16_t kRemoteMetry_HD_Ua = 0x0081;
constexpr std::uint16_t kRemoteMetry_HD_Ub = 0x0082;
constexpr std::uint16_t kRemoteMetry_HD_Uc = 0x0083;
constexpr std::uint16_t kRemoteMetry_HD_Ia = 0x0084;
constexpr std::uint16_t kRemoteMetry_HD_Ib = 0x0085;
constexpr std::uint16_t kRemoteMetry_HD_Ic = 0x0086;
constexpr std::uint16_t kRemoteMetry_IHD_Ua = 0x0091;
constexpr std::uint16_t kRemoteMetry_IHD_Ub = 0x0092;
constexpr std::uint16_t kRemoteMetry_IHD_Uc = 0x0093;
constexpr std::uint16_t kRemoteMetry_IHD_Ia = 0x0094;
constexpr std::uint16_t kRemoteMetry_IHD_Ib = 0x0095;
constexpr std::uint16_t kRemoteMetry_IHD_Ic = 0x0096;
constexpr std::uint16_t kRemoteMetry_Location = 0x00AA;
constexpr std::uint16_t kRemoteMetry_PlotBuf_Ua = 0x00B1;
constexpr std::uint16_t kRemoteMetry_PlotBuf_Ub = 0x00B2;
constexpr std::uint16_t kRemoteMetry_PlotBuf_Uc = 0x00B3;
constexpr std::uint16_t kRemoteMetry_PlotBuf_Ia = 0x00B4;
constexpr std::uint16_t kRemoteMetry_PlotBuf_Ib = 0x00B5;
constexpr std::uint16_t kRemoteMetry_PlotBuf_Ic = 0x00B6;
constexpr std::uint16_t kRemoteMetry_VoltageMaxValue = 0x0601;
constexpr std::uint16_t kRemoteMetry_VoltageMinValue = 0x0602;
constexpr std::uint16_t kRemoteMetry_VoltageOnTimeValue = 0x0603;
constexpr std::uint16_t kRemoteMetry_VoltageImbalanceMaxValue = 0x0604;
constexpr std::uint16_t kRemoteMetry_VoltageQualifiedRateOnTimeValue = 0x0605;
constexpr std::uint16_t kRemoteMetry_CurrentMaxValue = 0x0606;
constexpr std::uint16_t kRemoteMetry_CurrentMinValue = 0x0607;
constexpr std::uint16_t kRemoteMetry_CurrentOnTimeValue = 0x0608;
constexpr std::uint16_t kRemoteMetry_CurrentImbalanceMaxValue = 0x0609;
constexpr std::uint16_t kRemoteMetry_PowerMaxValue = 0x0610;
constexpr std::uint16_t kRemoteMetry_PowerOnTimeValue = 0x0611;
constexpr std::uint16_t kRemoteMetry_PowerFactorMaxValue = 0x0612;
constexpr std::uint16_t kRemoteMetry_PowerFactorOnTimeValue = 0x0613;
constexpr std::uint16_t kRemoteMetry_LoadRateOnTimeValue = 0x0614;
constexpr std::uint16_t kRemoteMetry_PositiveActivePowerOnTimeValue = 0x0615;
constexpr std::uint16_t kRemoteMetry_PositiveReactivePowerOnTimeValue = 0x0616;
constexpr std::uint16_t kRemoteMetry_ReverseActivePowerOnTimeValue = 0x0617;
constexpr std::uint16_t kRemoteMetry_ReverseReactivePowerOnTimeValue = 0x0618;
constexpr std::uint16_t kYX_ObjectAddr_ALL = 0x0011;
constexpr std::uint16_t kYX_ObjectAddr_GLKGW = 0x0101;
constexpr std::uint16_t kYX_ObjectAddr_JDKGW = 0x0102;
constexpr std::uint16_t kYX_ObjectAddr_KHBJ = 0x0103;
constexpr std::uint16_t kYX_ObjectAddr_WCN = 0x0104;
constexpr std::uint16_t kYX_ObjectAddr_YFJD = 0x0105;
constexpr std::uint16_t kYX_ObjectAddr_HW = 0x0106;
constexpr std::uint16_t kYX_ObjectAddr_TW = 0x0107;
constexpr std::uint16_t kYX_ObjectAddr_Run = 0x0108;
constexpr std::uint16_t kYX_ObjectAddr_Alarm = 0x0109;
constexpr std::uint16_t kYX_ObjectAddr_SyncErr = 0x010A;
constexpr std::uint16_t kYX_ObjectAddr_SwitchState = 0x010B;
constexpr std::uint16_t kYX_ObjectAddr_Setting_System = 0x0201;
constexpr std::uint16_t kYX_ObjectAddr_Setting_Analog = 0x0202;
constexpr std::uint16_t kYX_ObjectAddr_Setting_PowerQuality = 0x0203;
constexpr std::uint16_t kYX_ObjectAddr_Setting_FaultRecord = 0x0204;
constexpr std::uint16_t kYX_ObjectAddr_Setting_BPMU = 0x0205;
constexpr std::uint16_t kYX_ObjectAddr_DateTimeSet = 0x0206;
constexpr std::uint16_t kYK_ObjectAddr_DO_QDJ = 0x0101;
constexpr std::uint16_t kYK_ObjectAddr_DO_BTJ = 0x0102;
constexpr std::uint16_t kYK_ObjectAddr_DO_BHJ = 0x0103;
constexpr std::uint16_t kYK_ObjectAddr_DO_YTJ = 0x0104;
constexpr std::uint16_t kYK_ObjectAddr_DO_YHJ = 0x0105;
constexpr std::uint16_t kYK_ObjectAddr_Switch = 0x0106;
constexpr std::uint16_t kYK_ObjectAddr_MasterStart = 0x0107;
constexpr std::uint16_t kYK_ObjectAddr_FlashSoftware = 0x0108;
constexpr std::uint16_t kYT_ObjectAddr_MeterageInit = 0x0066;
constexpr std::uint16_t kYT_ObjectAddr_DateTimeSet = 0x0077;
constexpr std::uint16_t kYT_ObjectAddr_Setting_System = 0x0011;
constexpr std::uint16_t kYT_ObjectAddr_Setting_Analog = 0x0022;
constexpr std::uint16_t kYT_ObjectAddr_Setting_PowerQuality = 0x0033;
constexpr std::uint16_t kYT_ObjectAddr_Setting_FaultRecord = 0x0044;
constexpr std::uint16_t kYT_ObjectAddr_Setting_BPMU = 0x0055;
constexpr std::uint16_t kSOE_Type_Start = 0x0001;
constexpr std::uint16_t kSOE_Type_Act = 0x0002;
constexpr std::uint16_t kSOE_Type_3Value = 0x0003;
constexpr std::uint16_t kSOE_Type_2Value = 0x0004;
constexpr std::uint16_t kSOE_Type_1Value = 0x0005;
constexpr std::uint16_t kRecord_Relay_Information_Addr = 0x0011;
constexpr std::uint16_t kRecord_Relay_Data_Addr = 0x0022;
constexpr std::uint16_t kRecord_PQ_Information_Addr = 0x0033;
constexpr std::uint16_t kRecord_PQ_Data_Addr = 0x0044;
constexpr std::uint16_t kRecord_SegSwell_Information_Addr = 0x0033;
constexpr std::uint16_t kRecord_SegSwell_Data_Addr = 0x0044;
constexpr std::uint16_t kPhase_A = 0x01;
constexpr std::uint16_t kPhase_B = 0x02;
constexpr std::uint16_t kPhase_C = 0x04;
constexpr std::uint16_t kPhase_AB = 0x03;
constexpr std::uint16_t kPhase_BC = 0x06;
constexpr std::uint16_t kPhase_CA = 0x05;
constexpr std::uint16_t kPhase_ABC = 0x07;
constexpr std::uint16_t kSW_Open = 0x01;
constexpr std::uint16_t kSW_Close = 0x02;
constexpr std::uint16_t kSW_UnCertain = 0x00;
constexpr std::uint16_t kSW_CtrlCircuitOpen = 0x11;
constexpr std::uint16_t kLED_Off = 0x01;
constexpr std::uint16_t kLED_On = 0x10;
constexpr std::uint16_t kRemoteSignal_DI_Mask = 0x0100;
constexpr std::uint16_t kRemoteSignal_RAState_Mask = 0x0200;
constexpr std::uint16_t kCd_Err_ProgremRAM = 0x4001;
constexpr std::uint16_t kCd_Err_DataRAM = 0x4002;
constexpr std::uint16_t kCd_Err_ProtectionSetting = 0x4003;
constexpr std::uint16_t kCd_Err_AnalogCoeff = 0x4004;
constexpr std::uint16_t kCd_Err_PTCTRatio = 0x4005;
constexpr std::uint16_t kCd_Err_U = 0x4011;
constexpr std::uint16_t kCd_Err_I = 0x4012;
constexpr std::uint16_t kCd_Err_BusPTDX_3P = 0x4013;
constexpr std::uint16_t kCd_Err_BusPTDX_3P_Block = 0x4113;
constexpr std::uint16_t kCd_Err_BusPTDX_2P = 0x4014;
constexpr std::uint16_t kCd_Err_BusPTDX_2P_Block = 0x4114;
constexpr std::uint16_t kCd_Err_BusPTDX_1P = 0x4015;
constexpr std::uint16_t kCd_Err_BusPTDX_1P_Block = 0x4115;
constexpr std::uint16_t kCd_Err_LinePTDX = 0x4016;
constexpr std::uint16_t kCd_Err_CTDX_A_Onside = 0x4017;
constexpr std::uint16_t kCd_Err_CTDX_A_Offside = 0x4018;
constexpr std::uint16_t kCd_Err_CTDX_B_Onside = 0x4019;
constexpr std::uint16_t kCd_Err_CTDX_B_Offside = 0x401A;
constexpr std::uint16_t kCd_Err_CTDX_C_Onside = 0x401B;
constexpr std::uint16_t kCd_Err_CTDX_C_Offside = 0x401C;
constexpr std::uint16_t kCd_Err_CtlCircuit = 0x4021;
constexpr std::uint16_t kCd_Err_DO_Relay = 0x4022;
constexpr std::uint16_t kCd_Err_DO_Alarm = 0x4023;
constexpr std::uint16_t kCd_Err_RemoteTZ = 0x4024;
constexpr std::uint16_t kCd_Err_RemoteHZ = 0x4025;
constexpr std::uint16_t kCd_Err_RemoteFG = 0x4026;
constexpr std::uint16_t kQQueue_Maxlength = 100;
#pragma pack(push, 1)
struct Package_YC_BaseValue_Struct {
    uint16_t Common_addr;	//Common_Addr_RemoteMetry
    uint16_t Object_addr;	//工频相量地址（自定义）
    uint16_t Length;
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;		//0~59
    uint8_t Time_hour;		//0~23
    uint8_t Time_day;		//1~31
    uint8_t Time_month;		//1~12
    uint8_t Time_year;		//0~99
    uint32_t Flag_BD_LockOK;
    float Ua_Frequency;
    float Ub_Frequency;
    float Uc_Frequency;
    float Ua_RMS, Ua_Phase;
    float Ub_RMS, Ub_Phase;
    float Uc_RMS, Uc_Phase;
    float Uo_RMS, Uo_Phase;
    float IA_RMS, IA_Phase;
    float IB_RMS, IB_Phase;
    float IC_RMS, IC_Phase;
    float Io_RMS, Io_Phase;
    float Pa, Qa, Sa, Fa; //A相有功、无功、视在、功率因数
    float Pb, Qb, Sb, Fb; //B相有功、无功、视在、功率因数
    float Pc, Qc, Sc, Fc; //C相有功、无功、视在、功率因数
    float Pt, Qt, St, Ft; //合相有功、无功、视在、功率因数
};

struct YC_HarmonicU_Struct {
    uint16_t Common_addr;	//Common_Addr_RemoteMetry
    uint16_t Object_addr;	//地址（自定义）
    uint16_t Length;
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;	//0~59
    uint8_t Time_hour;	//0~23
    uint8_t Time_day;	//1~31
    uint8_t Time_month;	//1~12
    uint8_t Time_year;	//0~99
    float Ua_Frequency[10], Ua_RMS[10], Ua_Angle[10];
    float Ub_Frequency[10], Ub_RMS[10], Ub_Angle[10];
    float Uc_Frequency[10], Uc_RMS[10], Uc_Angle[10];
};

struct YC_HarmonicI_Struct {
    uint16_t Common_addr;	//Common_Addr_RemoteMetry
    uint16_t Object_addr;	//地址（自定义）
    uint16_t Length;
    uint16_t Time_ms;	//0~59999
    uint8_t Time_min;	//0~59
    uint8_t Time_hour;	//0~23
    uint8_t Time_day;	//1~31
    uint8_t Time_month;	//1~12
    uint8_t Time_year;	//0~99
    float Ia_Frequency[10], Ia_RMS[10], Ia_Angle[10];
    float Ib_Frequency[10], Ib_RMS[10], Ib_Angle[10];
    float Ic_Frequency[10], Ic_RMS[10], Ic_Angle[10];
};

// 缺少 powerquality.h：必须提供真实载荷类型后才能实例化。
template <typename PowerQualityIndicator_struct>
struct Package_YC_PowerQuality_Struct {
    uint16_t Common_addr;	//Common_Addr_RemoteMetry
    uint16_t Object_addr;	//地址（自定义）
    uint16_t Length;
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;		//0~59
    uint8_t Time_hour;		//0~23
    uint8_t Time_day;		//1~31
    uint8_t Time_month;		//1~12
    uint8_t Time_year;		//0~99
    PowerQualityIndicator_struct PowerQuality;
};

// 缺少 powerquality.h：必须提供真实载荷类型后才能实例化。
template <typename HarmonicDistortion_struct>
struct Package_YC_Distortion_Struct {
    uint16_t Common_addr;	//Common_Addr_RemoteMetry
    uint16_t Object_addr;	//地址（自定义）
    uint16_t Length;
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;		//0~59
    uint8_t Time_hour;		//0~23
    uint8_t Time_day;		//1~31
    uint8_t Time_month;		//1~12
    uint8_t Time_year;		//0~99
    HarmonicDistortion_struct Distortion;
};

struct Package_YC_PlotBuf_Struct {
    uint16_t Common_addr;	//Common_Addr_RemoteMetry
    uint16_t Object_addr;	//地址（自定义）
    uint16_t Length;
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;		//0~59
    uint8_t Time_hour;		//0~23
    uint8_t Time_day;		//1~31
    uint8_t Time_month;		//1~12
    uint8_t Time_year;		//0~99
    int16_t Value[400];		//解析时先转浮点然后除100
};

struct RemoteSignal_Change_Struct {
    uint16_t Common_addr;	//Common_Addr_RemoteSignal
    uint16_t Object_addr; //各种遥信Object_addr
    uint16_t Length;
    uint8_t State;      //8bit=0,0,0,0,0,0,状态(01:open, 10:close)(01:Fault, 10:Right)
    uint16_t Time_ms;   //0~59999
    uint8_t Time_min;   //0~59
    uint8_t Time_hour;  //0~23
    uint8_t Time_day;   //1~31
    uint8_t Time_month; //1~12
    uint8_t Time_year;  //0~99
};

struct Package_YT_CommonSetting_TeleMeasuring_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //遥测参数定值遥调地址
    uint16_t Length;
    CommonSetting_TeleMeasuring_Struct TeleMeasuring;
};

struct Package_YT_CommonSetting_TeleSignaling_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //遥信参数定值遥调地址
    uint16_t Length;
    CommonSetting_TeleSignaling_Struct TeleSignaling;
};

struct Package_YT_CommonSetting_TeleControlling_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //遥控参数定值遥调地址
    uint16_t Length;
    CommonSetting_TeleControlling_Struct TeleControlling;
};

struct Package_YT_CommonSetting_ExceedingLimit_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //越限报警参数定值遥调地址
    uint16_t Length;
    CommonSetting_ExceedingLimit_Struct ExceedingLimit;
};

struct Package_YT_CommonSetting_Statistics_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //统计参数定值遥调地址
    uint16_t Length;
    CommonSetting_Statistics_Struct Statistics;
};

struct Package_YT_ProtectionSoftStrap_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //保护软压板定值遥调地址
    uint16_t Length;
    ProtectionSoftStrap_Struct SoftStrap;
};

struct Package_YT_RleaySetting_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //保护定值遥调地址
    uint16_t Length;
    uint16_t AreaCode;
    RelaySetting_Struct Setting;
};

struct Package_YT_RelaySetting_AreaCode_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //修改定值套号遥调地址
    uint16_t Length;
    uint16_t AreaCode;                                                           //定值区号
    uint16_t AreaCodeConfirm;                                                    //定值区号确认
};

struct Package_YT_CommonSetting_PrimarySystem_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //一次系统参数定值遥调地址
    uint16_t Length;
    CommonSetting_PrimarySystem_Struct PrimarySystem;
};

struct Package_YT_CommonSetting_AnalogQuantity_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr; //模拟量参数定值遥调地址
    uint16_t Length;
    CommonSetting_AnalogQuantity_Struct AnalogQuantity;
};

struct RemoteAdjust_PowerQualitySetting_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr;
    uint16_t Length;
    PowerQualitySetting_struct PowerQualitySetting;
};

struct RemoteAdjust_FaultRecordSetting_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr;
    uint16_t Length;
    FaultRecordSetting_Struct FaultRecordSetting;
};

struct RemoteAdjust_BPMU_Setting_Struct {
    uint16_t Common_addr; //Common_Addr_RemoteAdjust
    uint16_t Object_addr;
    uint16_t Length;
    BroadbandPhasorSetting_Struct BroadbandPhasorSetting;
};

struct RemoteControl_Struct {
    uint16_t Common_addr;
    uint16_t Object_addr;	//保护元件动作代码:启动元件动作
    uint16_t Length;
    uint8_t State;          //8bit=0,0,0,0,0,0,状态(01:open, 10:close)
    uint8_t State_Confirm;	//8bit=0,0,0,0,0,0,状态(01:open, 10:close)
};

struct SOE_Start_Struct {
    uint16_t Common_addr; //Common_Addr_SOE
    uint16_t Object_addr; //保护元件动作代码:启动元件动作
    uint16_t Length;
    uint8_t Information; //8bit=0,0,0,0,A相，B相，C相
    uint16_t Time_ms;    //0~59999
    uint8_t Time_min;    //0~59
    uint8_t Time_hour;   //0~23
    uint8_t Time_day;    //1~31
    uint8_t Time_month;  //1~12
    uint8_t Time_year;   //0~99
};

struct SOE_Act_Struct {
    uint16_t Common_addr; //Common_Addr_SOE
    uint16_t Object_addr; //保护元件动作代码:保护元件动作
    uint16_t Length;
    uint8_t Information; //8bit=0,0,0,0,A相，B相，C相
    uint16_t Time_ms;    //0~59999
};

struct SOE_3Value_Struct {
    uint16_t Common_addr; //Common_Addr_SOE
    uint16_t Object_addr; //保护元件动作代码:动作值
    uint16_t Length;
    float Value1;
    float Value2;
    float Value3;
};

struct SOE_2Value_Struct {
    uint16_t Common_addr; //Common_Addr_SOE
    uint16_t Object_addr; //保护元件动作代码:动作值
    uint16_t Length;
    float Value1;
    float Value2;
};

struct SOE_1Value_Struct {
    uint16_t Common_addr; //Common_Addr_SOE
    uint16_t Object_addr; //保护元件动作代码:动作值
    uint16_t Length;
    float Value;
};

struct SOE_Node_Struct {
    uint16_t type;			//Common_Addr_SOE
    uint16_t Object_addr;	//保护元件动作代码:启动元件动作
    uint32_t GroupNum;
    uint16_t Information;	//
    uint16_t Time_ms;		//0~59999
    uint8_t Time_s;			//0~59
    uint8_t Time_min;		//0~59
    uint8_t Time_hour;		//0~23
    uint8_t Time_day;		//1~31
    uint8_t Time_month;		//1~12
    uint8_t Time_year;		//0~99
    float Value1;
    float Value2;
    float Value3;
};
#pragma pack(pop)
} // namespace jybsmr131
