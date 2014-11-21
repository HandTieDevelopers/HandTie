var shell = require('shelljs');
//var keypress = require('keypress');
var net = require('net');
var fs = require('fs');
var Promise = require('bluebird');
var adb = require('adbkit');
var adbClient = adb.createClient();

//keyboard input
/*
keypress(process.stdin);

process.stdin.on('keypress', function (ch, key) {
  if(key) { //get rid of undefined key
    console.log('got "keypress",name = ', key.name);
  }
  if (key && key.ctrl && key.name == 'c') {
    process.exit();
  }
});

process.stdin.setRawMode(true);
process.stdin.resume();
*/

//shell script
var appleScriptInterpreter = 'osascript';
var relativePathOfKeynoteCmdScripts = '../Processing/appleScript/';
var KeynoteCmds = [
  "startSlideShow.scpt",
  "stopSlideShow.scpt",
  "previousSlide.scpt",
  "nextSlide.scpt"
];

function execKeynoteCmd(keynoteCmd) {
  shell.exec( appleScriptInterpreter + ' ' + relativePathOfKeynoteCmdScripts + keynoteCmd, {silent:true,async:true}, function(code,output) {});
}

function controlKeynote(cmd) {
  if(cmd === 'L') {
    execKeynoteCmd(KeynoteCmds[2]);
  }
  else if(cmd === 'R'){
    execKeynoteCmd(KeynoteCmds[3]);
  }
}

var watchIRMode = 1;

function controlWear(cmd) {
  /*
  adbClient.shell(currentWear, "input swipe 260 70 260 200")   //up    
  adbClient.shell(currentWear, "input swipe 260 200 260 70")  //down
  adbClient.shell(currentWear, "input swipe 260 50 260 310")  //big_up   
  adbClient.shell(currentWear, "input swipe 260 310 260 50")  //big_down
  adbClient.shell(currentWear, "input swipe 250 200 5 200")  //right
  adbClient.shell(currentWear, "input swipe 5 150 300 150")  //left
  adbClient.shell(currentWear, "input tap 150 150")  //return
  adbClient.shell(currentWear, "input keyevent 26")   //Power
  adbClient.shell(currentWear, "input swipe 1 160 250 160")  //Back_home
  adbClient.shell(currentWear, "input swipe 310 160 100 160")   //App
  */

  if(cmd === 'M') { //switch to mode 1
    watchIRMode = 1;
  }
  else if(cmd === 'P') { //switch to mode 0
    watchIRMode = 0;
  }
  else if(cmd === 'U') {
    if(watchIRMode) {
      adbClient.shell(currentWear, "input swipe 260 70 260 200")   //up
    }
    else {
      adbClient.shell(currentWear, "input swipe 260 50 260 310")   //big_up
    }
  }
  else if(cmd === 'D'){
    if(watchIRMode) {
      adbClient.shell(currentWear, "input swipe 260 200 260 70")  //down
    }
    else {
      adbClient.shell(currentWear, "input swipe 260 310 260 50")  //big_down
    }
  }
  else if(cmd === 'L'){
    if(watchIRMode) {
      adbClient.shell(currentWear, "input swipe 5 150 300 150")  //left 
    }
    else {
      adbClient.shell(currentWear, "input swipe 310 160 100 160")  //App
    }
  }
  else if(cmd === 'R'){
    if(watchIRMode) {
      adbClient.shell(currentWear, "input swipe 250 200 5 200")  //right
    }
    else {
      adbClient.shell(currentWear, "input swipe 1 160 250 160")  //Back_home
    }
  }
  else if(cmd == 'C') {
    if(watchIRMode) {
      adbClient.shell(currentWear, "input tap 150 150")  //Enter
    }
    else {
      adbClient.shell(currentWear, "input keyevent 26")  //Power
    }
  }
} 

var glassIRMode = 1;

function controlGlass(cmd) {
  /* command list
  adbClient.shell(currentGlass, "input keyevent 22");  //right
  adbClient.shell(currentGlass, "input keyevent 21");  //left
  adbClient.shell(currentGlass, "input keyevent 4");   //back   
  adbClient.shell(currentGlass, "input keyevent 3");   //Home
  adbClient.shell(currentGlass, "input keyevent 66");  //Enter
  adbClient.shell(currentGlass, "input keyevent 67");  //Del
  adbClient.shell(currentGlass, "input keyevent 27");  //Camera
  adbClient.shell(currentGlass, "input keyevent 26");  //Power
  adbClient.shell(currentGlass, "input keyevent 23");  //Dpad_center
  adbClient.shell(currentGlass, "input keyevent 1");  //Menu
  */
  if(cmd === 'M') { //switch to mode 1
    glassIRMode = 1;
  }
  else if(cmd === 'P') { //switch to mode 0
    glassIRMode = 0;
  }
  else if(cmd === 'U') {
    if(glassIRMode) {
      adbClient.shell(currentGlass, "input keyevent 4");   //back   
    }
    else {
      adbClient.shell(currentGlass, "input keyevent 67");  //Del
    }
  }
  else if(cmd === 'D'){
    if(glassIRMode) {
      adbClient.shell(currentGlass, "input keyevent 3");   //Home
    }
    else {
      adbClient.shell(currentGlass, "input keyevent 27");  //Camera
    }
  }
  else if(cmd === 'L'){
    if(glassIRMode) {
      adbClient.shell(currentGlass, "input keyevent 21");  //left
    }
    else {
      adbClient.shell(currentGlass, "input keyevent 23");  //Dpad_center
    }
  }
  else if(cmd === 'R'){
    if(glassIRMode) {
      adbClient.shell(currentGlass, "input keyevent 22");  //right
    }
    else {
      adbClient.shell(currentGlass, "input keyevent 1");  //Menu
    }
  }
  else if(cmd == 'C') {
    if(glassIRMode) {
      adbClient.shell(currentGlass, "input keyevent 66");  //Enter
    }
    else {
      adbClient.shell(currentGlass, "input keyevent 26");  //Power
    }
  }
}

var glassIDs = ['015ECD9B1201E014','016837660601F007'];
var wearIDs = ['R3AF600Z0XN','localhost:6670'];
var currentGlass = null;
var currentWear = null;

function tryToFindNewGlass() {
  adbClient.listDevicesWithPaths()
  .then(function(devices) {
    for(var i = 0;i < devices.length;i++) {
      if(glassIDs.indexOf(devices[i]) !== -1) {
        currentGlass = devices[i];
        console.log('find another glass,id:' + currentGlass);
        return; 
      }
    }
    currentGlass = null;
    console.log('not found any glass');
  });
}

function tryToFindNewWear() {
  adbClient.listDevicesWithPaths()
  .then(function(devices) {
    for(var i = 0;i < devices.length;i++) {
      if(wearIDs.indexOf(devices[i]) !== -1) {
        currentWear = devices[i];
        console.log('find another wear,id:' + currentWear);
        return; 
      }
    }
    currentWear = null;
    console.log('not found any wear');
  });
}

// plugin/unplug/firstTimeExecute event
adbClient.trackDevices()
.then(function(tracker) {
  tracker.on('add', function(device) {
    console.log('Device %s was plugged in', device.id);
    if(glassIDs.indexOf(device.id) !== -1 ) {
      currentGlass = device.id;
      console.log('current glass id become:' + currentGlass);
    }
    else if(wearIDs.indexOf(device.id) !== -1) {
      currentWear = device.id;
      console.log('current wear id become:' + currentWear);
    }
  })
  tracker.on('remove', function(device) {
    console.log('Device %s was unplugged', device.id);
    if(currentGlass === device.id) {
      tryToFindNewGlass();
    }
    else if(currentWear === device.id) {
      tryToFindNewWear();
    }
  })
  tracker.on('end', function() {
    console.log('Tracking stopped');
  })
})
.catch(function(err) {
  console.error('Something went wrong:', err.stack)
});

var tcpPortNum = 8090;

//tcp server
var tcpServerForCommWithProcessing = net.createServer(function(client) { //'connection' listener
  console.log('client connected');
  client.setEncoding('binary');
  client.on('data',function(data) { //data arriving callback
    console.log( data );
    var segments = data.split(',');
    
    if(segments.length !== 2) {
      console.log('command format error');
      return;
    }

    if(segments[0] === 'g') { //glass
      if(currentGlass === null) {
        tryToFindNewGlass();
      }
      if(currentGlass !== null) {
        controlGlass(segments[1]);
      }
    }
    else if(segments[0] === 'w') { //wear
      if(currentWear === null) {
        tryToFindNewWear();
      }
      if(currentWear !== null) {
        controlWear(segments[1]);
      }
    }
    else if(segments[0] === 'k') { //keynote
      controlKeynote(segments[1]);
    }
    else {
      console.log('unknown control mode');
    }
    
    
  });

  client.on('timeout',function() {
  	client.end();
  });
  
  client.on('end', function() {
    console.log('client disconnected');
  });
  
});

tcpServerForCommWithProcessing.listen(tcpPortNum, function() { //'listening' listener
  console.log('server bound on port:' + tcpPortNum);
});
