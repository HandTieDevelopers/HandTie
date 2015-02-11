#include <Arduino.h>
#include "SerialProtocol.h"

#define RECORD_BUTTON_PIN 7

class RecordButton{
public:
   RecordButton();
   ~RecordButton();

   void checkClick();
private:

};
