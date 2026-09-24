// 根据 Qt SystemSetting_JYBSMR131.h 移植；字段顺序与类型保持原样。
#pragma once
#include <cstdint>
#include "setting.h"
namespace jybsmr131 {

#pragma pack(push, 1)
struct SystemSettingWithoutRatedCurrent {
    uint32_t SystemGroundingMode;	// 系统中性点接地方式：(1)——小电阻接地方式
    //										 (2)——消弧线圈接地方式
    //									   (3)——小电阻并消弧线圈接地方式
    float PTp_Primary;		// 母线相PT一次额定值：***.*kV
    float PTp_Secondary;	// 母线相PT二次额定值：****V
    float PTo_Primary;		// 母线零序PT一次额定值：***.*kV
    float PTo_Secondary;	// 母线零序PT二次额定值：****V
    float CTp_Primary;		// 保护CT一次额定值：****A
    float CTp_Secondary;	// 保护CT二次额定值：****A
    float CTo_Primary;		// 零序CT一次额定值：****A
    float CTo_Secondary;	// 零序CT二次额定值：****A
    uint32_t	CRC;	//校验码
};
#pragma pack(pop)
} // namespace jybsmr131
