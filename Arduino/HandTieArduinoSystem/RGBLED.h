#ifndef RGBLED_H
#define RGBLED_H

#include <Arduino.h>

#define RED_PIN   8
#define GREEN_PIN 9
#define BLUE_PIN  9

#define RED_ORIGINAL_COLOR 10
#define GREEN_ORIGINAL_COLOR 10
#define BLUE_ORIGINAL_COLOR 10

#if ( RED_PIN == 3 || RED_PIN == 5 || RED_PIN == 6 || RED_PIN ==  9 || RED_PIN ==  10 ||  RED_PIN ==  11 )
   #define RED_PIN_HAS_ANALOG 1
#else
   #define RED_PIN_HAS_ANALOG 0
#endif

#if ( GREEN_PIN == 3 || GREEN_PIN == 5 || GREEN_PIN == 6 || GREEN_PIN ==  9 || GREEN_PIN ==  10 ||  GREEN_PIN ==  11 )
   #define GREEN_PIN_HAS_ANALOG 1
#else 
   #define GREEN_PIN_HAS_ANALOG 0
#endif

#if ( BLUE_PIN == 3 || BLUE_PIN == 5 || BLUE_PIN == 6 || BLUE_PIN ==  9 || BLUE_PIN ==  10 ||  BLUE_PIN ==  11 )
   #define BLUE_PIN_HAS_ANALOG 1
#else
   #define BLUE_PIN_HAS_ANALOG 0
#endif


enum{
   LED_OFFTOON,
   LED_ON,
   LED_ONTOOFF,
   LED_OFF,
   LED_ORIGINAL
};

class RGBLED
{
public:
   RGBLED();
   void ledAction();

   void setLED(uint16_t onSpanTime, uint16_t offSpanTime,                //for blink and fade
               uint16_t onToOffTransition, uint16_t offToOnTransition,   //for fade
               uint8_t r_color, uint8_t g_color, uint8_t b_color, uint8_t repeat);

private:
   unsigned long onSpanTime;
   unsigned long offSpanTime;
   unsigned long onToOffTransition;
   unsigned long offToOnTransition;
   unsigned long period;
   uint8_t r_color;
   uint8_t g_color;
   uint8_t b_color;
   uint8_t repeat;
   uint8_t led_state;

   unsigned long actionstart_Millis;
   unsigned long lastMillis;

   void eval_state();
   void createColor();
   void offtoon_color();
   void on_color();
   void ontooff_color();
   void off_color();
   void original_color();
};

#endif RGBLED_H