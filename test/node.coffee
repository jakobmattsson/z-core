fs = require 'fs'

it 'has synced version numbers', ->
  bower = JSON.parse(fs.readFileSync('./bower.json', 'utf8'))
  npm = JSON.parse(fs.readFileSync('./package.json', 'utf8'))
  bower.version.should.eql npm.version
