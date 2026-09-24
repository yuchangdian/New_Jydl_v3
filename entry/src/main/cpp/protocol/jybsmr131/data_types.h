// 根据 Qt data.h 移植；字段顺序与类型保持原样。
#pragma once
#include <cstdint>

namespace jybsmr131 {

#pragma pack(push, 1)
struct RemoteSignalALL_Struct {
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
};

struct DigitalInputData_Struct {
    uint8_t GLKGW;  //DI1——(隔离开关位置)
    uint8_t JDKGW;  //DI2——(接地开关位置)
    uint8_t KHBJ;   //DI3——(控制回路报警)
    uint8_t WCN;    //DI4——(未储能位)
    uint8_t YFJD;   //DI5——(远方/就地)
    uint8_t HW;     //DI6——(合位)
    uint8_t TW;     //DI7——(分位)
    uint8_t Run;    //运行
    uint8_t Alarm;  //告警
    uint8_t SyncErr;    //同步异常
    uint8_t SwitchState;  //开关位置
};
#pragma pack(pop)
} // namespace jybsmr131
