int hits = 0; // impact count
int gAllTrig = 1000; // impact sensitivity

void setup() {
  Serial.begin(9600); // initialize serial
}

void loop() {
  // accelerometer data
  AccelerationReading accel = { 0, 0, 0 };
  accel = Bean.getAcceleration();
  uint16_t gAll = (abs(accel.xAxis)+abs(accel.yAxis)+abs(accel.zAxis));

  // this detects impact so if you hit the bean
  // or move it very quickly, the if is true
  if ((gAll > gAllTrig)) {
    Serial.println( hits );
    delay(50); // prevent duplicate detection

    // set led colour according to impact counter
    if (hits == 1) { Bean.setLed(0,0,255); } // blue
    if (hits == 2) { Bean.setLed(255,0,0); } // red
    if (hits == 3) { Bean.setLed(0,255,0); } // green
    if (hits == 4) { Bean.setLed(255,0,255); } // pink
    if (hits == 5) { Bean.setLed(255,100,0); } // orange
    if (hits == 6) { Bean.setLed(135,206,250);  hits = 0; } // light blue
    hits++; // increment counter
  }
}
