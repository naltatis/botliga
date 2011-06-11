mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/botliga'

Schema = mongoose.Schema

Match = new Schema(
  id: { type: String, unique: true }
  team1: Number
  team2: Number
  team1Name: String
  team2Name: String
  team1Goals: Number
  team2Goals: Number
  season: String
  group: Number
  date: Date
)

mongoose.model('Match', Match);

(exports ? this).Match = mongoose.model('Match');
(exports ? this).db = mongoose.connection.db