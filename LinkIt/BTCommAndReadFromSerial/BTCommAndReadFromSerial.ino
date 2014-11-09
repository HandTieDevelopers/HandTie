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
#include <LBT.h>
#include <LBTServer.h>
#define SPP_SVR "LinkItBTServer" // it is the server's visible name
#define Specific_Client_Addr "7C:D1:C3:8C:70:33"
#define WRITE_BUFF_SIZE ((int)300)
#define ENDDING_CHAR 0
#define NEWLINE_CHAR '\n'
#define Serial1BaudRate 57600

bool connected = false;
char buff_w[WRITE_BUFF_SIZE] = {0};

void setup() {
  Serial1.begin(Serial1BaudRate);
  Serial1.setTimeout(100); //make reading more smoothly
  Serial.begin(9600);

  Serial.println("init BT server");

  while( !LBTServer.begin((uint8_t*)SPP_SVR) )
  {
    Serial.println("Cannot begin Bluetooth Server successfully");
    // don't do anything else
    delay(0xffffffff);
  }
  
  Serial.println("Bluetooth Server begin successfully");
  
}

//int numByteReadFromSerial = 0;
//bool stringCompleteWithNewline = false;
void loop() {
  
  while( !connected )
  {
    //Serial.println("no connection yet");
    connected = LBTServer.accept(10000,Specific_Client_Addr);
  }
  
  //Serial.print("Connected, address");
  //Serial.println(Specific_Client_Addr);
  
  int numByteReadFromSerial = Serial1.readBytes(buff_w,WRITE_BUFF_SIZE);
  if(numByteReadFromSerial > 0) {
    //Serial.write(buff_w,numByteReadFromSerial);
    int numByteWritten = 0;
    while(numByteWritten < numByteReadFromSerial) {
      int write_size = LBTServer.write((uint8_t*)(buff_w + numByteWritten), numByteReadFromSerial - numByteWritten);
      if(write_size > 0) {
        numByteWritten += write_size;
      }

      if(!LBTServer.connected()) {
        Serial.println("no connection right now");
        /*
        LBTServer.end();
        while( !LBTServer.begin((uint8_t*)SPP_SVR) )
        {
          Serial.println("Cannot begin Bluetooth Server successfully");
          // don't do anything else
          //delay(0xffffffff);
        }
        */
        connected = false;
        break;
      }
    }
  }
  else {
    //Serial.println("I think LinkIt is absolutely a crap");
    Serial1.end();
    Serial1.begin(Serial1BaudRate);
  }
  

}
