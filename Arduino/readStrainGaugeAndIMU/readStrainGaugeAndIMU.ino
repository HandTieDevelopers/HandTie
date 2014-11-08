#include <stdio.h>
#include <stdlib.h>
#include "Wire.h"

#define DEBUG 0
#define USING_MPU9150

// Arduino backward compatibility macros
#if ARDUINO >= 100
  #define WIRE_SEND(b) Wire.write((byte) b) 
  #define WIRE_RECEIVE() Wire.read() 
#else
  #define WIRE_SEND(b) Wire.send(b)
  #define WIRE_RECEIVE() Wire.receive() 
#endif

//strain gauge 
const uint16_t numStrainGauges = 5;
const uint16_t numButtons = 1;
//due to nano occupying A4 and A5 for I2C communication,we change strain gauge to A6
const uint16_t strainGaugePins[numStrainGauges] = {0,1,2,3,6};
const uint16_t buttonPin[numButtons] = {2};
uint16_t analogVals[numStrainGauges] = {0};

#define numDims 3
uint16_t accel[numDims] = {0};

const uint32_t baud_rate = 57600;
char commBuff[100];

#ifdef USING_SEN10724

// Sensor I2C addresses
#define ACCEL_ADDRESS 0x53 // 0x53 = 0xA6 / 2
#define ACCEL_REG_START_ADDRESS 0x32

#elif defined(USING_MPU9150) || defined(USING_MPU6050)

#define ACCEL_ADDRESS 0x68
#define ACCEL_REG_START_ADDRESS 0x3B
#define MPU6050_RA_PWR_MGMT_1 0x6B
#define MPU6050_PWR1_SLEEP_BIT 6
#define MPU6050_PWR1_CLKSEL_BIT 2
#define MPU6050_RA_GYRO_CONFIG 0x1B
#define MPU6050_GCONFIG_FS_SEL_BIT 4
#define MPU6050_GCONFIG_FS_SEL_LENGTH 2
#define MPU6050_RA_ACCEL_CONFIG 0x1C
#define MPU6050_ACONFIG_AFS_SEL_BIT 4
#define MPU6050_ACONFIG_AFS_SEL_LENGTH 2

//accel range
#define MPU6050_ACCEL_FS_2          0x00
#define MPU6050_ACCEL_FS_4          0x01
#define MPU6050_ACCEL_FS_8          0x02
#define MPU6050_ACCEL_FS_16         0x03

//gyro range
#define MPU6050_GYRO_FS_250         0x00
#define MPU6050_GYRO_FS_500         0x01
#define MPU6050_GYRO_FS_1000        0x02
#define MPU6050_GYRO_FS_2000        0x03

//clock source
#define MPU6050_CLOCK_INTERNAL          0x00
#define MPU6050_CLOCK_PLL_XGYRO         0x01
#define MPU6050_CLOCK_PLL_YGYRO         0x02
#define MPU6050_CLOCK_PLL_ZGYRO         0x03
#define MPU6050_CLOCK_PLL_EXT32K        0x04
#define MPU6050_CLOCK_PLL_EXT19M        0x05
#define MPU6050_CLOCK_KEEP_RESET        0x07

#define MPU6050_PWR1_DEVICE_RESET_BIT   7
#define MPU6050_PWR1_SLEEP_BIT          6
#define MPU6050_PWR1_CYCLE_BIT          5
#define MPU6050_PWR1_TEMP_DIS_BIT       3
#define MPU6050_PWR1_CLKSEL_BIT         2
#define MPU6050_PWR1_CLKSEL_LENGTH      3

#define BUFFER_LENGTH 32

int8_t readBytes(uint8_t devAddr, uint8_t regAddr, uint8_t length, uint8_t *data, uint16_t timeout) {
    int8_t count = 0;
    uint32_t t1 = millis();

    // Arduino v1.0.0, Wire library
    // Adds standardized write() and read() stream methods instead of send() and receive()

    // I2C/TWI subsystem uses internal buffer that breaks with large data requests
    // so if user requests more than BUFFER_LENGTH bytes, we have to do it in
    // smaller chunks instead of all at once
    for (uint8_t k = 0; k < length; k += min(length, BUFFER_LENGTH)) {
        Wire.beginTransmission(devAddr);
        WIRE_SEND(regAddr);
        Wire.endTransmission();
        Wire.beginTransmission(devAddr);
        Wire.requestFrom(devAddr, (uint8_t)min(length - k, BUFFER_LENGTH));

        for (; Wire.available() && (timeout == 0 || millis() - t1 < timeout); count++) {
            data[count] = WIRE_RECEIVE();
        }

        Wire.endTransmission();
    }
        
    // check for timeout
    if (timeout > 0 && millis() - t1 >= timeout && count < length) count = -1; // timeout

    return count;
}

int writeBytes(uint8_t devAddr, uint8_t regAddr, uint8_t length, uint8_t* data) {
    
    Wire.beginTransmission(devAddr);
    WIRE_SEND((uint8_t) regAddr); // send address
    
    for (uint8_t i = 0; i < length; i++) {
      WIRE_SEND((uint8_t) data[i]);  
    }
    Wire.endTransmission();
    
    return 1;
}

int writeBit(uint8_t devAddr, uint8_t regAddr, uint8_t bitNum, uint8_t data) {
    uint8_t b;
    readBytes(devAddr, regAddr, 1, &b, 0);
    b = (data != 0) ? (b | (1 << bitNum)) : (b & ~(1 << bitNum));
    return writeBytes(devAddr, regAddr, 1, &b);
}

int writeBits(uint8_t devAddr, uint8_t regAddr, uint8_t bitStart, uint8_t length, uint8_t data) {
    //      010 value to write
    // 76543210 bit numbers
    //    xxx   args: bitStart=4, length=3
    // 00011100 mask byte
    // 10101111 original value (sample)
    // 10100011 original & ~mask
    // 10101011 masked | value
    uint8_t b;
    if (readBytes(devAddr, regAddr, 1, &b, 0) != 0) {
        uint8_t mask = ((1 << length) - 1) << (bitStart - length + 1);
        data <<= (bitStart - length + 1); // shift data into correct position
        data &= mask; // zero all non-important bits in data
        b &= ~(mask); // zero all important bits in existing byte
        b |= data; // combine data with existing byte
        return writeBytes(devAddr, regAddr, 1, &b);
    } else {
        return 0;
    }
}

#endif

void I2C_Init()
{
  Wire.begin();
}

void Accel_Init()
{
#ifdef USING_SEN10724

  Wire.beginTransmission(ACCEL_ADDRESS);
  WIRE_SEND(0x2D);  // Power register
  WIRE_SEND(0x08);  // Measurement mode
  Wire.endTransmission();
  delay(5);
  Wire.beginTransmission(ACCEL_ADDRESS);
  WIRE_SEND(0x31);  // Data format register
  WIRE_SEND(0x08);  // Set to full resolution
  Wire.endTransmission();
  delay(5);
  
  // Because our main loop runs at 50Hz we adjust the output data rate to 50Hz (25Hz bandwidth)
  Wire.beginTransmission(ACCEL_ADDRESS);
  WIRE_SEND(0x2C);  // Rate
  WIRE_SEND(0x09);  // Set to 50Hz, normal operation
  Wire.endTransmission();
  delay(5);

#elif defined(USING_MPU9150) || defined(USING_MPU6050)

  //setClockSource(MPU6050_CLOCK_PLL_XGYRO);
  writeBits(ACCEL_ADDRESS, MPU6050_RA_PWR_MGMT_1, MPU6050_PWR1_CLKSEL_BIT, MPU6050_PWR1_CLKSEL_LENGTH, MPU6050_CLOCK_PLL_XGYRO);
  //setFullScaleGyroRange(MPU6050_GYRO_FS_250);
  writeBits(ACCEL_ADDRESS, MPU6050_RA_GYRO_CONFIG, MPU6050_GCONFIG_FS_SEL_BIT, MPU6050_GCONFIG_FS_SEL_LENGTH, MPU6050_GYRO_FS_250);
  //setFullScaleAccelRange(MPU6050_ACCEL_FS_2);
  writeBits(ACCEL_ADDRESS, MPU6050_RA_ACCEL_CONFIG, MPU6050_ACONFIG_AFS_SEL_BIT, MPU6050_ACONFIG_AFS_SEL_LENGTH, MPU6050_ACCEL_FS_2);
  //setSleepEnabled(false);
  writeBit(ACCEL_ADDRESS, MPU6050_RA_PWR_MGMT_1, MPU6050_PWR1_SLEEP_BIT, false);

#endif

}

// Reads x, y and z accelerometer registers
void Read_Accel()
{
  
  byte buff[6];

  Wire.beginTransmission(ACCEL_ADDRESS); 
  WIRE_SEND(ACCEL_REG_START_ADDRESS);  // Send address to read from
  Wire.endTransmission();
  
  Wire.beginTransmission(ACCEL_ADDRESS);
  Wire.requestFrom(ACCEL_ADDRESS, 6);  // Request 6 bytes
  int i = 0;
  while(Wire.available())  // ((Wire.available())&&(i<6))
  { 
    buff[i] = WIRE_RECEIVE();  // Read one byte
    i++;
  }
  Wire.endTransmission();
  
  if (i == 6)  // All bytes received?
  {
    // No multiply by -1 for coordinate system transformation here, because of double negation:
    // We want the gravity vector, which is negated acceleration vector.
    #ifdef USING_SEN10724
    accel[0] = (((int16_t) buff[3]) << 8) | buff[2];  // X axis (internal sensor y axis)
    accel[1] = (((int16_t) buff[1]) << 8) | buff[0];  // Y axis (internal sensor x axis)
    accel[2] = (((int16_t) buff[5]) << 8) | buff[4];  // Z axis (internal sensor z axis)
    #elif defined(USING_MPU9150) || defined(USING_MPU6050)
    accel[0] = (((int16_t) buff[0]) << 8) | buff[1];
    accel[1] = (((int16_t) buff[2]) << 8) | buff[3];
    accel[2] = (((int16_t) buff[4]) << 8) | buff[5];
    #endif
  }
  else
  {
    if(DEBUG) {
      Serial.println("!ERR: reading accelerometer");
    }
  }
}

void setup() {
	Serial.begin(baud_rate);
	for(int i = 0;i < numButtons;i++) {
		pinMode(buttonPin[i], INPUT);
	}
	
	I2C_Init();
	Accel_Init();
}

void loop() {
	
	//Reading Values
	for(int i = 0;i < numStrainGauges;i++) {
		analogVals[i] = analogRead(strainGaugePins[i]);
	}
	Read_Accel();
	sprintf(commBuff," %d %d %d %d %d %d %d %d ",analogVals[0],analogVals[1],analogVals[2],analogVals[3],analogVals[4],accel[0],accel[1],accel[2]);
	
	if(digitalRead(buttonPin[0]) == LOW) {	//do calibration
		Serial.print("c");
	}
	else {
		Serial.print("n");
	}
	Serial.println(commBuff);
	
}
