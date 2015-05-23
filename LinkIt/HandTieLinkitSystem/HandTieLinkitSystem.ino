#include <SPI.h>
#include "SGManager.h"
#include "ParserWithAction.h"
#include "RecordButton.h"

SGManager * sgManager;
ParserWithAction * parser;
RecordButton * recordButton;

void setup(){
   Serial.begin(38400);
   
   sgManager = new SGManager();
   parser = new ParserWithAction(sgManager);
   recordButton = new RecordButton();

   sgManager->allCalibrationAtConstAmp();
}

void loop(){
   sgManager->serialPrint();
   recordButton->checkClick();
}

void serialEvent(){
   while(Serial.available()){
      parser->parse();
   }
}
