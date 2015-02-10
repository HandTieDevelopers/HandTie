#include <SPI.h>
#include "SGManager.h"
#include "ParserWithAction.h"

#define RECORD_BUTTON_PIN 6

SGManager sgManager;
ParserWithAction parser(&sgManager);

void setup(){
   Serial.begin(115200);
   sgManager.allCalibration();

   pinMode(RECORD_BUTTON_PIN, INPUT_PULLUP);
}

void loop(){
   sgManager.serialPrint();

   if(digitalRead(RECORD_BUTTON_PIN) == LOW){
      Serial.print(SEND_RECORD_SIGNAL);
      Serial.println("1");
      while(digitalRead(RECORD_BUTTON_PIN) == LOW);
   }
}

void serialEvent(){
   while(Serial.available()){
      parser.parse();
   }
}
