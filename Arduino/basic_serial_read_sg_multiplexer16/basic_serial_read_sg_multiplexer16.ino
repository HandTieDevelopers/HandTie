#define NUM_OF_GAUGE 8
#define NUM_OF_MULT_PINS 3
#define NUM_OF_CS_PIN 1

#define GAUGE_PIN A0
#define CS_PIN 5
#define MULT_MIN_PIN 2

uint16_t analogVals[NUM_OF_GAUGE] = {0};
boolean csPinStatus = LOW;

void setup(){
   for(int i=MULT_MIN_PIN; i<MULT_MIN_PIN+NUM_OF_MULT_PINS+NUM_OF_CS_PIN; i++){
      pinMode(i, OUTPUT);
   }
   digitalWrite(CS_PIN, csPinStatus);
   Serial.begin(9600);
}

void loop(){
   for(int i=0; i<NUM_OF_GAUGE; i++){
       digitalWrite(MULT_MIN_PIN, i & 1);
       digitalWrite(MULT_MIN_PIN+1, (i >> 1) & 1);
       digitalWrite(MULT_MIN_PIN+2, (i >> 2) & 1);
       analogVals[i] = analogRead(GAUGE_PIN);
       Serial.print(analogVals[i]);
       Serial.print("\t");
   }
   if(csPinStatus)
       Serial.print("\n");
   csPinStatus = !csPinStatus;
   digitalWrite(CS_PIN, csPinStatus);
//   digitalWrite(MULT_MIN_PIN, HIGH);
//   digitalWrite(MULT_MIN_PIN+1,LOW);
//   digitalWrite(MULT_MIN_PIN+2,LOW);
//   Serial.print(analogRead(GAUGE_PIN));
}
