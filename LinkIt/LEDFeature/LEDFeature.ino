#include <stdio.h>
#include <stdlib.h>

//-- breathing LED -- not working on LinkIt
/*
#define PERIOD_COUNTER 1000

int easeInOutQuad(float t, int b, int c, uint32_t d) {
	t /= d/2;
	if (t < 1) return c/2*t*t + b;
	t--;
	return -c/2 * (t*(t-2) - 1) + b;
};

uint32_t counter = 0;
bool counterInverse = false;
int step = 1;
*/
//

//strain gauge 
const uint16_t numStrainGauges = 5;
const uint16_t strainGaugePins[numStrainGauges] = {0,1,2,3,6};

uint16_t analogVals[numStrainGauges] = {0};

uint16_t numAnalogValsAccumulated = 0;
uint32_t analogValsSum[numStrainGauges] = {0};
uint32_t analogValsSquareSum[numStrainGauges] = {0};

#define numSamplesForVarianceTest 100

bool varianceExceedThreshold(uint16_t threshold, uint8_t numValsToTriger) {
	float numAnalogValsAccumulatedInFloat = numAnalogValsAccumulated;
	numAnalogValsAccumulated = 0; //init

	for(int i = 0;i < numStrainGauges;i++) {
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
	for(int i = 0;i < numStrainGauges;i++) {
		analogValsSum[i] += analogVals[i];	
		analogValsSquareSum[i] += analogVals[i]*analogVals[i];
	}
	numAnalogValsAccumulated++;

}

#define numLEDPins 3
int LEDPin[numLEDPins] = {3,8,9}; //G,R,B
#define bLEDIndex 2
#define gLEDIndex 0
#define rLEDIndex 1

#define LEDBlinkingPeriodInMilliSec 3000 //3s
#define LEDToSleepDurationInMilliSec 30000 //30s
#define LEDToActiveDurationInMilliSec 3000 //3s

enum LEDState {
	Sleep = 0,
	Active,
	Triggered
};

LEDState ledState = Sleep;

uint32_t timerForLEDBlinking = 0;
uint8_t LEDSleepBlinkingState = LOW;

void initLEDSleepVars() {
	timerForLEDBlinking = millis();
	LEDSleepBlinkingState = LOW;
	ledState = Sleep;
}

uint32_t timerForLEDActive = 0;
bool toLightLEDBlue = false;

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

uint32_t timerForLEDTriggered = 0;
bool toLightLEDGreen = false;

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

void setup() {
	Serial.begin(9600);
	for(int i = 0;i < numLEDPins;i++) {
		pinMode(LEDPin[i],OUTPUT);	
		digitalWrite(LEDPin[i], LOW);
	}
	
	initLEDSleepVars();
}

void loop() {
	/*
	int newLEDVal;
	newLEDVal = easeInOutQuad(counter,0,255,PERIOD_COUNTER);
	//analogWrite(LEDPin[0], newLEDVal);
	//analogWrite(LEDPin[1], newLEDVal);

	counter += step;
	if(counter == 0) {
		step = 1;
	}
	else if(counter == PERIOD_COUNTER) {
		step = -1;
	}
	*/
	
	//after you get analogVals of strain gauges
	updateVarianceUsingAnalogVals();

	if(numAnalogValsAccumulated == numSamplesForVarianceTest) {
		if(varianceExceedThreshold(20,3)) {
			if(ledState == Sleep) {
				//transit to active
				initLEDActiveVars();
			}
			else if(ledState == Active) {
				//transit to triggered
				initLEDTriggeredVars();
			}
		}
	}

	decideLEDLighting();
	

}
