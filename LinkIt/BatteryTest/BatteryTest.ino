#include <LBattery.h>

char buff[256];

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(13,OUTPUT);
  digitalWrite(13,LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
  int battLevel = LBattery.level();
  //sprintf(buff,"battery level = %d",  battLevel);
  //Serial.println(buff);
  if(battLevel == 100) {
    Serial.println("fully charged");
    digitalWrite(13,HIGH);
  }
  sprintf(buff,"is charging = %d",LBattery.isCharging() );
  Serial.println(buff);
  delay(1000); 
}

