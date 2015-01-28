#include <SPI.h>

const byte address = 0x11;
const int CS = 53;   //mega SS pin

void setup(){
   pinMode(CS, OUTPUT);
   digitalWrite(CS, HIGH);
   SPI.begin();
//   digitalPotWrite(0);
}

void loop(){
    for (int level = 0; level <= 255; level++)
    {
      digitalPotWrite(level);
      delay(1000);
    }
    delay(1000);
 
    for (int level = 255; level >= 0; level--)
    {
      digitalPotWrite(level);
      delay(1000);
    }

//digitalPotWrite(200);

}

void digitalPotWrite(int value){
   digitalWrite(CS, LOW);
   SPI.transfer(address);
   SPI.transfer(value);
   digitalWrite(CS, HIGH);
}
