(function() {
  var app, express, model;
  express = require("express");
  model = require("./lib/model");
  require("express-namespace");
  app = express.createServer();
  app.get("/", function(req, res) {
    return res.send("Hello World");
  });
  app.namespace("/api", function() {
    app.get("/", function(req, res) {
      var instance;
      instance = new model.Match();
      instance.id = 7;
      instance.team1 = "Werder";
      instance.team2 = "Hamburg";
      return instance.save(function(err) {
        return res.send("saved");
      });
    });
    return app.get("/evaluate", function(req, res) {
      return res.send("Hello World");
    });
  });
  app.listen(3000);
}).call(this);
