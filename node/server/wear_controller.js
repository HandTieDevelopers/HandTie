var Promise = require('bluebird');
var adb = require('adbkit');
var client = adb.createClient();
var keypress = require('keypress');
var fs = require('fs');
var MyPort = 6670;
keypress(process.stdin);

client.listDevicesWithPaths()
  .then(function(devices) {
    return Promise.map(devices, function(device) {
      console.log("[Device] "+device.id);
        if(device.id == "localhost:"+MyPort){
          process.stdin.on('keypress', function (ch, key) {
            console.log('got "keypress"'+key.name);
            if (key && key.ctrl && key.name == 'c') {
              process.exit();
            }
            else if(key.name == 'up'){
              return client.shell(device.id, "input swipe 260 70 260 200")   //up    
            }
            else if(key.name == 'down'){
              return client.shell(device.id, "input swipe 260 200 260 70")  //down
            }
            else if(key.name == 'q'){
              return client.shell(device.id, "input swipe 260 50 260 310")  //big_up   
            }
            else if(key.name == 'a'){
              return client.shell(device.id, "input swipe 260 310 260 50")  //big_down
            }
            else if(key.name == 'right'){
              return client.shell(device.id, "input swipe 250 200 5 200")  //right
            }
            else if(key.name == 'left'){
              return client.shell(device.id, "input swipe 5 150 300 150")  //left
            }
            else if(key.name == 'return'){
              return client.shell(device.id, "input tap 150 150")  //left
            }
            else if(key.name == 'p'){
              return client.shell(device.id, "input keyevent 26")   //Power
            }
            else if(key.name == 'x'){
              return client.shell(device.id, "input swipe 1 160 250 160")  //Back_home
            }
            else if(key.name == 'z'){
              return client.shell(device.id, "input swipe 310 160 100 160")   //App
            }
          });

          process.stdin.setRawMode(true);
          //console.log("setRawMode");
          process.stdin.resume();

        return client.shell(device.id, 'input keyevent 3')  //Home
      }
    })
  })
  .then(function() {
    console.log('Done.');
  })
  .catch(function(err) {
    console.error('Something went wrong:', err.stack);
  });