#include <SPI.h>
#include <Wire.h>
#include "SGManager.h"
#include "ParserWithAction.h"
// #include "RecordButton.h"
#include "ADXL345.h"
#include "RGBLED.h"

SGManager sgManager;
RGBLED rgbLED;
ParserWithAction parser(&sgManager, &rgbLED);
// RecordButton recordButton;
ADXL345 * accel;

void setup(){
   Serial.begin(38400);
   sgManager.allCalibrationAtConstAmp();
   accel = new ADXL345();
   //rgbLED.setLED(5,5,5,5,10,10,10,2);
}

void loop(){
   sgManager.serialPrint();
   accel->serialPrintRaw();
   // recordButton.checkClick();
   rgbLED.ledAction();

   Serial.println();
}

void serialEvent(){
   while(Serial.available()){
     parser.parse();
   }
}
