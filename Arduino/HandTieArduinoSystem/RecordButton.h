#include <Arduino.h>
#include "SerialProtocol.h"

#define RECORD_BUTTON_PIN 9
#define RECORD_INTERVAL ((uint16_t)300)
class RecordButton{
public:
   RecordButton();
   ~RecordButton();
   void checkClick();
private:

};
