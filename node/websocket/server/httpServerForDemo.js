#!/usr/bin/env node
var http = require('http');
var express = require('express');
var app = express();
var port = 8080;

var server = http.createServer(app);

app.post('/glass/:ctrlMsg', function (req, res){ //for glass
    console.log(req.params.ctrlMsg);
    //res.end();
});


app.post('/watch/:ctrlMsg', function (req, res){ //for watch
    console.log(req.params.ctrlMsg);
    res.end();
});

app.listen(port, function() {
    console.log(' Server is listening on port ' + port);
});
