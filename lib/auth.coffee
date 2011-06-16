mongoose = require 'mongoose'
mongooseAuth = require 'mongoose-auth'
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
      redirectPath: '/'
}

mongoose.model('User', UserSchema);

User = mongoose.model 'User'

(exports ? this).User = User
(exports ? this).auth = mongooseAuth