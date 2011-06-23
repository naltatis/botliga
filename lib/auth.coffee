mongoose = require 'mongoose'
mongooseAuth = require 'mongoose-auth'
model = require './model'
mongoose.connect (process.env.MONGOHQ_URL || 'mongodb://localhost/botliga')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId
User


createBots = (user, number, callback) ->
  model.Bot.count user: user._id, (err, count) ->
    diff = number - count
    
    return callback() if diff <= 0
      
    finished = ->
      callback() if diff <= 0
      

    # create missing bots
    for i in [1..diff]
      bot = new model.Bot()
      bot.user = user._id
      bot.save (err, bot) ->
        console.log "bot #{bot.id} saved"
        diff = diff - 1
        finished()

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
      redirectPath: '/einstellungen'
      findOrCreateUser: (sess, accessTok, accessTokExtra, ghUser) ->
        promise = @Promise()
        self = @
        # TODO Check user in session or request helper first
        #      e.g., req.user or sess.auth.userId
        @User()().findOne {'github.id': ghUser.id}, (err, foundUser) ->
          if foundUser?
            createBots foundUser, 3, ->
              promise.fulfill foundUser
          else
            self.User()().createWithGithub ghUser, accessTok, (err, createdUser) ->
              createBots createdUser, 3, ->
                promise.fulfill createdUser
        promise
}

mongoose.model('User', UserSchema);

User = mongoose.model 'User'

(exports ? this).User = User
(exports ? this).auth = mongooseAuth