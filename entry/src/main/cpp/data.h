#ifndef DATA_H
#define DATA_H

#include <iostream>
#include <complex.h>
#include <cstdint>  // 提供 uint8_t / uint16_t / uint32_t 这类固定宽度整数类型
#include <deque>    // 提供 std::deque，用来替代原来的 QQueue

#define SETTING_FILE_NAME "/data/Setting_Set_"
#define REPORT_SIGN_NAME "file.txt"
#define REPORT_ACTIVE_TXT "/data/report/"
#define SQLITE_HARMONIC_TABLE "harmonic"

#define SETTING_FILE_DIR "/data/"


#pragma pack(1)

//断路器当前状态
extern uint8_t  BreakerState_Now;

struct RemoteSignal
{
    uint8_t State;	//8bit= 0x01:open, 0x02:close
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;	//0~59
    uint8_t Time_hour;	//0~23
    uint8_t Time_day;	//1~31
    uint8_t Time_month;	//1~12
    uint8_t Time_year;	//0~99
};

typedef struct
{
    uint8_t State;      //8bit=0,0,0,0,0,0,状态(01:Open/Fault, 10:Close/Right)
    uint16_t Time_ms;	//0~59999
    uint8_t Time_min;	//0~59
    uint8_t Time_hour;	//0~23
    uint8_t Time_day;	//1~31
    uint8_t Time_month;	//1~12
    uint8_t Time_year;	//0~99
    uint16_t CRC;
}RemoteSignal_Change_Struct;
#define YX_Change_DataLenth 10
#define YX_Change_CRC16Lenth 4


//typedef struct
//{
//        //Common_Addr_SOE
//        //保护元件动作代码:启动元件动作
//    uint8_t Information;	//8bit=0,0,0,0,A相，B相，C相
//    uint16_t Time_ms;		//0~59999
//    uint8_t Time_min;	//0~59
//    uint8_t Time_hour;	//0~23
//    uint8_t Time_day;	//1~31
//    uint8_t Time_month;	//1~12
//    uint8_t Time_year;	//0~99
//}SOE_Start_Struct;

//typedef struct
//{
//        //Common_Addr_SOE
//        //保护元件动作代码:保护元件动作

//    uint8_t Information;	//8bit=0,0,0,0,A相，B相，C相
//    uint16_t Time_ms;		//0~59999
//}SOE_Act_Struct;

typedef struct
{
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;	//0~59
    uint8_t Time_hour;	//0~23
    uint8_t Time_day;	//1~31
    uint8_t Time_month;	//1~12
    uint8_t Time_year;	//0~99

    uint8_t MonitoringKM;
    uint8_t DisableReclose;
    uint8_t SprintLessEnergy;
    uint8_t ExternalTrip;
    uint8_t ExternalClose;
    uint8_t PWRboard24V;
    uint8_t TWJ;
    uint8_t HWJ;
    uint8_t HHJ;
    uint8_t STJ;
    uint8_t RTJ;
    uint8_t OverCurrentProtection;
    uint8_t IoProtection;
    uint8_t BusProtection;
    uint8_t Reclose	;
    uint8_t GroundingChoicTrip;
    uint8_t ResetButton;
    uint8_t DeviceMaintain;
    uint8_t RemoteOrLocal;
}RemoteSignalALL_Struct;

typedef struct
{
    uint8_t MonitoringKM;
    uint8_t DisableReclose;
    uint8_t SprintLessEnergy;
    uint8_t ExternalTrip;
    uint8_t ExternalClose;
    uint8_t PWRboard24V;

    uint8_t TWJ_Flag;
    uint8_t HWJ_Flag;
    uint8_t HHJ_Flag;
    uint8_t STJ_Flag;
    uint8_t RTJ_Flag;

    uint8_t PilotProtection;
    uint8_t LowFreqProtection;
    uint8_t LowVoltProtection;
    uint8_t OutageReclose;
    uint8_t ResetButton;
    uint8_t DeviceMaintain;
    uint8_t RemoteOrLocal;
    uint8_t GroundingChoicTrip;
}DigitalInputData_Struct;
extern DigitalInputData_Struct DigitalInputData;

typedef struct
{
	uint16_t Time_ms;			//0~59999
	uint8_t Time_min;			//0~59
	uint8_t Time_hour;		//0~23
	uint8_t Time_day;			//1~31
	uint8_t Time_month;		//1~12
	uint8_t Time_year;		//0~99
	
	uint32_t Flag_PTP_LockOK;
	
	float Ua_Frequency;
	float Ub_Frequency;
	float Uc_Frequency;
	float Ux_Frequency;
	
	float Ua_Rms, Ua_Phase;
	float Ub_Rms, Ub_Phase;
	float Uc_Rms, Uc_Phase;
	float Uo_Rms, Uo_Phase;

	float IA_Rms, IA_Phase;
	float IB_Rms, IB_Phase;
	float IC_Rms, IC_Phase;
	float Io_Rms, Io_Phase;

	float Ia_Rms, Ia_Phase;
	float Ib_Rms, Ib_Phase;
	float Ic_Rms, Ic_Phase;
	float Is_Rms, Is_Phase;					//»¤Ì×µçÁ÷	£¨²»ÏÔÊ¾£©
	
	float Ux_Rms, Ux_Phase;
	float Iby1_Rms, Iby1_Phase;			//±¸ÓÃµçÁ÷	£¨²»ÏÔÊ¾£©
	float Iby2_Rms, Iby2_Phase;			//±¸ÓÃµçÁ÷	£¨²»ÏÔÊ¾£©
	float Iby3_Rms, Iby3_Phase;			//±¸ÓÃµçÁ÷	£¨²»ÏÔÊ¾£©
	float Pa, Qa, Sa, Fa; //AÏàÓÐ¹¦¡¢ÎÞ¹¦¡¢ÊÓÔÚ¡¢¹¦ÂÊÒòÊý
    float Pb, Qb, Sb, Fb; //BÏàÓÐ¹¦¡¢ÎÞ¹¦¡¢ÊÓÔÚ¡¢¹¦ÂÊÒòÊý
    float Pc, Qc, Sc, Fc; //CÏàÓÐ¹¦¡¢ÎÞ¹¦¡¢ÊÓÔÚ¡¢¹¦ÂÊÒòÊý
    float Pt, Qt, St, Ft; //ºÏÏàÓÐ¹¦¡¢ÎÞ¹¦¡¢ÊÓÔÚ¡¢¹¦ÂÊÒòÊý
}__attribute__ ((packed,aligned(1))) YC_BaseFreq_Struct;	//宸ラ閬ユ祴鏁版嵁缁撴瀯
extern YC_BaseFreq_Struct BaseFreq_Dsip;
extern bool BaseFreqDisplayReady;
#define BaseFreq_DataLenth  sizeof(YC_BaseFreq_Struct)

typedef struct
{
    float Pos_Pa;
    float Pos_Pb;
    float Pos_Pc;
    float Pos_Ps;

    float Pos_Qa;
    float Pos_Qb;
    float Pos_Qc;
    float Pos_Qs;

    float Neg_Pa;
    float Neg_Pb;
    float Neg_Pc;
    float Neg_Ps;

    float Neg_Qa;
    float Neg_Qb;
    float Neg_Qc;
    float Neg_Qs;
}YC_Energy_Struct;	//宸ラ鐢佃兘鏁版嵁缁撴瀯
extern YC_Energy_Struct Energy_Dsip;
#define Energy_DataLenth  64

typedef struct
{
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;	//0~59
    uint8_t Time_hour;	//0~23
    uint8_t Time_day;	//1~31
    uint8_t Time_month;	//1~12
    uint8_t Time_year;	//0~99
    float Ua[30];   //Ua[0]工频频率，Ua[1]工频幅值，Ua[2]工频相位，Ua[3]谐波1频率，Ua[4]谐波1幅值，Ua[5]谐波1相位...
    float Ub[30];
    float Uc[30];
}__attribute__ ((packed,aligned(1))) YC_HarmonicU_Struct;	//璋愭尝鐢靛帇閬ユ祴鏁版嵁缁撴瀯
extern YC_HarmonicU_Struct HarmonicU_Dsip;
#define HarmonicU_DataLenth  367

typedef struct
{
    uint16_t Time_ms;	//0~59999
    uint8_t Time_min;	//0~59
    uint8_t Time_hour;	//0~23
    uint8_t Time_day;	//1~31
    uint8_t Time_month;	//1~12
    uint8_t Time_year;	//0~99
    float Ia[30];   //Ia[0]工频频率，Ia[1]工频幅值，Ia[2]工频相位，Ia[3]谐波1频率，Ia[4]谐波1幅值，Ia[5]谐波1相位...
    float Ib[30];
    float Ic[30];
}__attribute__ ((packed,aligned(1))) YC_HarmonicI_Struct;	//璋愭尝鐢垫祦閬ユ祴鏁版嵁缁撴瀯
extern YC_HarmonicI_Struct HarmonicI_Dsip;
#define HarmonicI_DataLenth  367

typedef struct
{
        //Common_Addr_RemoteAdjust
        //定值遥调地址（自定义）
    uint16_t Code;
}RemoteAdjust_Setting_number;


typedef struct
{
        //Common_Addr_RemoteAdjust
        //修改定值套号遥调地址（自定义）

    uint16_t SettingCode;	//定值套号
}RemoteAdjust_ChangeSettingCode_Struct;	//修改定值套号遥调数据结构


//谐波数据结构
typedef struct
{
    unsigned int Flag;
    float Ua[30];   //较高的10次谐波：幅值 相位 频率
    float Ub[30];
    float Uc[30];

    float Ia[30];
    float Ib[30];
    float Ic[30];
}CalResult_struct;
extern CalResult_struct CalResult;  //计算结果数据，较高的10次谐波

//遥测数据结构

typedef struct
{
    float Ua_Real, Ua_Imag,	Ua_RMS;
    float Ub_Real, Ub_Imag,	Ub_RMS;
    float Uc_Real, Uc_Imag,	Uc_RMS;
    float Uo_Real, Uo_Imag,	Uo_RMS;
    float Ux_Real, Ux_Imag,	Ux_RMS;

    float IA_Real, IA_Imag,	IA_RMS;
    float IB_Real, IB_Imag,	IB_RMS;
    float IC_Real, IC_Imag,	IC_RMS;
    float Io_Real, Io_Imag,	Io_RMS;

    float Ia_Real, Ia_Imag,	Ia_RMS;
    float Ib_Real, Ib_Imag,	Ib_RMS;
    float Ic_Real, Ic_Imag,	Ic_RMS;
    float Is_Real, Is_Imag,	Is_RMS;
}RemoteMetry_DFT_Struct;
extern RemoteMetry_DFT_Struct RemoteMetry_DFT;

//互感器变比数据结构
typedef struct
{
    unsigned int PT_Ratio;
    unsigned int CT_Ratio;
    unsigned int IoCT_Ratio;

    unsigned int PT_Pri;
    unsigned int CT_Pri;
    unsigned int CT_Sec;
    unsigned int IoCT_Pri;
    unsigned int IoCT_Sec;

    unsigned int CRC;
}TransformerRatio_Struct;		//长度0x0024

typedef struct
{
    uint16_t type;			//Common_Addr_SOE
    uint16_t Object_addr;	//保护元件动作代码:启动元件动作
    uint8_t GroupNum;
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
}__attribute__ ((packed,aligned(1))) SOE_Node_Struct;

inline uint32_t CRC32(uint32_t *pCRC, uint32_t Len)
{
    uint32_t CRC_val=0;
    for(uint32_t i=0; i<Len; i++)
    {
        CRC_val = CRC_val^*pCRC;
        pCRC++;
    }
    return CRC_val;
}

inline uint16_t CRC16(uint16_t *p, uint16_t length)
{
    uint16_t crcVal=0,i=0;
    for(i=0;i<length;i++)
    {
        crcVal=crcVal^*p;
        p++;
    }
    return crcVal;
}

#define DATA_QUEUE_MAX_LENGTH        100
extern std::deque<YC_BaseFreq_Struct> BaseFreq_Queue;
extern std::deque<YC_Energy_Struct> Energy_Queue;
extern std::deque<YC_HarmonicU_Struct> HarmonicU_Queue;
extern std::deque<YC_HarmonicI_Struct> HarmonicI_Queue;
extern std::deque<RemoteSignal_Change_Struct> YX_Change_Queue;
extern std::deque<SOE_Node_Struct> SOE_Node_Queue;
//extern RelaySetting_Struct RelaySetting[20];

extern unsigned int SettingCode;
extern unsigned int ChangeSettingCode_Flag;

#pragma pack()

#endif // DATA_H
