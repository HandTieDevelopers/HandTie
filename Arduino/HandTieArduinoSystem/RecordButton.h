#include <Arduino.h>
#include "SerialProtocol.h"

#define RECORD_BUTTON_PIN 6

class RecordButton{
public:
   RecordButton();
   ~RecordButton();

   void checkClick();
private:

};