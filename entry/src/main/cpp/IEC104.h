#ifndef IEC104_H
#define IEC104_H
#include <iostream>
#include <complex.h>
#include "data.h"

#define	Common_Addr_RemoteMetry		0x0011	//遥测
#define	Common_Addr_RemoteControl	0x0022	//遥控
#define	Common_Addr_RemoteSignal	0x0033	//遥信
#define	Common_Addr_RemoteAdjust	0x0044	//遥调
#define	Common_Addr_SOE				0x0055	//SOE

#define	SOE_StartMark		0x1000	//SOE
#define	SOE_ActMark         0x2000	//SOE
#define	SOE_ValueMark		0x3000	//SOE
#define	SOE_EventMark		0x4000	//SOE

#define	SOE_StartDataLen	9	//SOE
#define	SOE_ActDataLen      4	//SOE
#define	SOE_3ValueDataLen	13	//SOE
#define	SOE_2ValueDataLen	9	//SOE
#define	SOE_1ValueDataLen	5	//SOE
#define	SOE_EventDataLen	9	//SOE

#define SOE_Type_Start		0x0001
#define SOE_Type_Act		0x0002
#define SOE_Type_3Value		0x0003
#define SOE_Type_2Value		0x0004
#define SOE_Type_1Value		0x0005
//SOE报文结构:
//SOE_Start+(SOE_Act_Struct+SOE_Value3A_Struct*n)*m
//SOE_Start+(SOE_Act_Struct+SOE_Value2A_Struct*n)*m
//SOE_Start+(SOE_Act_Struct+SOE_Value_Struct*n)*m

#define RemoteMetry_BaseFreq		0x0011
#define RemoteMetry_PowerEnergy		0x0022
#define RemoteMetry_HarmonicU		0x0033
#define RemoteMetry_HarmonicI		0x0044

#define RemoteControl_BHH1			0x0001
#define RemoteControl_BTJ1			0x0002
#define RemoteControl_BHJ1			0x0003
#define RemoteControl_YTJ1			0x0004
#define RemoteControl_YHJ1			0x0005
#define RemoteControl_BTJ2			0x0006
#define RemoteControl_BHJ2			0x0007
#define RemoteControl_YTJ2			0x0008
#define RemoteControl_YHJ2			0x0009
#define RemoteControl_CKJ1			0x000a
#define RemoteControl_CKJ2			0x000b
#define RemoteControl_CKJ3			0x000c
#define RemoteControl_BTXJ			0x000d
#define RemoteControl_BHXJ			0x000e
#define RemoteControl_GJJ			0x000f
#define RemoteControl_YCJ			0x0010
#define RemoteControl_FGJ			0x0020
#define RemoteControl_SGZJ			0x0030
#define RemoteControl_BYJ1			0x0040
#define RemoteControl_BYJ2			0x0050
#define RemoteControl_BYJ3			0x0060
#define RemoteControl_MC1			0x0070
#define RemoteControl_MC2			0x0080

#define RemoteControl_QDJ1			0x0101
#define RemoteControl_QDJ2			0x0102
#define RemoteControl_QDJ3			0x0103




#define RemoteSignal_MonitoringKM		0x0101		//DIa1——(DIO插件KM电压监测)
#define RemoteSignal_DisableReclose		0x0102		//DIa2——(DIO插件开入1：闭锁重合闸)
#define RemoteSignal_SprintLessEnergy	0x0103		//DIa3——(DIO插件开入2：弹簧未储能开入)
#define RemoteSignal_ExternalTrip		0x0104		//DIa4——(DIO插件开入3：外部跳闸开入)
#define RemoteSignal_ExternalClose		0x0105		//DIa5——(DIO插件开入4：外部合闸开入)
#define RemoteSignal_PWRboard24V		0x0106		//DIa14——(PWR插件24V输出电压检测)

#define RemoteSignal_TWJ				0x0107		//DIb1——(TWJ动作检测)
#define RemoteSignal_HWJ				0x0108		//DIb2——(HWJ动作检测)
#define RemoteSignal_HHJ				0x0109		//DIb3——(HHJ动作检测)
#define RemoteSignal_STJ				0x010A		//DIb4——(STJ动作检测)
#define RemoteSignal_RTJ				0x010B		//DIb5——(RTJ动作检测)

#define RemoteSignal_Type_Mask          0x0F00      //开入遥信标志
#define RemoteSignal_PilotProtection	0x010C		//DIc1——(CPU插件开入1：纵联保护硬压板)
#define RemoteSignal_LowFreqProtection	0x010D		//DIc2——(CPU插件开入2：低频减载保护硬压板)
#define RemoteSignal_LowVoltProtection	0x010E		//DIc3——(CPU插件开入3：低压减载保护硬压板)
#define RemoteSignal_OutageReclose		0x010F		//DIc4——(CPU插件开入4：停用重合闸硬压板)
#define RemoteSignal_ResetButton		0x0110		//DIc8——(CPU插件开入13：复归按钮)
#define RemoteSignal_DeviceMaintain		0x0111		//DIc13——(CPU插件开入14：检修压板)
#define RemoteSignal_RemoteOrLocal		0x0112		//DIc14——(CPU插件开入15：远方/就地转换开关)
#define RemoteSignal_GroundingChoicTrip	0x0113		//DIc15——(CPU插件开入8：接地选跳)
#define RemoteSignal_BreakState			0x0121		//断路器位置
#define RemoteSignal_DI_Mask            0x0100      //开入遥信标志

#define RemoteSignal_LED_Run			0x0321		//运行LED
#define RemoteSignal_LED_Alarm			0x0322		//告警LED
#define RemoteSignal_LED_Triping		0x0323		//跳闸LED
#define RemoteSignal_LED_Closing		0x0324		//合闸LED
//#define RemoteSignal_LED_BreakState		0x0325		//断路器位置LED
//#define RemoteSignal_LED_Closed			0x0326		//合位LED
#define RemoteSignal_LED_Charge			0x0327		//充电LED
#define RemoteSignal_LED_Sync			0x0328		//同步LED
#define RemoteSignal_LED_Comm			0x0329		//通信LED
#define RemoteSignal_LED_Backup			0x032A		//备用LED
#define RemoteSignal_LED_Mask           0x0300      //LED遥信标志

#define RemoteSignal_RAState_Mask           0x0200      //遥调状态标志

#define YX_ObjectAddr_CommonSetting_PrimarySystem		0x0201	// 一次系统参数定值
#define YX_ObjectAddr_CommonSetting_AnalogQuantity      0x0202	// 模拟量参数定值
#define YX_ObjectAddr_CommonSetting_TeleMeasuring		0x0203	// 遥测参数定值
#define YX_ObjectAddr_CommonSetting_TeleSignaling		0x0204	// 遥信参数定值
#define YX_ObjectAddr_CommonSetting_TeleControlling     0x0205	// 遥控参数定值
#define YX_ObjectAddr_CommonSetting_ExceedingLimit      0x0206	// 越限报警参数定值
#define YX_ObjectAddr_CommonSetting_Statistics			0x0207	// 统计参数定值
#define YX_ObjectAddr_CommonSetting_PowerQuality		0x0208	// 电能质量告警定值

#define YX_ObjectAddr_ProtectionSoftStrap				0x0209	// 保护软压板定值
#define YX_ObjectAddr_RelaySetting						0x020A	// 保护定值
#define YX_ObjectAddr_RelaySetting_AreaCode				0x020B	// 保护定值区号

#define YT_ObjectAddr_CommonSetting_PrimarySystem		0x0011	// 一次系统参数定值
#define YT_ObjectAddr_CommonSetting_AnalogQuantity		0x0022	// 模拟量参数定值
#define YT_ObjectAddr_CommonSetting_TeleMeasuring		0x0033	// 遥测参数定值
#define YT_ObjectAddr_CommonSetting_TeleSignaling		0x0044	// 遥信参数定值
#define YT_ObjectAddr_CommonSetting_TeleControlling     0x0055	// 遥控参数定值
#define YT_ObjectAddr_CommonSetting_ExceedingLimit		0x0066	// 越限报警参数定值
#define YT_ObjectAddr_CommonSetting_Statistics			0x0077	// 统计参数定值
#define YT_ObjectAddr_CommonSetting_PowerQuality		0x0088	// 电能质量告警定值

#define YT_ObjectAddr_ProtectionSoftStrap				0x0099	// 保护软压板定值
#define YT_ObjectAddr_RelaySetting						0x00AA	// 保护定值
#define YT_ObjectAddr_RelaySetting_AreaCode				0x00BB	// 保护定值区号

#define SOE_Type_Start		0x0001
#define SOE_Type_Act		0x0002
#define SOE_Type_3Value		0x0003
#define SOE_Type_2Value		0x0004
#define SOE_Type_1Value		0x0005

/**********************************************************/
/************************相别定义**************************/
/**********************************************************/
#define Phase_A		0x01
#define Phase_B   	0x02
#define Phase_C   	0x04
#define Phase_AB	0x03
#define Phase_BC	0x06
#define Phase_CA	0x05
#define Phase_ABC	0x07

/**************************************************************/
/*********************断路器/开关状态位**************************/
/**************************************************************/

#define  SW_Open	0x01
#define  SW_Close	0x10
#define  SW_UnCertain       0x00
#define  SW_CtrlCircuitOpen	0x11

#define  LED_Off	0x01
#define  LED_On		0x10

/***********************************************************************/
/*****************************保护元件动作代码**************************/
//********** 16位代码命名规则：
//********** [8-11]=1代表启动元件动作
//********** [8-11]=2代表保护元件动作
//********** [8-11]=3代表动作值
//********** [8-11]=4代表事件报告
/***********************************************************************/
/***********************************************************************/
/*****************************保护元件动作代码**************************/
/***********************************************************************/
#define  Cd_CurrentMutationStartMoment				0x1001	//电流突变量启动元件动作/****年**月**日**：**：**.***
#define  Cd_CurrentStartMoment						0x1002	//电流启动元件动作/****年**月**日**：**：**.***
#define  Cd_ZeroSequenceCurrentMutationStartMoment	0x1003	//零序电流突变量启动元件动作/****年**月**日**：**：**.***
#define  Cd_ZeroSequenceCurrentStartMoment			0x1004  //零序电流启动元件动作/****年**月**日**：**：**.***

#define  Cd_OverLoad_StartMoment			0x1201	//过负荷元件启动/****年**月**日**：**：**.***
#define  Cd_OverLoad_ReturnMoment			0x1202	//过负荷元件返回/****年**月**日**：**：**.***

#define  Cd_LowFrequency_StartMoment		0x1301	//低周减载元件启动/****年**月**日**：**：**.***
#define  Cd_LowFrequency_ReturnMoment		0x1302	//低周减载元件返回/****年**月**日**：**：**.***

#define  Cd_LowVoltage_StartMoment			0x1401	//低电压元件启动/****年**月**日**：**：**.***
#define  Cd_LowVoltage_ReturnMoment			0x1402	//低电压元件返回/****年**月**日**：**：**.***

#define  Cd_MisTripStartReclosureMoment		0x1071	//开关不对称启动重合闸/****年**月**日**：**：**.***

#define  Cd_RemoteTripMoment				0x1081	//远方跳闸/****年**月**日**：**：**.***
#define  Cd_RemoteCloseMoment				0x1082	//远方合闸/****年**月**日**：**：**.***


#define  Cd_FaultChoicePhase	0x2001	//故障选相，时间：**ms
#define  Cd_FaultPhase 			0x2002	//故障相别：A相/B相/C相/AB相/BC相/CA相/ABC相

#define  Cd_I_Z1_Act        	0x2011	//电流I段保护动作，时间：**ms
#define  Cd_I_Z2_Act          	0x2012	//电流II段保护动作，时间：**ms
#define  Cd_I_Z3_Act          	0x2013	//电流III段保护动作，时间：**ms
#define  Cd_I_PtBreak_Act       0x2014	//PT断线相过流保护动作，时间：**ms
#define  Cd_I_InverseTime_Act	0x2015	//电流反时限保护动作，时间：**ms
#define  Cd_I_RecloseAcc_Act   	0x2016	//重合闸后加速电流保护动作，时间：**ms
#define  Cd_I_ManCloseAcc_Act	0x2017	//手合加速电流保护动作，时间：**ms

#define  Cd_Io_Z1_Act         	0x2021	//零序电流I段保护动作，时间：**ms
#define  Cd_Io_Z2_Act         	0x2022	//零序电流II段保护动作，时间：**ms
#define  Cd_Io_Z3_Act         	0x2023	//零序电流III段保护动作，时间：**ms
#define  Cd_Io_InverseTime_Act	0x2024	//零序电流反时限保护动作，时间：**ms
#define  Cd_Io_RecloseAcc_Act   0x2025	//重合闸后加速零序电流保护动作，时间：**ms
#define  Cd_Io_ManCloseAcc_Act  0x2026	//手合加速零序电流保护动作，时间：**ms

#define  Cd_Io_Z1_Alarm     		0x2031	//零序电流I段保护告警，时间：**ms
#define  Cd_Io_Z2_Alarm         	0x2032	//零序电流II段保护告警，时间：**ms
#define  Cd_Io_Z3_Alarm         	0x2033	//零序电流III段保护告警，时间：**ms
#define  Cd_Io_InverseTime_Alarm	0x2034	//零序电流反时限保护告警，时间：**ms

#define  Cd_IoSelfAdapt_Z1_Act  		0x2041	//自适应零序电流I段保护动作，时间：**ms
#define  Cd_IoSelfAdapt_Z2_Act  		0x2042	//自适应零序电流II段保护动作，时间：**ms
#define  Cd_IoSelfAdapt_Z3_Act  		0x2043	//自适应零序电流III段保护动作，时间：**ms
#define  Cd_IoSelfAdapt_InverseTime_Act	0x2044	//自适应零序电流反时限保护动作，时间：**ms
#define  Cd_IoSelfAdapt_RecloseAcc_Act  0x2045	//重合闸后加速自适应零序电流保护动作，时间：**ms
#define  Cd_IoSelfAdapt_ManCloseAcc_Act 0x2046	//手合加速自适应零序电流保护动作，时间：**ms

#define  Cd_IoSelfAdapt_Z1_Alarm  			0x2051	//自适应零序电流I段保护告警，时间：**ms
#define  Cd_IoSelfAdapt_Z2_Alarm  			0x2052	//自适应零序电流II段保护告警，时间：**ms
#define  Cd_IoSelfAdapt_Z3_Alarm  			0x2053	//自适应零序电流III段保护告警，时间：**ms
#define  Cd_IoSelfAdapt_InverseTime_Alarm	0x2054	//自适应零序电流反时限保护告警，时间：**ms

#define  Cd_BusProtection_Act				0x2061	//闭锁式母线保护动作，时间：**ms

#define  Cd_ProtectionStartReclosure_Act	0x2071	//保护启动重合闸，时间：**ms
#define  Cd_Reclosure_Act					0x2072	//重合闸动作，时间：**ms

#define  Cd_ResetTripOrderTime				0x2081	//跳闸继电器返回，时间：**ms
#define  Cd_ResetCloseOrderTime				0x2082	//合闸继电器返回，时间：**ms
#define  Cd_TripNotSuccess					0x2083	//跳闸不成功，时间：**ms
#define  Cd_RecloseNotSuccess				0x2084	//合闸不成功，时间：**ms

#define  Cd_OverLoad_Trip					0x2091	//过负荷动作，时间：**ms
#define  Cd_OverLoad_Alarm					0x2092	//过负荷告警，时间：**ms

#define  Cd_LowFrequency_Trip				0x20A1	//低周保护动作，时间：**ms
#define  Cd_LowFrequency_Alarm				0x20A2	//低周保护告警，时间：**ms

#define  Cd_LowVoltage_Trip					0x20B1	//低压保护动作，时间：**ms
#define  Cd_LowVoltage_Alarm				0x20B2	//低压保护告警，时间：**ms

#define  Cd_ProtectionGlobalReset_Act		0x20C1	//保护整组复归，时间：**ms

#define  Cd_Idiff_Act_A        	0x20D1	//A相电流差动保护动作，时间：**ms
#define  Cd_Idiff_Act_B        	0x20D2	//B相电流差动保护动作，时间：**ms
#define  Cd_Idiff_Act_C        	0x20D3	//C相电流差动保护动作，时间：**ms
#define  Cd_IdiffCombined_Act_C 0x20D4	//C相电流差动保护动作，时间：**ms

#define  Cd_IoPilot_Act        	0x20D5	//零序电流纵联保护动作，时间：**ms
#define  Cd_IoPilotCombined_Act 0x20D6	//零序电流纵联保护联跳动作，时间：**ms

#define  Cd_UoPilot_Act        0x20D7	//线路断线零序纵联保护动作，时间：**ms
#define  Cd_UoPilotCombined_Act 0x20D8	//线路断线零序纵联保护联跳动作，时间：**ms
/*******************************************************************/
/*****************************保护动作值代码*************************/
/*******************************************************************/
#define  Cd_Ua_RMS					0x3001	//A相电压：**.**V
#define  Cd_Ub_RMS					0x3002	//B相电压：**.**V
#define  Cd_Uc_RMS					0x3003	//C相电压：**.**V
#define  Cd_Uo_RMS					0x3004	//零序电压：**.**V
#define  Cd_IA_RMS					0x3005	//A相保护电流：**.**A
#define  Cd_IB_RMS					0x3006	//B相保护电流：**.**A
#define  Cd_IC_RMS					0x3007	//C相保护电流：**.**A
#define  Cd_Io_RMS					0x3008	//零序电流：**.**A
#define  Cd_Ia_RMS					0x3009	//A相测量电流：**.**A
#define  Cd_Ib_RMS					0x300A	//B相测量电流：**.**A
#define  Cd_Ic_RMS					0x300B	//C相测量电流：**.**A
#define  Cd_Is_RMS					0x300C	//护套电流：**.**A
#define  Cd_Ux_RMS					0x300D	//线路电压：**.**V

#define  Cd_Act_Ua_RMS				0x3101	//A相电压动作值：**.**V
#define  Cd_Return_Ua_RMS			0x3102	//A相电压返回值：**.**V
#define  Cd_Act_Ub_RMS				0x3103	//B相电压动作值：**.**V
#define  Cd_Return_Ub_RMS			0x3104	//B相电压返回值：**.**V
#define  Cd_Act_Uc_RMS				0x3105	//C相电压动作值：**.**V
#define  Cd_Return_Uc_RMS			0x3106	//B相电压返回值：**.**V
#define  Cd_Act_Uo_RMS				0x3107	//零序电压动作值：**.**V
#define  Cd_Return_Uo_RMS			0x3108	//零序电压返回值：**.**V
#define  Cd_Act_Uabc_RMS			0x3109	//ABC三相电压动作值：**.**V，**.**V，**.**V
#define  Cd_Return_Uabc_RMS			0x310A	//ABC三相电压返回值：**.**V，**.**V，**.**V

#define  Cd_Act_IA_RMS				0x3201	//A相电流动作值：**.**A
#define  Cd_Return_IA_RMS			0x3202	//A相电流返回值：**.**A
#define  Cd_Act_IB_RMS				0x3203	//B相电流动作值：**.**A
#define  Cd_Return_IB_RMS			0x3204	//B相电流返回值：**.**A
#define  Cd_Act_IC_RMS				0x3205	//C相电流动作值：**.**A
#define  Cd_Return_IC_RMS			0x3206	//C相电流返回值：**.**A
#define  Cd_Act_Io_RMS				0x3207	//零序电流动作值：**.**A
#define  Cd_Return_Io_RMS			0x3208	//零序电流返回值：**.**A
#define  Cd_Act_IABC_RMS			0x3209	//ABC三相电流动作值：**.**A，**.**A，**.**A
#define  Cd_Return_IABC_RMS			0x320A	//ABC三相电流返回值：**.**A，**.**A，**.**A

#define  Cd_Act_IoUo_RMS			0x3301	//零序电流电压动作值：**.**A,**.**V

#define  Cd_Act_Ia_RMS				0x3401	//A相测量电流动作值：**.**A
#define  Cd_Return_Ia_RMS			0x3402	//A相测量电流返回值：**.**A
#define  Cd_Act_Ib_RMS				0x3403	//B相测量电流动作值：**.**A
#define  Cd_Return_Ib_RMS			0x3404	//B相测量电流返回值：**.**A
#define  Cd_Act_Ic_RMS				0x3405	//C相测量电流动作值：**.**A
#define  Cd_Return_Ic_RMS			0x3406	//C相测量电流返回值：**.**A
#define  Cd_Act_Iabc_RMS			0x3407	//ABC三相测量电流动作值：**.**A，**.**A，**.**A
#define  Cd_Return_Iabc_RMS			0x3408	//ABC三相测量电流返回值：**.**A，**.**A，**.**A

#define  Cd_Act_Is_RMS				0x3501	//护套电流动作值：**.**A
#define  Cd_Return_Is_RMS			0x3502	//护套电流返回值：**.**A

#define  Cd_Act_Ux_RMS				0x3601	//线路电压动作值：**.**V
#define  Cd_Return_Ux_RMS			0x3602	//线路电压返回值：**.**V

#define  Cd_Act_IoSelfAdapt_RMS		0x3701  //自适应零序电流动作值：**.**A
#define  Cd_Return_IoSelfAdapt_RMS	0x3702  //自适应零序电流返回值：**.**A
#define  Cd_Act_IoUoSelfAdapt_RMS	0x3703  //自适应零序电流电压动作值：**.**A，**.**V

#define  Cd_Act_Uab_RMS   			0x3801	//AB相电压动作值：**.**V
#define  Cd_Return_Uab_RMS   		0x3802	//AB相电压返回值：**.**V
#define  Cd_Act_Ubc_RMS   			0x3803	//BC相电压动作值：**.**V
#define  Cd_Return_Ubc_RMS   		0x3804	//BC相电压返回值：**.**V
#define  Cd_Act_Uca_RMS   			0x3805	//CA相电压动作值：**.**V
#define  Cd_Return_Uca_RMS   		0x3806	//CA相电压返回值：**.**V
#define  Cd_Act_UabUbcUca_RMS   	0x3807	//三相线电压动作值：**.**V，**.**V，**.**V
#define  Cd_Return_UabUbcUca_RMS   	0x3808	//三相线电压返回值：**.**V，**.**V，**.**V

#define  Cd_Act_U2_RMS				0x3901	//负序电压动作值：**.**V
#define  Cd_Return_U2_RMS			0x3902	//负序电压返回值：**.**V
#define  Cd_Act_I2_RMS				0x3A01	//负序电流动作值：**.**V
#define  Cd_Return_I2_RMS			0x3A02	//负序电流返回值：**.**V

#define  Cd_Act_Za					0x3B01	//A相阻抗动作值：**.** + j**.**
#define  Cd_Return_Za				0x3B02	//A相阻抗返回值：**.** + j**.**
#define  Cd_Act_Zb					0x2B03	//B相阻抗动作值：**.** + j**.**
#define  Cd_Return_Zb				0x3B04	//B相阻抗返回值：**.** + j**.**
#define  Cd_Act_Zc					0x3B05	//C相阻抗动作值：**.** + j**.**
#define  Cd_Return_Zc				0x3B06	//C相阻抗返回值：**.** + j**.**
#define  Cd_Act_Zab					0x3B07	//AB相阻抗动作值：**.** + j**.**
#define  Cd_Return_Zab				0x3B08	//AB相阻抗返回值：**.** + j**.**
#define  Cd_Act_Zbc					0x3B09	//BC相阻抗动作值：**.** + j**.**
#define  Cd_Return_Zbc				0x3B0A	//BC相阻抗返回值：**.** + j**.**
#define  Cd_Act_Zca					0x3B0B	//CA相阻抗动作值：**.** + j**.**
#define  Cd_Return_Zca				0x3B0C	//CA相阻抗返回值：**.** + j**.**

#define  Cd_Act_FrequencyValue		0x3C01	//频率动作值：**.**Hz
#define  Cd_Return_FrequencyValue	0x3C02	//频率返回值：**.**Hz

#define  Cd_FaultDistence			0x3D01	//故障距离：**.**kM

#define  Cd_IA_OnSide				0x3E01	//本侧A相电流：**.** + j**.**A
#define  Cd_IA_OffSide				0x3E02	//对侧A相电流：**.** + j**.**A
#define  Cd_IB_OnSide				0x3E03	//本侧B相电流：**.** + j**.**A
#define  Cd_IB_OffSide				0x3E04	//对侧B相电流：**.** + j**.**A
#define  Cd_IC_OnSide				0x3E05	//本侧C相电流：**.** + j**.**A
#define  Cd_IC_OffSide				0x3E06	//对侧C相电流：**.** + j**.**A
#define  Cd_Io_OnSide				0x3E07	//本侧零序电流：**.** + j**.**A
#define  Cd_Io_OffSide				0x3E08	//对侧零序电流：**.** + j**.**A
#define  Cd_Uo_OnSide				0x3E09	//本侧零序电压：**.** + j**.**V
#define  Cd_Uo_OffSide				0x3E0A	//对侧零序电压：**.** + j**.**V
/******************************************************************/
/****************************事件代码******************************/
/******************************************************************/
#define	Cd_Err_ProgremRAM  			0x4001  //程序存储空间自检出错/****年**月**日**：**：**.***
#define	Cd_Err_DataRAM   			0x4002  //数据存储空间自检出错/****年**月**日**：**：**.***
#define Cd_Err_ProtectionSetting   	0x4003  //保护定值自检出错/****年**月**日**：**：**.***
#define Cd_Err_AnalogCoeff 			0x4004  //模拟通道系数自检出错/****年**月**日**：**：**.***
#define	Cd_Err_PTCTRatio			0x4005	//PT、CT变比自检出错/****年**月**日**：**：**.***

#define Cd_Err_U           			0x4011  //电压回路自检出错/****年**月**日**：**：**.***
#define Cd_Err_I           			0x4012  //电流回路自检出错/****年**月**日**：**：**.***
#define Cd_Err_BusPTDX_3P  			0x4013	//母线PT三相断线/****年**月**日**：**：**.***
#define Cd_Err_BusPTDX_3P_Block  	0x4113	//母线PT三相断线闭锁相关保护/****年**月**日**：**：**.***
#define Cd_Err_BusPTDX_2P  			0x4014	//母线PT两相断线/****年**月**日**：**：**.***
#define Cd_Err_BusPTDX_2P_Block		0x4114	//母线PT两相断线闭锁相关保护/****年**月**日**：**：**.***
#define Cd_Err_BusPTDX_1P  			0x4015  //母线PT单相断线/****年**月**日**：**：**.***
#define Cd_Err_BusPTDX_1P_Block		0x4115  //母线PT单相断线闭锁相关保护/****年**月**日**：**：**.***
#define Cd_Err_LinePTDX   			0x4016  //线路PT断线/****年**月**日**：**：**.***
#define Cd_Err_CTDX_A_Onside		0x4017  //本侧A相CT断线/****年**月**日**：**：**.***
#define Cd_Err_CTDX_A_Offside		0x4018  //对侧A相CT断线/****年**月**日**：**：**.***
#define Cd_Err_CTDX_B_Onside		0x4019  //本侧B相CT断线/****年**月**日**：**：**.***
#define Cd_Err_CTDX_B_Offside		0x401A  //对侧B相CT断线/****年**月**日**：**：**.***
#define Cd_Err_CTDX_C_Onside		0x401B  //本侧C相CT断线/****年**月**日**：**：**.***
#define Cd_Err_CTDX_C_Offside		0x401C  //对侧C相CT断线/****年**月**日**：**：**.***

#define Cd_Err_CtlCircuit	0x4021  //控制回路断线/****年**月**日**：**：**.***
#define Cd_Err_DO_Relay		0x4022  //保护开出出错/****年**月**日**：**：**.***
#define Cd_Err_DO_Alarm		0x4023  //告警开出出错/****年**月**日**：**：**.***
#define Cd_Err_RemoteTZ   	0x4024  //遥控跳闸失败/****年**月**日**：**：**.***
#define Cd_Err_RemoteHZ		0x4025  //遥控合闸失败/****年**月**日**：**：**.***
#define Cd_Err_RemoteFG   	0x4026  //遥控复归失败/****年**月**日**：**：**.***

extern QString SOE_StartString(uint16_t StartCode);
extern QString SOE_ActString(uint16_t StartCode);
extern QString SOE_PhaseString(uint8_t PhaseInfo);
extern QString SOE_3ValString(SOE_Node_Struct tNode);
extern QString SOE_2ValString(SOE_Node_Struct tNode);
extern QString SOE_1ValString(SOE_Node_Struct tNode);

typedef struct
{
    uint16_t Common_addr;
    uint16_t Object_addr;	//保护元件动作代码:启动元件动作
    uint16_t Length;
    uint8_t State;          //8bit=0,0,0,0,0,0,状态(01:open, 10:close)
    uint8_t State_Confirm;	//8bit=0,0,0,0,0,0,状态(01:open, 10:close)
}__attribute__ ((packed,aligned(1))) RemoteControl_Struct;

typedef struct
{
    uint16_t Object_addr;	//保护元件动作代码:启动元件动作
    uint16_t Length;
    uint8_t GroupNum;
    uint8_t Information;	//8bit=0,0,0,0,A相，B相，C相
    uint16_t Time_ms;		//0~59999
    uint8_t Time_min;	//0~59
    uint8_t Time_hour;	//0~23
    uint8_t Time_day;	//1~31
    uint8_t Time_month;	//1~12
    uint8_t Time_year;	//0~99
}__attribute__ ((packed,aligned(1))) SOE_Start_Struct;

typedef struct
{
    uint16_t Object_addr;	//保护元件动作代码:保护元件动作
    uint16_t Length;
    uint8_t GroupNum;
    uint8_t Information;	//8bit=0,0,0,0,A相，B相，C相
    uint16_t Time_ms;		//0~59999
}__attribute__ ((packed,aligned(1))) SOE_Act_Struct;

typedef struct
{
    uint16_t Object_addr;	//保护元件动作代码:动作值
    uint16_t Length;
    uint8_t GroupNum;
    float Value1;
    float Value2;
    float Value3;
}__attribute__ ((packed,aligned(1))) SOE_3Value_Struct;

typedef struct
{
    uint16_t Object_addr;	//保护元件动作代码:动作值
    uint16_t Length;
    uint8_t GroupNum;
    float Value1;
    float Value2;
}__attribute__ ((packed,aligned(1))) SOE_2Value_Struct;

typedef struct
{
    uint16_t Object_addr;	//保护元件动作代码:动作值
    uint16_t Length;
    uint8_t GroupNum;
    float Value;
}__attribute__ ((packed,aligned(1))) SOE_1Value_Struct;




#endif // IEC104_H
