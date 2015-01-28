#define NUM_OF_GAUGE 4
#define NUM_OF_MULT_PINS 3

#define GAUGE_PIN A0
#define MULT_MIN_PIN 1

uint16_t analogVals[NUM_OF_GAUGE] = {0};

void setup(){
   for(int i=MULT_MIN_PIN; i<MULT_MIN_PIN+NUM_OF_MULT_PINS; i++){
      pinMode(i, OUTPUT);
   }
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
   Serial.print("\n");
//
   // digitalWrite(MULT_MIN_PIN, HIGH);
   // digitalWrite(MULT_MIN_PIN+1,LOW);
   // digitalWrite(MULT_MIN_PIN+2,LOW);
   // Serial.print(analogRead(GAUGE_PIN));
}
