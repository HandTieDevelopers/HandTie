#ifndef ADXL345_H
#define ADXL345_H

#include <Arduino.h>
#include <Wire.h>

#define ADXL345_ADDR        0xA7 >> 1
#define ADXL345_X_LOW_ADDR  0x32
#define ADXL345_X_HIGH_ADDR 0x33
#define ADXL345_Y_LOW_ADDR  0x34
#define ADXL345_Y_HIGH_ADDR 0x35
#define ADXL345_Z_LOW_ADDR  0x36
#define ADXL345_Z_HIGH_ADDR 0x37

#define ADXL345_PWR_CTL_ADDR 0x2D
#define ADXL345_DATA_RATE    0xA //Rate code for 100Hz

/*
data rate/rate code
3200 1111
1600 1110
800  1101
400  1100
200  1011
100  1010
50   1001
25   1000
*/

class ADXL345
{
public:
   ADXL345();
   void serialPrintRaw();
   void serialPrintGravity();

private:
   void writeToRegister(int, int);
   int readFromRegister(int);

   void serialPrint(float);

};

#endif //#ifndef ADXL345_H