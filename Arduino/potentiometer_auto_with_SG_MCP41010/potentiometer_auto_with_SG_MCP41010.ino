#include <SPI.h>

// Digital Potentiometer MCP41010
#define DIGITAL_POT_ADDR   0x11
#define CS_PIN 53
#define TARGET_VAL 30
#define TARGET_VAL_TOLERANCE 0.1
#define TARGET_POSITIVE_TOLER TARGET_VAL*(1+TARGET_VAL_TOLERANCE)
#define TARGET_NEGATIVE_TOLER TARGET_VAL*(1-TARGET_VAL_TOLERANCE)
#define MAX_TIME_CALIBRATION 5000
#define INITIAL_POSITION 137

// Strain Gauge Macro
#define NUM_OF_GAUGE 5
#define GAUGE_PIN A0

// Multiplexer Macro
#define NUM_OF_MULTIPLEX_PINS 3
#define MULTIPLEX_MIN_PIN 4

// Button
#define BUTTON_PIN 2

int potPos[NUM_OF_GAUGE] = {INITIAL_POSITION};

uint16_t analogVals[NUM_OF_GAUGE] = {0};

void setup(){
   pinMode(CS_PIN, OUTPUT);
   pinMode(BUTTON_PIN, INPUT_PULLUP);
   SPI.begin();
   Serial.begin(115200);

   digitalPotWrite(INITIAL_POSITION);
}

void loop(){
   for(int i=0; i<NUM_OF_GAUGE; i++){
      digitalWrite(MULTIPLEX_MIN_PIN, i & 1);
      digitalWrite(MULTIPLEX_MIN_PIN+1, (i >> 1) & 1);
      digitalWrite(MULTIPLEX_MIN_PIN+2, (i >> 2) & 1);

      analogVals[i] = analogRead(GAUGE_PIN);
      Serial.print(analogVals[i]);
      Serial.print("\t");
   }
   Serial.print("\n");

   if(digitalRead(BUTTON_PIN) == HIGH){
       autoCalibration();
   }
}

void autoCalibration(){
   uint16_t timeNow;
   Serial.println("Calibrating");
   for(int i=0; i<NUM_OF_GAUGE; i++){
      digitalWrite(MULTIPLEX_MIN_PIN, i & 1);
      digitalWrite(MULTIPLEX_MIN_PIN+1, (i >> 1) & 1);
      digitalWrite(MULTIPLEX_MIN_PIN+2, (i >> 2) & 1);

      timeNow = millis();
      while(1){
         analogVals[i] = analogRead(GAUGE_PIN);

         if(analogVals[i] > TARGET_POSITIVE_TOLER){
            digitalPotWrite(++potPos[i]);
         } else if (analogVals[i] < TARGET_NEGATIVE_TOLER){
            digitalPotWrite(--potPos[i]);
         } else if (timeNow > MAX_TIME_CALIBRATION){
            potPos[i] = INITIAL_POSITION;
            Serial.print("Timeout");
            break;
         } else {
            Serial.print(analogVals[i]);
            break;
         }
      }
      Serial.print("\t");
   }
}

void digitalPotWrite(int value){
   digitalWrite(CS_PIN, LOW);
   SPI.transfer(DIGITAL_POT_ADDR);
   SPI.transfer(value);
   digitalWrite(CS_PIN, HIGH);
}
