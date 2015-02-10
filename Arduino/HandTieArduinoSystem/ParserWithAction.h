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

   void parseForManualChangeToOneGaugeTargetValNoAmp();
   void parseForManualChangeToOneGaugeTargetValWithAmp();
   void parseForManualChangeToOneGaugeBridgePotPos();
   void parseForManualChangeToOneGaugeAmpPotPos();

   void parseForManualChangeToAllGaugesTargetValsNoAmp();
   void parseForManualChangeToAllGaugesTargetValsWithAmp();
};

#endif