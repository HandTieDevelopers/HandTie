#include <SPI.h>

const static uint8_t kADR_WIPER0       = B00000000;
const int CS = 53;   //mega SS pin

void setup(){
   pinMode(CS, OUTPUT);
   SPI.begin();
}

void loop(){
   digitalPotWrite(0);
}

void digitalPotWrite(int value){
   digitalWrite(CS, LOW);
   SPI.transfer(kADR_WIPER0);
   SPI.transfer(value);
   digitalWrite(CS, HIGH);
}
