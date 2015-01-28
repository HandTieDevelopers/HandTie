//boolean invert = LOW;

void setup() {
  Serial.begin( 9600 );
   for (int i = 2; i < 6; ++i)
   {
      pinMode( i, OUTPUT );
   }
   
   pinMode( 7, OUTPUT);
   pinMode( A0, INPUT );

}
   
void loop() {
   digitalWrite( 5, LOW );
   digitalWrite( 7, HIGH);
   for(int i=0; i<8; i++){
      digitalWrite( 2, i & 1 );
      digitalWrite( 3, ( i >> 1 ) & 1 );
      digitalWrite( 4, ( i >> 2 ) & 1 );
      Serial.print(analogRead(A0));
      Serial.print("\t");
   }
//   if(invert)
//      Serial.println();
//   invert = !invert;
   
   digitalWrite( 5, HIGH);
   digitalWrite( 7, LOW );
   for(int i=0; i<8; i++){
      digitalWrite( 2, i & 1 );
      digitalWrite( 3, ( i >> 1 ) & 1 );
      digitalWrite( 4, ( i >> 2 ) & 1 );
      Serial.print(analogRead(A0));
      Serial.print("\t");
   }

//   digitalWrite( 2, 1);
//   digitalWrite( 3, 0);
//   digitalWrite( 4, 0);
//   Serial.print(analogRead(A0));

   Serial.println();

}
