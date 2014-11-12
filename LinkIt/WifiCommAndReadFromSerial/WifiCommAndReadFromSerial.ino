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

#include <LTask.h>
#include <LWiFi.h>
#include <LWiFiClient.h>
#include <string>

#define WIFI_AP "HandTieNotHentai"
#define WIFI_PASSWORD "androidiphone"
#define WIFI_AUTH LWIFI_WEP  // choose from LWIFI_OPEN, LWIFI_WPA, or LWIFI_WEP.

#define WRITE_BUFF_SIZE ((int)4096)
#define ENDDING_CHAR 0
#define NEWLINE_CHAR '\n'
#define Serial1BaudRate 115200

#define serverPort ((uint16_t)8080)
IPAddress serverIP (192,168,1,2);

const uint16_t retryIntervalInMilliSec = 1000;
LWiFiLoginInfo APConnectingInfo(WIFI_AUTH, WIFI_PASSWORD);
LWiFiClient wifiClient;

void connectToAP() {
  while (0 == LWiFi.connect(WIFI_AP, APConnectingInfo)) {
    Serial.println("connecting Wifi AP failed");
    delay(retryIntervalInMilliSec);
  }
}

void checkOrWaitForConnection() {
  if(!wifiClient.connected()) {
    //Serial.println("no connection to server right now");
    if(LWiFi.status() == LWIFI_STATUS_DISCONNECTED) {
      connectToAP();
    }

    while(wifiClient.connect(serverIP,serverPort) == 0) {
      Serial.println("connecting to server failed");
      delay(retryIntervalInMilliSec);
    } 
  }
}

char buff_w[WRITE_BUFF_SIZE];

void setup() {
  Serial1.begin(Serial1BaudRate);
  Serial1.setTimeout(100); //make reading more smoothly
  Serial.begin(9600);

  Serial.println("init wifi client");

  LTask.begin();
  LWiFi.begin();

  connectToAP();  
  
  Serial.println("Wifi AP connected successfully");

  checkOrWaitForConnection();
}

void loop() {
  int numByteReadFromSerial = Serial1.readBytes(buff_w,WRITE_BUFF_SIZE); //read from arduino
  if(numByteReadFromSerial > 0) {
    //Serial.write(buff_w,numByteReadFromSerial);
    int numByteWritten = 0;
    while(numByteWritten < numByteReadFromSerial) {
      //assumed we have been connected to server here.
      int write_size = wifiClient.write((const uint8_t*)(buff_w + numByteWritten), numByteReadFromSerial - numByteWritten);
      if(write_size > 0) {
        numByteWritten += write_size;
      }
      else { //something wrong
        checkOrWaitForConnection();
      }
    }
  }
  else {
    //Serial.println("I think LinkIt is absolutely a crap");
    Serial1.end();
    Serial1.begin(Serial1BaudRate);
  }
  
}
