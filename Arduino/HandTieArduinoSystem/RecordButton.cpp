#include "RecordButton.h"

RecordButton::RecordButton(){
   pinMode(RECORD_BUTTON_PIN, INPUT_PULLUP);
}

RecordButton::~RecordButton(){}

void RecordButton::checkClick(){
   if(digitalRead(RECORD_BUTTON_PIN) == LOW){
      Serial.print(SEND_RECORD_SIGNAL);
      Serial.println("1");
      while(digitalRead(RECORD_BUTTON_PIN) == LOW);
   }
}