var shell = require('shelljs');
var net = require('net');
var portNum = 8080;
var relativePath = '../../C/binary/';

var child = shell.exec(relativePath + 'irRemoteExculsive', {silent:true,async:true}, function(code,output) {
  console.log('ir program terminated');
  console.log('Exit code:', code);
  console.log('Program output:', output);
});

child.stderr.on('data', function(data) {
  data = data.slice(0, data.length - 1); //remove newline char
  console.log('data:' + data);
});

var tcpServerForCommWithProcessing = net.createServer(function(client) { //'connection' listener
  console.log('server connected');
  client.on('data',function(data) {
    console.log( data.toString() );
  });

  client.on('timeout',function() {
  	client.end();
  });
  
  client.on('end', function() {
    console.log('client disconnected');
  });
  
});

tcpServerForCommWithProcessing.listen(portNum, function() { //'listening' listener
  console.log('server bound on port:' + portNum);
});