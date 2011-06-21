mongoose = require 'mongoose'
mongoose.connect (process.env.MONGOHQ_URL || 'mongodb://localhost/botliga')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

Bot = new Schema(
  id: { type: String, unique: true }
  name: String
)

Guess = new Schema(
  hostGoals: Number
  guestGoals: Number
  match: ObjectId
  bot: ObjectId
  points: Number
)

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


mongoose.model('Bot', Bot);
mongoose.model('Guess', Guess);
mongoose.model('Match', Match);

(exports ? this).Match = mongoose.model 'Match'
(exports ? this).Guess = mongoose.model 'Guess'
(exports ? this).Bot = mongoose.model 'Bot'
(exports ? this).db = mongoose.connection.db