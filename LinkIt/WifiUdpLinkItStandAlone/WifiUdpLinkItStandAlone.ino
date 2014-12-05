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

//tuning parameters
#define numSamplesForVarianceTest 10
#define thresholdForStateTransition 20
#define numGaugesForStateTransition 2


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
IPAddress serverIP (192,168,1,5);
#define retryIntervalInMilliSec 1000

LWiFiLoginInfo APConnectingInfo(WIFI_AUTH, WIFI_PASSWORD);
// A UDP instance to let us send and receive packets over UDP
LWiFiUDP udpClient;

void connectToAP() {
  while (0 == LWiFi.connect(WIFI_AP, APConnectingInfo)) {
    //Serial.println("connecting Wifi AP failed");
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

//strain gauge 
#define NUM_OF_GAUGE 5
#define numButtons 1
#define NUM_OF_MULT_PINS 3

#define GAUGE_PIN A0
#define MULT_MIN_PIN 4
const uint16_t buttonPin[numButtons] = {2};
uint16_t analogVals[NUM_OF_GAUGE] = {0};

uint16_t numAnalogValsAccumulated = 0;
uint32_t analogValsSum[NUM_OF_GAUGE] = {0};
uint32_t analogValsSquareSum[NUM_OF_GAUGE] = {0};


bool varianceExceedThreshold(uint16_t threshold, uint8_t numValsToTriger) {
  float numAnalogValsAccumulatedInFloat = numAnalogValsAccumulated;
  numAnalogValsAccumulated = 0; //init

  for(int i = 0;i < NUM_OF_GAUGE;i++) {
    float analogValsAvg = analogValsSum[i]/numAnalogValsAccumulatedInFloat;
    float variance = analogValsSquareSum[i]/numAnalogValsAccumulatedInFloat - analogValsAvg * analogValsAvg; //E[x^2] - E[x]^2
    
    //for tuning parameters
    Serial.print(i);
    Serial.print(":");
    Serial.println(variance);
    
    //init variables
    analogValsSum[i] = 0;
    analogValsSquareSum[i] = 0;   

    if(variance > threshold) {
      numValsToTriger--;
      if(numValsToTriger <= 0) {
        return true;
      }
    }
  }
  
  return false;
}


void updateVarianceUsingAnalogVals() {
  for(int i = 0;i < NUM_OF_GAUGE;i++) {
    analogValsSum[i] += analogVals[i];  
    analogValsSquareSum[i] += analogVals[i]*analogVals[i];
  }
  numAnalogValsAccumulated++;

}

#define numLEDPins 3
int LEDPin[numLEDPins] = {8,9,3}; //G,R,B
#define bLEDIndex 2
#define gLEDIndex 0
#define rLEDIndex 1

#define LEDBlinkingPeriodInMilliSec 1000 //3s
#define LEDToSleepDurationInMilliSec 30000 //30s
#define LEDToActiveDurationInMilliSec 3000 //3s

enum LEDState {
  Sleep = 0,
  Active,
  Triggered
};

LEDState ledState = Sleep;

uint32_t timerForLEDBlinking = 0;
uint8_t LEDSleepBlinkingState = LOW;

void initLEDSleepVars() {
  timerForLEDBlinking = millis();
  LEDSleepBlinkingState = LOW;
  ledState = Sleep;
}

uint32_t timerForLEDActive = 0;
bool toLightLEDBlue = false;

void initLEDActiveVars() {
  timerForLEDActive = millis();
  toLightLEDBlue = true;
  ledState = Active;
}

void lightLEDBlue() {
  if(toLightLEDBlue) {
    digitalWrite(LEDPin[bLEDIndex], HIGH);
    digitalWrite(LEDPin[rLEDIndex], LOW);
    digitalWrite(LEDPin[gLEDIndex], LOW);
    toLightLEDBlue = false;
  }
}

uint32_t timerForLEDTriggered = 0;
bool toLightLEDGreen = false;

void initLEDTriggeredVars() {
  timerForLEDTriggered = millis();
  toLightLEDGreen = true;
  ledState = Triggered;
}

void lightLEDGreen() {
  if(toLightLEDGreen) {
    digitalWrite(LEDPin[gLEDIndex], HIGH);
    digitalWrite(LEDPin[rLEDIndex], LOW);
    digitalWrite(LEDPin[bLEDIndex], LOW);
    toLightLEDGreen = false;
  }
}

void decideLEDLighting() {
  if(ledState == Sleep) {
    //Blinking every 3 secs with white color
    if(millis() - timerForLEDBlinking >= LEDBlinkingPeriodInMilliSec) {
      for(int i = 0;i < numLEDPins;i++) {
        digitalWrite(LEDPin[i], LEDSleepBlinkingState);
      }
      LEDSleepBlinkingState = !LEDSleepBlinkingState;
      timerForLEDBlinking = millis();
    }
  }
  else if(ledState == Active) {
    //light in Blue and set timer for sleeping event
    lightLEDBlue();

    if(millis() - timerForLEDActive >= LEDToSleepDurationInMilliSec) {
      //transit to sleep state
      initLEDSleepVars();
    }

  }
  else if(ledState == Triggered){
    //light in green and turned into led active state in 3 secs
    lightLEDGreen();

    if(millis() - timerForLEDTriggered >= LEDToActiveDurationInMilliSec) {
      //transit to active state
      initLEDActiveVars();
    }

  }
}

void setup() {
  Serial.begin(9600);

  for(int i = 0;i < numLEDPins;i++) {
    pinMode(LEDPin[i],OUTPUT);  
    digitalWrite(LEDPin[i], LOW);
  }
  
  initLEDSleepVars();
  
//-- strain gauge
  for(int i = 0;i < numButtons;i++) {
    pinMode(buttonPin[i], INPUT);
  }

  for(int i=MULT_MIN_PIN; i<MULT_MIN_PIN+NUM_OF_MULT_PINS; i++){
    pinMode(i, OUTPUT);
  }

  //IMU I2C
  I2C_Init();
#ifdef USING_SEN10724
  Accel_Init();
#elif defined(USING_MPU9150) || defined(USING_MPU6050)
  Do_Calibrarion();
#endif

  
  //Serial.println("init wifi client");
  
  LWiFi.begin();
  connectToAP();  
  
  //Serial.println("Wifi AP connected successfully");
  
  udpClient.begin(udpLocalPort);
}

void loop() {

//-- accelerometer

  Read_Accel();
  sprintf(buff_w,"a %d %d %d \n",accel[0],accel[1],accel[2]);
  transmitUDPPacket();
  
  char mode = 's';
  if(digitalRead(buttonPin[0]) == LOW) {  //do calibration
    mode = 'c'; 
  }

//-- strain gauges

  for(int i=0; i<NUM_OF_GAUGE; i++){
    digitalWrite(MULT_MIN_PIN, i & 1);
    digitalWrite(MULT_MIN_PIN+1, (i >> 1) & 1);
    digitalWrite(MULT_MIN_PIN+2, (i >> 2) & 1);
    analogVals[i] = analogRead(GAUGE_PIN);
  }
  
  sprintf(buff_w,"%c %d %d %d %d %d \n",mode,analogVals[0],analogVals[1],analogVals[2],analogVals[3],analogVals[4]);
  transmitUDPPacket();

//-- LED --

  //after you get analogVals of strain gauges
  updateVarianceUsingAnalogVals();

  if(numAnalogValsAccumulated == numSamplesForVarianceTest) {
    if(varianceExceedThreshold(thresholdForStateTransition,numGaugesForStateTransition)) {
      if(ledState == Sleep) {
        //transit to active
        initLEDActiveVars();
      }
      else if(ledState == Active) {
        //transit to triggered
        initLEDTriggeredVars();
      }
    }
  }

  decideLEDLighting();

}
