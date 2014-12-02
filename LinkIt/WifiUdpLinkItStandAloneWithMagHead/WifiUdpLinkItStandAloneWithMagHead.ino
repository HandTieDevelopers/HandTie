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
#include "constantsAndVars.h"

void setup() {
  Serial.begin(9600);

//-- LED

  for(int i = 0;i < numLEDPins;i++) {
    pinMode(LEDPin[i],OUTPUT);  
    digitalWrite(LEDPin[i], LOW);
  }
  
  initLEDSleepVars();
  
//-- strain gauges

  for(int i = 0;i < numButtons;i++) {
    pinMode(buttonPin[i], INPUT_PULLUP);
  }

  for(int i=MULT_MIN_PIN; i<MULT_MIN_PIN+NUM_OF_MULT_PINS; i++){
    pinMode(i, OUTPUT);
  }

//-- IMU

  // Init sensors
  I2C_Init();
  Accel_Init();
  Magn_Init();
  Gyro_Init();
  
  // Read sensors, init DCM algorithm
  delay(20);  // Give sensors enough time to collect data
  reset_sensor_fusion();

//-- Udp Client

  //Serial.println("init wifi client");
  
  LWiFi.begin();
  connectToAP();  
  
  //Serial.println("Wifi AP connected successfully");
  
  udpClient.begin(udpLocalPort);

}

void loop() {

//-- IMU   
  // timestamp_old = timestamp;
  // timestamp = millis();
  // if (timestamp > timestamp_old)
  //   G_Dt = (float) (timestamp - timestamp_old) / 1000.0f; // Real time of loop run. We use this on the DCM algorithm (gyro integration time)
  // else G_Dt = 0;

  // Update sensor readings
  read_sensors();

  // Apply sensor calibration
  compensate_sensor_errors();

  // Run DCM algorithm
  Compass_Heading(); // Calculate magnetic heading
  Matrix_update();
  Normalize();
  Drift_correction();
  Euler_angles();
  
  accelForSending[0] = accel[0];
  accelForSending[1] = accel[1];
  accelForSending[2] = accel[2];

  sprintf(buff_w,"a %d %d %d %.2f \n",accelForSending[0],accelForSending[1],accelForSending[2],MAG_Heading);
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
