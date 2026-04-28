#include <node_api.h>
#include "napi/native_api.h"

#include <cstdlib>
#include <cstring>

#include "setting_napi.h"
#include "telemetry_napi.h"
#include "tcp_client.h"


#include "napi/native_api.h"
#include "hilog/log.h"
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200  // 全局domain宏，标识业务领域
#define LOG_TAG "MY_TAG"   // 全局tag宏，标识模块日志tag
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/time.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/ioctl.h>






#define I2C_DEV "/dev/i2c-5"//i2c_dev为i2c　adapter创建的别名
/*These registers configure the direction of the I/O pins. 
Cx[y] = 0: The corresponding port pin is an output.
Cx[y] = 1: The corresponding port pin is an input.*/

#define REG_BANK0_DIR_ADDR 0x18
#define REG_BANK1_DIR_ADDR 0x19
#define REG_BANK2_DIR_ADDR 0x1A
#define REG_BANK3_DIR_ADDR 0x1B
#define REG_BANK4_DIR_ADDR 0x1C

//IP0 to IP4 - Input Port registers
#define REG_BANK0_INPUT_ADDR 0x00
#define REG_BANK1_INPUT_ADDR 0x01
#define REG_BANK2_INPUT_ADDR 0x02
#define REG_BANK3_INPUT_ADDR 0x03
#define REG_BANK4_INPUT_ADDR 0x04


//IP0 to IP4 - Output Port registers
#define REG_BANK0_OUTPUT_ADDR 0x08
#define REG_BANK1_OUTPUT_ADDR 0x09
#define REG_BANK2_OUTPUT_ADDR 0x0A
#define REG_BANK3_OUTPUT_ADDR 0x0B
#define REG_BANK4_OUTPUT_ADDR 0x0C

/* CONFIG 寄存器位定义 */
/* 位15: 操作状态/单次转换启动 */
#define CONFIG_OS_Pos      15
#define CONFIG_OS_Msk      (1UL << CONFIG_OS_Pos)
#define CONFIG_OS_RW_Msk   ~(1UL << CONFIG_OS_Pos)  /* R/W访问 */

/* OS位值定义 */
#define CONFIG_OS_WRITE_START_CONV  1  /* 写入1:启动单次转换(断电模式下) */
#define CONFIG_OS_WRITE_NOP         0  /* 写入0:无效 */
#define CONFIG_OS_READ_BUSY         0  /* 读取0:芯片正在执行转换 */
#define CONFIG_OS_READ_IDLE         1  /* 读取1:芯片未执行转换 */

/* 位14-12: 输入多路选择器配置 */
#define CONFIG_MUX_Pos     12
#define CONFIG_MUX_Msk     (0x7UL << CONFIG_MUX_Pos)
#define CONFIG_MUX_RW_Msk  ~(0x7UL << CONFIG_MUX_Pos)



#define I2C_CHIP0_ADDRESS 0x22
#define I2C_CHIP1_ADDRESS 0x25

/* MUX[2:0]配置值 */
typedef enum {
    CONFIG_MUX_AIN0_AIN1 = 0x0,  /* AINP=AIN0, AINN=AIN1 (默认) */
    CONFIG_MUX_AIN0_AIN3 = 0x1,  /* AINP=AIN0, AINN=AIN3 */
    CONFIG_MUX_AIN1_AIN3 = 0x2,  /* AINP=AIN1, AINN=AIN3 */
    CONFIG_MUX_AIN2_AIN3 = 0x3,  /* AINP=AIN2, AINN=AIN3 */
    CONFIG_MUX_AIN0_GND  = 0x4,  /* AINP=AIN0, AINN=GND */
    CONFIG_MUX_AIN1_GND  = 0x5,  /* AINP=AIN1, AINN=GND */
    CONFIG_MUX_AIN2_GND  = 0x6,  /* AINP=AIN2, AINN=GND */
    CONFIG_MUX_AIN3_GND  = 0x7,  /* AINP=AIN3, AINN=GND */
} CONFIG_MUX_Config;

/* 位11-9: 可编程增益放大器配置 */
#define CONFIG_PGA_Pos     9
#define CONFIG_PGA_Msk     (0x7UL << CONFIG_PGA_Pos)
#define CONFIG_PGA_RW_Msk  (0x7UL << CONFIG_PGA_Pos)

/* PGA[2:0]配置值 */
typedef enum {
    CONFIG_PGA_FSR_6_144V = 0x0,  /* FSR=±6.144V */
    CONFIG_PGA_FSR_4_096V = 0x1,  /* FSR=±4.096V */
    CONFIG_PGA_FSR_2_048V = 0x2,  /* FSR=±2.048V (默认) */
    CONFIG_PGA_FSR_1_024V = 0x3,  /* FSR=±1.024V */
    CONFIG_PGA_FSR_0_512V = 0x4,  /* FSR=±0.512V */
    CONFIG_PGA_FSR_0_256V = 0x5,  /* FSR=±0.256V */
    CONFIG_PGA_FSR_0_256V_ALT1 = 0x6, /* FSR=±0.256V */
    CONFIG_PGA_FSR_0_256V_ALT2 = 0x7, /* FSR=±0.256V */
} CONFIG_PGA_Config;

/* 位8: 芯片运行模式 */
#define CONFIG_MODE_Pos     8
#define CONFIG_MODE_Msk     (1UL << CONFIG_MODE_Pos)
#define CONFIG_MODE_RW_Msk  (1UL << CONFIG_MODE_Pos)

/* MODE位值定义 */
#define CONFIG_MODE_CONTINUOUS  0  /* 连续转换模式 */
#define CONFIG_MODE_SINGLE_PWD  1  /* 单次转换模式或断电模式 (默认) */

/* CONFIG寄存器复位值 */
#define CONFIG_REG_RESET_VALUE  \
    ((CONFIG_OS_READ_IDLE << CONFIG_OS_Pos) |          \
     (CONFIG_MUX_AIN0_AIN1 << CONFIG_MUX_Pos) |        \
     (CONFIG_PGA_FSR_2_048V << CONFIG_PGA_Pos) |       \
     (CONFIG_MODE_SINGLE_PWD << CONFIG_MODE_Pos))

	 /* 第二个寄存器位定义 */
/* 位7-5: 数据速率配置 */
#define REG_DR_Pos         5
#define REG_DR_Msk         (0x7UL << REG_DR_Pos)
#define REG_DR_RW_Msk      (0x7UL << REG_DR_Pos)

/* DR[2:0]配置值 */
typedef enum {
    REG_DR_6_25_SPS  = 0x0,  /* 6.25 SPS */
    REG_DR_12_5_SPS  = 0x1,  /* 12.5 SPS */
    REG_DR_25_SPS    = 0x2,  /* 25 SPS */
    REG_DR_50_SPS    = 0x3,  /* 50 SPS */
    REG_DR_100_SPS   = 0x4,  /* 100 SPS (默认) */
    REG_DR_400_SPS   = 0x5,  /* 400 SPS */
    REG_DR_1000_SPS  = 0x6,  /* 1000 SPS */
    REG_DR_2000_SPS  = 0x7,  /* 2000 SPS */
} REG_DR_Config;

/* 位4: 比较器模式 */
#define REG_COMP_MODE_Pos     4
#define REG_COMP_MODE_Msk     (1UL << REG_COMP_MODE_Pos)
#define REG_COMP_MODE_RW_Msk  (1UL << REG_COMP_MODE_Pos)

/* COMP_MODE位值定义 */
#define REG_COMP_MODE_TRADITIONAL  0  /* 常规比较器 (默认) */
#define REG_COMP_MODE_WINDOW       1  /* 窗口比较器 */

/* 位3: 比较器极性 */
#define REG_COMP_POL_Pos     3
#define REG_COMP_POL_Msk     (1UL << REG_COMP_POL_Pos)
#define REG_COMP_POL_RW_Msk  (1UL << REG_COMP_POL_Pos)

/* COMP_POL位值定义 */
#define REG_COMP_POL_LOW_ACTIVE  0  /* 低电平响应 (默认) */
#define REG_COMP_POL_HIGH_ACTIVE 1  /* 高电平响应 */

/* 位2: 比较器输出锁存配置 */
#define REG_COMP_LAT_Pos     2
#define REG_COMP_LAT_Msk     (1UL << REG_COMP_LAT_Pos)
#define REG_COMP_LAT_RW_Msk  (1UL << REG_COMP_LAT_Pos)

/* COMP_LAT位值定义 */
#define REG_COMP_LAT_NON_LATCHING  0  /* 不锁存 (默认) */
#define REG_COMP_LAT_LATCHING      1  /* 锁存 */

/* 位1-0: 比较器队列和禁用控制 */
#define REG_COMP_QUE_Pos     0
#define REG_COMP_QUE_Msk     (0x3UL << REG_COMP_QUE_Pos)
#define REG_COMP_QUE_RW_Msk  (0x3UL << REG_COMP_QUE_Pos)

/* COMP_QUE[1:0]配置值 */
typedef enum {
    REG_COMP_QUE_1_CONV = 0x0,  /* 一次转换后置位 */
    REG_COMP_QUE_2_CONV = 0x1,  /* 两次转换后置位 */
    REG_COMP_QUE_4_CONV = 0x2,  /* 四次转换后置位 */
    REG_COMP_QUE_DISABLE = 0x3, /* 禁用比较器,ALERT/RDY高阻 (默认) */
} REG_COMP_QUE_Config;


int I2c_read_new(char regaddr, char *value,int count);
int fd;
unsigned char val[100];
void mydelay(int s,int us)
{
	struct timeval tv;
	tv.tv_sec = s;
	tv.tv_usec = us;
	//只用来延时，不检测读写
	select(0,NULL,NULL,NULL,&tv);
}

//读操作先发Slaveaddr_W+Regaddr_H+Regaddr_L 3个字节来告诉设备操作器件及两个byte参数
//然后发送Slaveaddr_R读数据

static int iic_read_new(int fd, char buff[], char addr, int count)
{
    int res;
    write(fd, &addr, 1);
    res = read(fd, buff, count);
   // printf("read %d byte at 0x%x\n", res, addr);
    return res;
}
//在写之前，在数据前加两个byte的参数，根据需要解析
static int iic_write_new(int fd, char buff[], char addr, int count)
{
    int res;
    int i, n;
    static char sendbuffer[100];
    memcpy(sendbuffer + 1, buff, count);
    sendbuffer[0] = addr;
    res = write(fd, sendbuffer, count + 1);
	return res;
    //printf("write %d byte at 0x%x/n", res, addr);
}

int I2c_write_new(char slaveaddr,char regaddr, char value)
{
    int res;
    //char slaveaddr;
    fd = open(I2C_DEV, O_RDWR); // I2C_DEV /dev/i2c-0
    if (fd < 0)
    {
		OH_LOG_ERROR(LOG_APP, "open");
		return fd;
    }
    //regaddr = 0x01;
    res = ioctl(fd, I2C_SLAVE, slaveaddr);    //设置I2C从设备地址[6:0]
	if (res < 0)
    {
		OH_LOG_ERROR(LOG_APP, "ioctl");

    }
    res =  iic_write_new(fd, &value, regaddr, 1);
	if (res < 0)
    {
		OH_LOG_ERROR(LOG_APP, "iic_write_new");

    }
    close(fd);
		return res;
}
int I2c_read_new(char slaveaddr,char regaddr, char *value,int count)
{
    int res;
    //char slaveaddr;
    fd = open(I2C_DEV, O_RDWR); // I2C_DEV /dev/i2c-0
    if (fd < 0)
    {
		printf("####i2c test device open failed####/n");
		return fd;
    }
    //regaddr = 0x01;
    res = ioctl(fd, I2C_SLAVE, slaveaddr);    //设置I2C从设备地址[6:0]
	if (res < 0)
    {
		perror("####i2c test device I2C_SLAVE failed####");

    }
	res =  iic_read_new(fd, value, regaddr, count);
	if (res < 0)
    {
		perror("####iic_read_new failed####");

    }
    close(fd);
	return res;
}
/**
 * @brief 设置指定I2C设备上指定GPIO引脚的方向（输入或输出）
 * 
 * @param slaveaddr I2C从设备地址（7位地址）
 * @param pin 引脚编号，范围 0 ~ 39，对应 PCA9698 的 40 个 GPIO。
 *            引脚分布: 0-7: Port0; 8-15: Port1; 16-23: Port2; 24-31: Port3; 32-39: Port4。
 * @param direction 引脚方向。0: 输出 (Output); 1: 输入 (Input)。
 * @return int 成功返回0，失败返回-1。
 */
int set_pin_direction(char slaveaddr, int pin, int direction) {
    uint8_t reg_val;
    uint8_t bank;
    uint8_t bit_mask;
    
    // 参数检查
    if (pin < 0 || pin > 39) {
        printf("Error: Pin number %d out of range (0~39).\n", pin);
        return -1;
    }
    
    // 计算引脚所属的端口(Bank)和在端口内的位掩码
    bank = pin / 8; // 确定是哪个端口 (0~4)
    bit_mask = 1 << (pin % 8); // 计算在端口寄存器中对应的位
    
    // 读取当前端口的方向寄存器值
    if (I2c_read_new(slaveaddr, REG_BANK0_DIR_ADDR + bank, (char *)&reg_val, 1) < 0) {
        perror("Failed to read direction register");
        return -1;
    }
    
    // 根据参数设置或清除对应的方向位
    if (direction) {
        reg_val |= bit_mask;  // 设置为1，表示输入
    } else {
        reg_val &= ~bit_mask; // 设置为0，表示输出
    }
    
    // 将新的方向配置写回寄存器
    if (I2c_write_new(slaveaddr, REG_BANK0_DIR_ADDR + bank, reg_val) < 0) {
        perror("Failed to write direction register");
        return -1;
    }
    
    return 0;
}

/**
 * @brief 设置指定I2C设备上指定GPIO引脚的输出电平（仅当引脚方向为输出时有效）
 * 
 * @param slaveaddr I2C从设备地址（7位地址）
 * @param pin 引脚编号，范围 0 ~ 39。
 * @param level 输出电平。0: 低电平; 1: 高电平。
 * @return int 成功返回0，失败返回-1。
 */
int set_pin_output_level(char slaveaddr, int pin, int level) {
    uint8_t reg_val;
    uint8_t bank;
    uint8_t bit_mask;
    
    // 参数检查
    if (pin < 0 || pin > 39) {
        printf("Error: Pin number %d out of range (0~39).\n", pin);
        return -1;
    }
    
    // 计算引脚所属的端口(Bank)和在端口内的位掩码
    bank = pin / 8;
    bit_mask = 1 << (pin % 8);
    
    // 读取当前端口的输出寄存器值
    if (I2c_read_new(slaveaddr, REG_BANK0_OUTPUT_ADDR + bank, (char *)&reg_val, 1) < 0) {
        perror("Failed to read output register");
        return -1;
    }
    
    // 根据参数设置或清除对应的输出位
    if (level) {
        reg_val |= bit_mask;  // 设置为1，输出高电平
    } else {
        reg_val &= ~bit_mask; // 设置为0，输出低电平
    }
    
    // 将新的输出电平配置写回寄存器
    if (I2c_write_new(slaveaddr, REG_BANK0_OUTPUT_ADDR + bank, reg_val) < 0) {
        perror("Failed to write output register");
        return -1;
    }
    
    return 0;
}

/**
 * @brief 读取指定I2C设备上指定GPIO引脚的输入电平（仅当引脚方向为输入时有效）
 * 
 * @param slaveaddr I2C从设备地址（7位地址）
 * @param pin 引脚编号，范围 0 ~ 39。
 * @param p_level 用于存储读取到的电平值的指针。0: 低电平; 1: 高电平。
 * @return int 成功返回0，失败返回-1。
 */
int get_pin_input_level(char slaveaddr, int pin, uint8_t *p_level) {
    uint8_t reg_val;
    uint8_t bank;
    uint8_t bit_mask;
    
    if (pin < 0 || pin > 39) {
        printf("Error: Pin number %d out of range (0~39).\n", pin);
        return -1;
    }
    
    bank = pin / 8;
    bit_mask = 1 << (pin % 8);
    
    // 读取指定端口的输入寄存器值
    if (I2c_read_new(slaveaddr, REG_BANK0_INPUT_ADDR + bank, (char *)&reg_val, 1) < 0) {
        perror("Failed to read input register");
        return -1;
    }
    
    // 提取对应引脚的电平状态
    *p_level = (reg_val & bit_mask) ? 1 : 0;
    
    return 0;
}


uint16_t read_data = 0;
static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);
    
    I2c_write_new(I2C_CHIP0_ADDRESS,REG_BANK0_DIR_ADDR, 0x00);//dir port0
    I2c_write_new(I2C_CHIP0_ADDRESS,REG_BANK1_DIR_ADDR, 0x00);//dir port1
    I2c_write_new(I2C_CHIP0_ADDRESS,REG_BANK2_DIR_ADDR, 0x00);//dir port2
    I2c_write_new(I2C_CHIP0_ADDRESS,REG_BANK3_DIR_ADDR, 0x00);//dir port3
    I2c_write_new(I2C_CHIP0_ADDRESS,REG_BANK4_DIR_ADDR, 0x00);//dir port4	

	 for(int i = 0;i<40;i++)
	 {
	 	set_pin_direction(I2C_CHIP0_ADDRESS,i, 0);      // 方向: 0=输出
	 	set_pin_output_level(I2C_CHIP0_ADDRESS,i, 1);   // 电平: 1=高	
	 	usleep(20);
	 }

    int i = 17;
    set_pin_direction(I2C_CHIP0_ADDRESS,i, 0);      // 方向: 0=输出
    set_pin_output_level(I2C_CHIP0_ADDRESS,i, 0);   // 电平: 1=高	
    //set_gpio_value(109,1,1);//warming

    //usleep(20000);
    OH_LOG_INFO(LOG_APP, "conv 0x%{public}x\n",read_data);
    OH_LOG_INFO(LOG_APP, "config 0x%{public}x\n",read_data);
    OH_LOG_INFO(LOG_APP, "hello world");

    return sum;
}

static napi_value CreateBoolean(napi_env env, bool value)
{
    napi_value result = nullptr;
    napi_get_boolean(env, value, &result);
    return result;
}

static napi_value CreateUndefined(napi_env env)
{
    napi_value result = nullptr;
    napi_get_undefined(env, &result);
    return result;
}

static bool GetRequiredString(napi_env env, napi_value value, char **result)
{
    size_t valueLength = 0;
    if (napi_get_value_string_utf8(env, value, nullptr, 0, &valueLength) != napi_ok) {
        napi_throw_type_error(env, nullptr, "host must be a string");
        return false;
    }

    char *buffer = static_cast<char *>(std::malloc(valueLength + 1));
    if (buffer == nullptr) {
        napi_throw_error(env, nullptr, "failed to allocate host buffer");
        return false;
    }

    if (napi_get_value_string_utf8(env, value, buffer, valueLength + 1, &valueLength) != napi_ok) {
        std::free(buffer);
        napi_throw_type_error(env, nullptr, "failed to read host");
        return false;
    }

    *result = buffer;
    return true;
}

static bool GetRequiredPort(napi_env env, napi_value value, int32_t *port)
{
    if (napi_get_value_int32(env, value, port) != napi_ok) {
        napi_throw_type_error(env, nullptr, "port must be an integer");
        return false;
    }

    if (*port <= 0 || *port > 65535) {
        napi_throw_range_error(env, nullptr, "port must be between 1 and 65535");
        return false;
    }
    return true;
}

static napi_value StartTcpClient(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 2) {
        napi_throw_type_error(env, nullptr, "startTcpClient requires host and port");
        return nullptr;
    }

    char *host = nullptr;
    int32_t port = 0;
    if (!GetRequiredString(env, args[0], &host) || !GetRequiredPort(env, args[1], &port)) {
        std::free(host);
        return nullptr;
    }

    bool started = TcpClient::GetInstance().Start(host, port) == 1;
    std::free(host);
    return CreateBoolean(env, started);
}

static napi_value StopTcpClient(napi_env env, napi_callback_info info)
{
    (void)info;
    TcpClient::GetInstance().Stop();
    return CreateUndefined(env);
}

static napi_value IsTcpClientRunning(napi_env env, napi_callback_info info)
{
    (void)info;
    return CreateBoolean(env, TcpClient::GetInstance().IsRunning() == 1);
}

// SendTcpData 是 ArkTS 到 native 发送链路的入口封装。
// 它负责把 ArkTS 字符串取出来，再转交给 tcp_client_send 执行真正的 socket 发送。
static napi_value SendTcpData(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "sendTcpData requires a string argument");
        return nullptr;
    }

    char *data = nullptr;
    if (!GetRequiredString(env, args[0], &data)) {
        return nullptr;
    }

    size_t length = std::strlen(data);
    bool sent = TcpClient::GetInstance().Send(data, static_cast<int>(length)) == 1;
    std::free(data);

    return CreateBoolean(env, sent);
}


EXTERN_C_START
// Init 是 native 模块导出表初始化函数。
// 当 libentry.so 被加载后，ArkTS 侧能调用到哪些原生函数，都在这里挂到 exports 上。
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"startTcpClient", nullptr, StartTcpClient, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stopTcpClient", nullptr, StopTcpClient, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"isTcpClientRunning", nullptr, IsTcpClientRunning, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBaseFreqDisplayData", nullptr, GetBaseFreqDisplayData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"requestHarmonicDisplayData", nullptr, RequestHarmonicDisplayData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getHarmonicVoltageDisplayData", nullptr, GetHarmonicVoltageDisplayData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getHarmonicCurrentDisplayData", nullptr, GetHarmonicCurrentDisplayData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPrimarySystemSetting", nullptr, GetPrimarySystemSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updatePrimarySystemSetting", nullptr, UpdatePrimarySystemSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAnalogQuantitySetting", nullptr, GetAnalogQuantitySetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateAnalogQuantitySetting", nullptr, UpdateAnalogQuantitySetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTeleMeasuringSetting", nullptr, GetTeleMeasuringSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateTeleMeasuringSetting", nullptr, UpdateTeleMeasuringSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTeleSignalingSetting", nullptr, GetTeleSignalingSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateTeleSignalingSetting", nullptr, UpdateTeleSignalingSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTeleControllingSetting", nullptr, GetTeleControllingSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateTeleControllingSetting", nullptr, UpdateTeleControllingSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getExceedingLimitSetting", nullptr, GetExceedingLimitSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateExceedingLimitSetting", nullptr, UpdateExceedingLimitSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPowerQualitySetting", nullptr, GetPowerQualitySetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updatePowerQualitySetting", nullptr, UpdatePowerQualitySetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStatisticsSetting", nullptr, GetStatisticsSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateStatisticsSetting", nullptr, UpdateStatisticsSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRelaySettingByZone", nullptr, GetRelaySettingByZone, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"requestRelaySettingByZone", nullptr, RequestRelaySettingByZone, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateRelaySettingByZone", nullptr, UpdateRelaySettingByZone, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendTcpData", nullptr, SendTcpData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr}
        
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = nullptr,
    .reserved = {0},
};

// RegisterEntryModule 是 native 动态库的注册入口。
// so 被装载时，系统会先执行这个 constructor，把上面的 Init 注册给 NAPI 运行时。
extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
