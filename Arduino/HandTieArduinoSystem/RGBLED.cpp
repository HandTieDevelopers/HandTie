#include "RGBLED.h"

RGBLED::RGBLED(){
   pinMode(RED_PIN, INPUT_PULLUP);
   pinMode(GREEN_PIN, INPUT_PULLUP);
   pinMode(BLUE_PIN, INPUT_PULLUP);
}

void RGBLED::ledAction(){

}

void RGBLED::setLED(uint16_t onSpanTime, uint16_t offSpanTime,               //for blink and fade
                    uint16_t onToOffTransition, uint16_t offToOnTransition,   //for fade
                    uint8_t color, uint8_t repeat){
   this->onSpanTime = onSpanTime;
   this->offSpanTime = offSpanTime;
   this->onToOffTransition = onToOffTransition;
   this->offToOnTransition = offToOnTransition;
   this->color = color;
   this->repeat = repeat;
}

void RGBLED::createColor(uint8_t brightness){
   switch(color){
      case RED:
         //digitalWrite
         //analogWrite
         break;
      case GREEN:
         break;
   }
}