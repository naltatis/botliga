mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/botliga'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

Bot = new Schema(
  id: { type: String, unique: true }
  name: String
  guesses: [Guess]
)

Guess = new Schema(
  hostGoals: Number
  guestGoals: Number
  match: ObjectId
)

mongoose.model('Bot', Bot);

Match = new Schema(
  id: { type: String, unique: true }
  hostId: Number
  guestId: Number
  hostName: String
  guestName: String
  hostGoals: Number
  guestGoals: Number
  season: String
  group: Number
  date: Date
)

mongoose.model('Match', Match);

(exports ? this).Match = mongoose.model('Match');
(exports ? this).Bot = mongoose.model('Bot');
(exports ? this).db = mongoose.connection.db