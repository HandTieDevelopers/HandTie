/*
  Copyright (c) 2014 MediaTek Inc.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License..

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
   See the GNU Lesser General Public License for more details.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "Wire.h"

#define DEBUG 0
#define USING_SEN10724

// Arduino backward compatibility macros
#if ARDUINO >= 100
  #define WIRE_SEND(b) Wire.write((byte) b) 
  #define WIRE_RECEIVE() Wire.read() 
#else
  #define WIRE_SEND(b) Wire.send(b)
  #define WIRE_RECEIVE() Wire.receive() 
#endif

#define numDims 3
int16_t accel[numDims] = {0};

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

//float accel_cali[numDims] = {0};

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
      Serial.write("!ERR: reading accelerometer");
    }
  }
}

//Wifi udp
#include <LWiFi.h>
#include <LWiFiUdp.h>

#define WIFI_AP "HandTieNotHentai"
#define WIFI_PASSWORD "androidiphone"
#define WIFI_AUTH LWIFI_WEP  // choose from LWIFI_OPEN, LWIFI_WPA, or LWIFI_WEP.

#define WRITE_BUFF_SIZE ((int)40)
#define ENDDING_CHAR 0
#define NEWLINE_CHAR '\n'
char buff_w[WRITE_BUFF_SIZE];

#define serverPort ((uint16_t)8080)
#define udpLocalPort ((uint16_t)1234)
IPAddress serverIP (192,168,1,2);
#define retryIntervalInMilliSec 1000

LWiFiLoginInfo APConnectingInfo(WIFI_AUTH, WIFI_PASSWORD);
// A UDP instance to let us send and receive packets over UDP
LWiFiUDP udpClient;

void connectToAP() {
  while (0 == LWiFi.connect(WIFI_AP, APConnectingInfo)) {
    Serial.println("connecting Wifi AP failed");
    delay(retryIntervalInMilliSec);
  }
}

void checkAPConnection() {
  if(LWiFi.status() == LWIFI_STATUS_DISCONNECTED) {
    udpClient.stop();
    connectToAP();
    udpClient.begin(udpLocalPort);
  }
}

//strain gauge 
#define numStrainGauges 5
#define numButtons 1

const uint16_t strainGaugePins[numStrainGauges] = {0,1,2,3,6};
const uint16_t buttonPin[numButtons] = {2};
uint16_t analogVals[numStrainGauges] = {0};

void setup() {
  
  for(int i = 0;i < numButtons;i++) {
    pinMode(buttonPin[i], INPUT);
  }

  //IMU I2C
  I2C_Init();
#ifdef USING_SEN10724
  Accel_Init();
#elif defined(USING_MPU9150) || defined(USING_MPU6050)
  Do_Calibrarion();
#endif

  Serial.begin(9600);
  Serial.println("init wifi client");
  
  LWiFi.begin();
  connectToAP();  
  
  Serial.println("Wifi AP connected successfully");
  
  udpClient.begin(udpLocalPort);
}

void transmitUDPPacket() {
  int isSuccessful = 0;
  int numBytesToTransmit = strlen(buff_w);
  udpClient.beginPacket(serverIP, serverPort);
  while(true) {
    isSuccessful = udpClient.write((const uint8_t*)buff_w, numBytesToTransmit);
    if(!isSuccessful) { //something wrong
      checkAPConnection();
    }
    else {
      break;
    }
  }
  udpClient.endPacket();
}

void loop() {
  Read_Accel();
  sprintf(buff_w,"a %d %d %d \n",accel[0],accel[1],accel[2]);
  transmitUDPPacket();
  
  char mode = 's';
  if(digitalRead(buttonPin[0]) == LOW) {  //do calibration
    mode = 'c'; 
  }

  //simulating the result of reading from arduino's serial
  
  analogVals[0] = 100;
  analogVals[1] = 133;
  analogVals[2] = 10;
  analogVals[3] = 5;
  analogVals[4] = 60;
  
  sprintf(buff_w,"%c %d %d %d %d %d \n",mode,analogVals[0],analogVals[1],analogVals[2],analogVals[3],analogVals[4]);
  transmitUDPPacket();

}
