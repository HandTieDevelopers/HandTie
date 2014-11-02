
/**
 * HTTP Client. 
 * 
 * Starts a network client that connects to a server on port 80,
 * sends an HTTP 1.0 GET request, and prints the results. 
 *
 * Note that this code is not necessary for simple HTTP GET request:
 * Simply calling loadStrings("http://www.processing.org") would do
 * the same thing as (and more efficiently than) this example.
 * This example is for people who might want to do something more 
 * complicated later.
 */
 

import processing.net.*;
Client c;
String data;

final static int serverPort = 8080;
final static String serverAddress = "127.0.0.1";

void sendMsg(String targetDevice, String msg) {
  c = new Client(this, serverAddress, serverPort);
  c.write("POST " + targetDevice + msg + " HTTP/1.0\r\n"); // Use the HTTP "POST" command to ask for a Web page
  c.write("\r\n");
  c.stop();
}

void setup() {
  String targetDevice = "/glass/";
  String msg = "swipeLeft";
  sendMsg(targetDevice, msg);
}

void draw() {
  /*
  if (c.available() > 0) { // If there's incoming data from the client...
    data = c.readString(); // ...then grab it and print it
    println(data);
  }
  */
  
}
