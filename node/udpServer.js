var dgram = require("dgram");
var serverPort = 8080;

var server = dgram.createSocket("udp6");

server.on("error", function (err) {
  console.log("server error:\n" + err.stack);
  server.close();
});

server.on("close", function() {
  console.log("client disconnected");
});

server.on("message", function (msg, rinfo) {
  console.log("msg: " + msg);
});

server.on("listening", function () {
  console.log("server listening on " + serverPort);
});

server.bind(serverPort);