mongoose = require 'mongoose'
mongooseAuth = require 'mongoose-auth'
model = require './model'
mongoose.connect (process.env.MONGOHQ_URL || 'mongodb://localhost/botliga')

Schema = mongoose.Schema
User

UserSchema = new Schema({})
UserSchema.plugin mongooseAuth, {
  everymodule:
    everyauth:
      User: -> User
  github:
    everyauth:
      myHostname: process.env.DOMAIN || 'http://localhost:3000'
      appId: process.env.GITHUB_APP_ID || 1
      appSecret: process.env.GITHUB_APP_SECRET || "geheim"
      redirectPath: '/settings'
}
UserSchema.pre 'init', (next) ->
  bot = new model.Bot()
  bot.user = this
  bot.save ->
    next()

mongoose.model('User', UserSchema);

User = mongoose.model 'User'

(exports ? this).User = User
(exports ? this).auth = mongooseAuth