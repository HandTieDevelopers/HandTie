var net = require('net');
//var StringDecoder = require('string_decoder').StringDecoder;
//var decoder = new StringDecoder('utf8');
var portNum = 8080;
// var buff = new Buffer(1024);

var server = net.createServer(function(client) { //'connection' listener
  console.log('server connected');
  client.on('data',function(data) {
    console.log( data.toString() );
  });

  client.on('timeout',function() {
  	client.end();
  });
  
  client.on('end', function() {
    console.log('server disconnected');
  });
  
});

server.listen(portNum, function() { //'listening' listener
  console.log('server bound on port:' + portNum);
});