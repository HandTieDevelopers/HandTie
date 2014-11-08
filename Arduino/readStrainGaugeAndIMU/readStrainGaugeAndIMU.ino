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
int16_t accel[numDims] = {0};

const uint32_t baud_rate = 57600;
char commBuff[100];

#ifdef USING_SEN10724

// Sensor I2C addresses
#define ACCEL_ADDRESS 0x53 // 0x53 = 0xA6 / 2
#define ACCEL_REG_START_ADDRESS 0x32

void Accel_Init()
{
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
}

#elif defined(USING_MPU9150) || defined(USING_MPU6050)

#define ACCEL_ADDRESS 0x68
#define ACCEL_REG_START_ADDRESS 0x3B

#include "gyro_accel.h"
// Defining constants
#define dt 20                       // time difference in milli seconds
#define rad2degree 57.3              // Radian to degree conversion
#define Filter_gain 0.95             // e.g.  angle = angle_gyro*Filter_gain + angle_accel*(1-Filter_gain)
// *********************************************************************
//    Global Variables
// *********************************************************************
unsigned long t=0; // Time Variables
//float angle_x_gyro=0,angle_y_gyro=0,angle_z_gyro=0,angle_x_accel=0,angle_y_accel=0,angle_z_accel=0,angle_x=0,angle_y=0,angle_z=0;

void Do_Calibrarion() {
  MPU6050_ResetWake();
  MPU6050_SetGains(0,1);// Setting the lows scale
  MPU6050_SetDLPF(0); // Setting the DLPF to inf Bandwidth for calibration
  MPU6050_OffsetCal();
  MPU6050_SetDLPF(6); // Setting the DLPF to lowest Bandwidth
}

float accel_cali[numDims] = {0};

#endif

void I2C_Init()
{
  Wire.begin();
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
    accel[0] = (buff[3] << 8) | buff[2];  // X axis (internal sensor y axis)
    accel[1] = (buff[1] << 8) | buff[0];  // Y axis (internal sensor x axis)
    accel[2] = (buff[5] << 8) | buff[4];  // Z axis (internal sensor z axis)
    #elif defined(USING_MPU9150) || defined(USING_MPU6050)
    accel[0] = (buff[0] << 8) | buff[1];
    accel[1] = (buff[2] << 8) | buff[3];
    accel[2] = (buff[4] << 8) | buff[5];

    accel[0] = (float)(accel[0]-accel_x_OC)*accel_scale_fact/10; //100 * m/s^2 and truncated into integer
    accel[1] = (float)(accel[1]-accel_y_OC)*accel_scale_fact/10;
    accel[2] = (float)(accel[2]-accel_z_OC)*accel_scale_fact/10;
  
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
#ifdef USING_SEN10724
	Accel_Init();
#elif defined(USING_MPU9150) || defined(USING_MPU6050)
  Do_Calibrarion();
#endif

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
