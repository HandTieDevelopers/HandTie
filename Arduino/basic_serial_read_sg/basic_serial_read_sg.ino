int caliVolts[] = {-1,-1,-1,-1,-1};
double elongRatios[5];


void setup() {
  pinMode(2,INPUT);
  Serial.begin(9600);  
}

void loop() {
  if(digitalRead(2) == 1){
    for(int i=0; i<5; ++i){
      caliVolts[i] = analogRead(i);
      Serial.println("button pressed: ");
    }
  }

  for(int i=0; i<5; ++i){
    int strainData = analogRead(i);
    elongRatios[i] = ((double)strainData) / caliVolts[i];
    Serial.print(elongRatios[i],2);
    Serial.print("\t");
    Serial.print(strainData);
    Serial.print("\t");
  }
  Serial.println("");
  delay(1);                  
}
