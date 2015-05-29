#include "RGBLED.h"

RGBLED::RGBLED(){
   pinMode(RED_PIN, INPUT_PULLUP);
   pinMode(GREEN_PIN, INPUT_PULLUP);
   pinMode(BLUE_PIN, INPUT_PULLUP);
   
   r_color = RED_ORIGINAL_COLOR;
   g_color = GREEN_ORIGINAL_COLOR;
   b_color = BLUE_ORIGINAL_COLOR;
}

void RGBLED::ledAction(){
    this->lastMillis = millis();
    eval_state();
    createColor();
    //analogWrite(GREEN_PIN, g_color);
    //analogWrite(RED_PIN, r_color);
    //analogWrite(BLUE_PIN, b_color);
}

void RGBLED::setLED(uint16_t onSpanTime, uint16_t offSpanTime,               //for blink and fade
                    uint16_t onToOffTransition, uint16_t offToOnTransition,   //for fade
                    uint8_t r_color, uint8_t g_color, uint8_t b_color,uint8_t repeat){
   this->onSpanTime = onSpanTime*1000;
   this->offSpanTime = offSpanTime*1000;
   this->onToOffTransition = onToOffTransition*1000;
   this->offToOnTransition = offToOnTransition*1000;
   this->period = (onSpanTime + offSpanTime
                  + onToOffTransition + offToOnTransition)*1000;
   this->r_color = r_color;
   this->g_color = g_color;
   this->b_color = b_color;
   this->repeat = repeat;
   this->actionstart_Millis = millis();
}

void RGBLED::eval_state(){
    if((lastMillis - actionstart_Millis)/period > repeat )
      led_state = LED_ORIGINAL;
    else if((lastMillis - actionstart_Millis)%period < offToOnTransition)
      led_state = LED_OFFTOON;
    else if((lastMillis - actionstart_Millis)%period >= offToOnTransition && (lastMillis - actionstart_Millis)%period < (offToOnTransition + onSpanTime))
      led_state = LED_ON;
    else if ((lastMillis - actionstart_Millis)%period >= (offToOnTransition + onSpanTime) && (lastMillis - actionstart_Millis)%period < (offToOnTransition + onSpanTime + onToOffTransition) )
      led_state = LED_ONTOOFF;
    else
      led_state = LED_OFF;
}

void RGBLED::createColor(){
    switch(led_state){
      case LED_OFFTOON:
        offtoon_color();
        break;
      case LED_ON:
        on_color();
        break;
      case LED_ONTOOFF:
        ontooff_color();
        break;
      case LED_OFF:
        off_color();
        break;
      case LED_ORIGINAL:
        original_color();
        break;
    }
}

void RGBLED::offtoon_color(){
    if(RED_PIN_HAS_ANALOG)
      analogWrite(RED_PIN, ((lastMillis - actionstart_Millis)%period * r_color)/offToOnTransition );
    else
      digitalWrite(RED_PIN, r_color/122);

    if(GREEN_PIN_HAS_ANALOG)
      analogWrite(GREEN_PIN, ((lastMillis - actionstart_Millis)%period * g_color)/offToOnTransition );
    else
      digitalWrite(GREEN_PIN, g_color/122);

    if(BLUE_PIN_HAS_ANALOG)
      analogWrite(BLUE_PIN, ((lastMillis - actionstart_Millis)%period * b_color)/offToOnTransition );
    else
      digitalWrite(BLUE_PIN, b_color/122);
}

void RGBLED::on_color(){
    if(RED_PIN_HAS_ANALOG)
      analogWrite(RED_PIN, r_color);
    else
      digitalWrite(RED_PIN, r_color/122);

    if(GREEN_PIN_HAS_ANALOG)
      analogWrite(GREEN_PIN, g_color);
    else
      digitalWrite(GREEN_PIN, g_color/122);

    if(BLUE_PIN_HAS_ANALOG)
      analogWrite(BLUE_PIN, b_color);
    else
      digitalWrite(BLUE_PIN, b_color/122);
}

void RGBLED::ontooff_color(){
    if(RED_PIN_HAS_ANALOG)
      analogWrite(RED_PIN, 
        r_color - (((lastMillis - actionstart_Millis)%period - offToOnTransition - onSpanTime) * r_color)/onToOffTransition);
    else
      digitalWrite(RED_PIN, r_color/122);

    if(GREEN_PIN_HAS_ANALOG)
      analogWrite(GREEN_PIN, 
        g_color - (((lastMillis - actionstart_Millis)%period - offToOnTransition - onSpanTime) * g_color)/onToOffTransition);
    else
      digitalWrite(GREEN_PIN, g_color/122);

    if(BLUE_PIN_HAS_ANALOG)
      analogWrite(BLUE_PIN, 
        b_color - (((lastMillis - actionstart_Millis)%period - offToOnTransition - onSpanTime) * b_color)/onToOffTransition);
    else
      digitalWrite(BLUE_PIN, b_color/122);
}

void RGBLED::off_color(){
    if(RED_PIN_HAS_ANALOG)
      analogWrite(RED_PIN, 0);
    else
      digitalWrite(RED_PIN, 0);

    if(GREEN_PIN_HAS_ANALOG)
      analogWrite(GREEN_PIN, 0);
    else
      digitalWrite(GREEN_PIN, 0);

    if(BLUE_PIN_HAS_ANALOG)
      analogWrite(BLUE_PIN, 0);
    else
      digitalWrite(BLUE_PIN, 0);
}

void RGBLED::original_color(){
    setLED(2,2,2,2,0,20,20,10000);
    /*if(RED_PIN_HAS_ANALOG)
      analogWrite(RED_PIN, RED_ORIGINAL_COLOR);
    else
      digitalWrite(RED_PIN, RED_ORIGINAL_COLOR/122);

    if(GREEN_PIN_HAS_ANALOG)
      analogWrite(GREEN_PIN, GREEN_ORIGINAL_COLOR);
    else
      digitalWrite(GREEN_PIN, GREEN_ORIGINAL_COLOR/122);

    if(BLUE_PIN_HAS_ANALOG)
      analogWrite(BLUE_PIN, BLUE_ORIGINAL_COLOR);
    else
      digitalWrite(BLUE_PIN, BLUE_ORIGINAL_COLOR/122);*/

}
