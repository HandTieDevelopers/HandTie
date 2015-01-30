#ifndef StrainGauge_h
#define StrainGauge_h

class StrainGauge
{
public:
   StrainGauge();
   ~StrainGauge();

   void setAmpPotPos(int);
   int getAmpPotPos();

   void setBridgePotPos(int);
   int getBridgePotPos();

private:
   int ampPotPos;
   int bridgePotPos;
};

#endif   //StrainGauge_h