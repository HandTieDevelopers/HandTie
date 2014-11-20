#include <stdio.h>
#include <stdlib.h>

//strain gauge 
const uint16_t numStrainGauges = 5;
const uint16_t numButtons = 1;
//due to nano occupying A4 and A5 for I2C communication,we change strain gauge to A6
const uint16_t strainGaugePins[numStrainGauges] = {0,1,2,3,6};
const uint16_t buttonPin[numButtons] = {2};
uint16_t analogVals[numStrainGauges] = {0};

const uint32_t baud_rate = 115200;
char commBuff[100];

void setup() {
	Serial.begin(baud_rate);
	for(int i = 0;i < numButtons;i++) {
		pinMode(buttonPin[i], INPUT);
	}
}

void loop() {
	
	//Reading Values
	for(int i = 0;i < numStrainGauges;i++) {
		analogVals[i] = analogRead(strainGaugePins[i]);
	}

	char mode = 's';
	if(digitalRead(buttonPin[0]) == LOW) {	//do calibration
		mode = 'c'; 
	}

	sprintf(commBuff,"%c %d %d %d %d %d \n",mode,analogVals[0],analogVals[1],analogVals[2],analogVals[3],analogVals[4]);
  
	Serial.print(commBuff);
	
}
