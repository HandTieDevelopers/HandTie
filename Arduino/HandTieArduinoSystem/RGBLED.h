#include <Arduino.h>

#define RED_PIN   8
#define GREEN_PIN 9
#define BLUE_PIN  9

enum{
   LED_ON,
   LED_OFF,
   LED_BLINK,
   LED_FADE   
};

enum{
   RED,
   GREEN,
   BLUE,
   YELLOW,
   CYAN,
   MAGENTA
};

class RGBLED
{
public:
   RGBLED();
   void ledAction();

   void setLED(uint16_t onSpanTime, uint16_t offSpanTime,                //for blink and fade
               uint16_t onToOffTransition, uint16_t offToOnTransition,   //for fade
               uint8_t color, uint8_t repeat);

private:
   uint16_t onSpanTime;
   uint16_t offSpanTime;
   uint16_t onToOffTransition;
   uint16_t offToOnTransition;
   uint8_t color;
   uint8_t repeat;

   unsigned long lastMillis;

   void createColor(uint8_t brightness);
};