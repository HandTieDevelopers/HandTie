#ifndef ParserWithAction_h
#define ParserWithAction_h

#include <Arduino.h>
#include "SGManager.h"

enum{
   ALL_CALIBRATION,

   MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_NO_AMP,
   MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_WITH_AMP,

   MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_NO_AMP,
   MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_WITH_AMP,

   REQUEST_FOR_TARGET_VALS_NO_AMP,
   REQUEST_FOR_TARGET_VALS_WITH_AMP,

   MANUAL_CHANGE_TO_ONE_GAUGE_BRIDGE_POT_POS,
   MANUAL_CHANGE_TO_ONE_GAUGE_AMP_POT_POS
};

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