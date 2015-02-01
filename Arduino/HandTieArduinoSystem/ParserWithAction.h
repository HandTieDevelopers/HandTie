#ifndef ParserWithAction_h
#define ParserWithAction_h

#include <Arduino.h>
#include "SGManager.h"

enum{
   ALL_CALIBRATION,

   MANUAL_CHANGE_TO_ONE_GAUGE,
   MANUAL_CHANGE_TO_ALL_GAUGES
};

class ParserWithAction
{
public:
   ParserWithAction(SGManager *);
   ~ParserWithAction();

   void parse();

private:
   SGManager * sgManager;

   void parseForManualChangeToOneGauge();
   void parseForManualChangeToAllGauges();
};

#endif