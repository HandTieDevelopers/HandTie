#ifndef ParserWithAction_h
#define ParserWithAction_h

#include <Arduino.h>
#include "SGManager.h"
#include "SerialProtocol.h"

class ParserWithAction
{
public:
   ParserWithAction(SGManager *);
   ~ParserWithAction();

   void parse();

private:
   SGManager * sgManager;

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
};

#endif