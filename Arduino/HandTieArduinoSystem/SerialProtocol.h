#ifndef Serial_Protocol_h
#define Serial_Protocol_h

// ------------- Send to Processing ------------ //

// Strain Gauge Protocol and State Machine
enum{
   // --- State Machine and Protocol ----- //
   SEND_NORMAL_VALS,
   SEND_CALI_VALS,

   SEND_TARGET_MIN_AMP_VALS,
   SEND_TARGET_AMP_VALS,

   SEND_BRIDGE_POT_POS_VALS,
   SEND_AMP_POT_POS_VALS,

   // ----------- Pure Protocol ---------- //
   SEND_CALIBRATING_MIN_AMP_VALS,
   SEND_CALIBRATING_AMP_VALS,

   // ------- Pure State Machine --------- //
   STATE_CALIBRATING_BRIDGE_AT_MIN_AMP,
   STATE_CALIBRATING_BRIDGE_AT_CONST_AMP,
   STATE_CALIBRATING_AMP_AT_CONST_BRIDGE,
   STATE_CALIBRATING_BRIDGE_AT_MIN_AMP_THEN_AMP_VALS
};

// Button Protocol
enum{
   SEND_RECORD_SIGNAL = 8,
};

// ---------- Receive from Processing ----------- //
enum{
   // -------- Common Protocol -------- //
   ALL_CALIBRATION,
   ALL_CALIBRATION_CONST_AMP,

   // ------Strain Gauge Protocol ----- //
   MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_MIN_AMP,
   MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_WITH_AMP,
   MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_AT_CONST_AMP,

   MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_MIN_AMP,
   MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_WITH_AMP,
   MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_AT_CONST_AMP,

   MANUAL_CHANGE_TO_ONE_GAUGE_BRIDGE_POT_POS,
   MANUAL_CHANGE_TO_ONE_GAUGE_AMP_POT_POS,
   
   MANUAL_CHANGE_TO_ALL_GAUGE_BRIDGE_POT_POS,
   MANUAL_CHANGE_TO_ALL_GAUGE_AMP_POT_POS
};


#endif  //Serial_Protocol_h