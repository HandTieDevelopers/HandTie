#!/bin/bash

curl --request PUT --data "{\"on\": true,\"bri\":$3,\"sat\":$2,\"hue\":$1,\"effect\":\"none\"}" http://10.4.28.46/api/newdeveloper/lights/1/state
curl --request PUT --data "{\"on\": true,\"bri\":$3,\"sat\":$2,\"hue\":$1,\"effect\":\"none\"}" http://10.4.28.46/api/newdeveloper/lights/2/state
curl --request PUT --data "{\"on\": true,\"bri\":$3,\"sat\":$2,\"hue\":$1,\"effect\":\"none\"}" http://10.4.28.46/api/newdeveloper/lights/3/state
curl --request PUT --data "{\"on\": true,\"bri\":$3,\"sat\":$2,\"hue\":$1,\"effect\":\"none\"}" http://10.4.28.46/api/newdeveloper/lights/4/state
