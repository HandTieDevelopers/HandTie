#include <SPI.h>

const byte address = 0x11;
const int CS = 53;   //mega SS pin

void setup(){
   pinMode(CS, OUTPUT);
   SPI.begin();
}

void loop(){
   digitalPotWrite(137);
}

void digitalPotWrite(int value){
   digitalWrite(CS, LOW);
   SPI.transfer(address);
   SPI.transfer(value);
   digitalWrite(CS, HIGH);
}
