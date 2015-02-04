#ifndef ParserWithAction_h
#define ParserWithAction_h

#include <Arduino.h>
#include "SGManager.h"

enum{
   ALL_CALIBRATION,

   MANUAL_CHANGE_TO_ONE_GAUGE_NO_AMP,
   MANUAL_CHANGE_TO_ONE_GAUGE_WITH_AMP,

   MANUAL_CHANGE_TO_ALL_GAUGES_NO_AMP,
   MANUAL_CHANGE_TO_ALL_GAUGES_WITH_AMP
};

class ParserWithAction
{
public:
   ParserWithAction(SGManager *);
   ~ParserWithAction();

   void parse();

private:
   SGManager * sgManager;

   void parseForManualChangeToOneGaugeNoAmp();
   void parseForManualChangeToOneGaugeWithAmp();
   void parseForManualChangeToAllGaugesNoAmp();
   void parseForManualChangeToAllGaugesWithAmp();
};

#endif