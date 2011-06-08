(function() {
  var Match, Schema, mongoose;
  mongoose = require('mongoose');
  mongoose.connect('mongodb://localhost/botliga');
  Schema = mongoose.Schema;
  Match = new Schema({
    id: Number,
    team1: String,
    team2: String
  });
  mongoose.model('Match', Match);
  (typeof exports !== "undefined" && exports !== null ? exports : this).Match = mongoose.model('Match');
}).call(this);
