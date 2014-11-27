
bool varianceExceedThreshold(uint16_t threshold, uint8_t numValsToTriger) {
  float numAnalogValsAccumulatedInFloat = numAnalogValsAccumulated;
  numAnalogValsAccumulated = 0; //init

  for(int i = 0;i < NUM_OF_GAUGE;i++) {
    float analogValsAvg = analogValsSum[i]/numAnalogValsAccumulatedInFloat;
    float variance = analogValsSquareSum[i]/numAnalogValsAccumulatedInFloat - analogValsAvg * analogValsAvg; //E[x^2] - E[x]^2
    
    //for tuning parameters
    Serial.print(i);
    Serial.print(":");
    Serial.println(variance);
    
    //init variables
    analogValsSum[i] = 0;
    analogValsSquareSum[i] = 0;   

    if(variance > threshold) {
      numValsToTriger--;
      if(numValsToTriger <= 0) {
        return true;
      }
    }
  }
  
  return false;
}


void updateVarianceUsingAnalogVals() {
  for(int i = 0;i < NUM_OF_GAUGE;i++) {
    analogValsSum[i] += analogVals[i];  
    analogValsSquareSum[i] += analogVals[i]*analogVals[i];
  }
  numAnalogValsAccumulated++;

}

void initLEDSleepVars() {
  timerForLEDBlinking = millis();
  LEDSleepBlinkingState = LOW;
  ledState = Sleep;
}


void initLEDActiveVars() {
  timerForLEDActive = millis();
  toLightLEDBlue = true;
  ledState = Active;
}

void lightLEDBlue() {
  if(toLightLEDBlue) {
    digitalWrite(LEDPin[bLEDIndex], HIGH);
    digitalWrite(LEDPin[rLEDIndex], LOW);
    digitalWrite(LEDPin[gLEDIndex], LOW);
    toLightLEDBlue = false;
  }
}

void initLEDTriggeredVars() {
  timerForLEDTriggered = millis();
  toLightLEDGreen = true;
  ledState = Triggered;
}

void lightLEDGreen() {
  if(toLightLEDGreen) {
    digitalWrite(LEDPin[gLEDIndex], HIGH);
    digitalWrite(LEDPin[rLEDIndex], LOW);
    digitalWrite(LEDPin[bLEDIndex], LOW);
    toLightLEDGreen = false;
  }
}

void decideLEDLighting() {
  if(ledState == Sleep) {
    //Blinking every 3 secs with white color
    if(millis() - timerForLEDBlinking >= LEDBlinkingPeriodInMilliSec) {
      for(int i = 0;i < numLEDPins;i++) {
        digitalWrite(LEDPin[i], LEDSleepBlinkingState);
      }
      LEDSleepBlinkingState = !LEDSleepBlinkingState;
      timerForLEDBlinking = millis();
    }
  }
  else if(ledState == Active) {
    //light in Blue and set timer for sleeping event
    lightLEDBlue();

    if(millis() - timerForLEDActive >= LEDToSleepDurationInMilliSec) {
      //transit to sleep state
      initLEDSleepVars();
    }

  }
  else if(ledState == Triggered){
    //light in green and turned into led active state in 3 secs
    lightLEDGreen();

    if(millis() - timerForLEDTriggered >= LEDToActiveDurationInMilliSec) {
      //transit to active state
      initLEDActiveVars();
    }

  }
}