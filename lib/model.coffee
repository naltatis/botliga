mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/botliga'

Schema = mongoose.Schema

Match = new Schema(
  id: Number
  team1: String
  team2: String
)

mongoose.model('Match', Match);

(exports ? this).Match = mongoose.model('Match');