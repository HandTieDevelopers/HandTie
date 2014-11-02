var Promise = require('bluebird')
var adb = require('adbkit')
var client = adb.createClient()
var keypress = require('keypress');
var fs = require('fs');

keypress(process.stdin);

client.listDevicesWithPaths()
  .then(function(devices) {
    return Promise.map(devices, function(device) {
      console.log("[Device] "+device.id);

        process.stdin.on('keypress', function (ch, key) {
          console.log('got "keypress"'+key.name);
          if (key && key.ctrl && key.name == 'c') {
            process.exit();
          }
          else if(key.name == 'right'){
            return client.shell(device.id, "input keyevent 22")   //right    
          }
          else if(key.name == 'left'){
            return client.shell(device.id, "input keyevent 21")  //left
          }
          else if(key.name == 'up'){
            return client.shell(device.id, "input keyevent 4")  //back   
          }
          else if(key.name == 'space'){
            return client.shell(device.id, "input keyevent 3")  //Home
          }
          else if(key.name == 'return'){
            return client.shell(device.id, "input keyevent 66")  //Enter
          }
          else if(key.name == 'backspace'){
            return client.shell(device.id, "input keyevent 67")  //Del
          }
          else if(key.name == 'c'){
            return client.shell(device.id, "input keyevent 27")  //Camera
          }
          else if(key.name == 'p'){
            return client.shell(device.id, "input keyevent 26")   //Power
          }
          else if(key.name == 'd'){
            return client.shell(device.id, "input keyevent 23")  //Dpad_center
          }
          else if(key.name == 'm'){
            return client.shell(device.id, "input keyevent 1")   //Menu
          }
        });

        process.stdin.setRawMode(true);
        console.log("setRawMode");
        process.stdin.resume();

      return client.shell(device.id, 'input keyevent 3')  //Home
    })
  })
  .then(function() {
    console.log('Done.')
  })
  .catch(function(err) {
    console.error('Something went wrong:', err.stack)
  })