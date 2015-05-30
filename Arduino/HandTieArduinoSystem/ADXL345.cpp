#include "ADXL345.h"

ADXL345::ADXL345(){
   Wire.begin();
   writeToRegister(ADXL345_PWR_CTL_ADDR, ADXL345_DATA_RATE);
}

void ADXL345::writeToRegister(int regAddr, int data){
   Wire.beginTransmission(ADXL345_ADDR);
   Wire.write(regAddr);
   Wire.write(data);
   Wire.endTransmission();
}

int ADXL345::readFromRegister(int regAddr){
   Wire.beginTransmission(ADXL345_ADDR);
   Wire.write(regAddr);
   Wire.endTransmission();

   Wire.requestFrom(ADXL345_ADDR, 1);

   if (Wire.available() <= 1){
      return Wire.read();
   }
}

void ADXL345::serialPrintRaw(){
   serialPrint(1.0);
}

void ADXL345::serialPrintGravity(){
   serialPrint(256.0);
}

void ADXL345::serialPrint(float div){
   Serial.print(((readFromRegister(ADXL345_X_HIGH_ADDR) << 8) +
                  readFromRegister(ADXL345_X_LOW_ADDR))/div);

   Serial.print(" ");

   Serial.print(((readFromRegister(ADXL345_Y_HIGH_ADDR) << 8) +
                  readFromRegister(ADXL345_Y_LOW_ADDR))/div);

   Serial.print(" ");

   Serial.print(((readFromRegister(ADXL345_Z_HIGH_ADDR) << 8) +
                  readFromRegister(ADXL345_Z_LOW_ADDR))/div);

   Serial.print(" ");
}