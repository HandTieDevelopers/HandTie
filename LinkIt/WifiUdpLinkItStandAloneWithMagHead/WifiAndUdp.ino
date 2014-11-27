//Wifi udp
#include <LWiFi.h>
#include <LWiFiUdp.h>

void connectToAP() {
  while (0 == LWiFi.connect(WIFI_AP, APConnectingInfo)) {
    //Serial.println("connecting Wifi AP failed");
    delay(retryIntervalInMilliSec);
  }
}

void checkAPConnection() {
  if(LWiFi.status() == LWIFI_STATUS_DISCONNECTED) {
    udpClient.stop();
    connectToAP();
    udpClient.begin(udpLocalPort);
  }
}

void transmitUDPPacket() {
  int isSuccessful = 0;
  int numBytesToTransmit = strlen(buff_w);
  udpClient.beginPacket(serverIP, serverPort);
  while(true) {
    isSuccessful = udpClient.write((const uint8_t*)buff_w, numBytesToTransmit);
    if(!isSuccessful) { //something wrong
      checkAPConnection();
    }
    else {
      break;
    }
  }
  udpClient.endPacket();
}