#ifndef ParserWithAction_h
#define ParserWithAction_h

#include <Arduino.h>
#include "SGManager.h"
#include "RGBLED.h"
#include "SerialProtocol.h"

class ParserWithAction
{
public:
   ParserWithAction(SGManager *, RGBLED *);
   ~ParserWithAction();

   void parse();

private:
   SGManager * sgManager;
   RGBLED * rgbLED;

   void parseForManualChangeToOneGaugeTargetValMinAmp();
   void parseForManualChangeToOneGaugeTargetValWithAmp();
   void parseForManualChangeToOneGaugeTargetValAtConstAmp();

   void parseForManualChangeToOneGaugeBridgePotPos();
   void parseForManualChangeToOneGaugeAmpPotPos();

   void parseForManualChangeToAllGaugesTargetValsMinAmp();
   void parseForManualChangeToAllGaugesTargetValsWithAmp();
   void parseForManualChangeToAllGaugesTargetValsAtConstAmp();

   void parseForManualChangeToAllGaugesBridgePotPos();
   void parseForManualChangeToAllGaugesAmpPotPos();

   void parseReceiveLedSignal();
};

#endif