fs = require 'fs'
{exec} = require 'child_process'

propagate = (onErr, onSucc) -> (err, rest...) -> if err then onErr(err) else onSucc(rest...)

it 'syncs the npm-version with the bower-version', ->
  npm = JSON.parse(fs.readFileSync('./package.json', 'utf8'))
  bower = JSON.parse(fs.readFileSync('./bower.json', 'utf8'))
  bower.version.should.eql npm.version

it 'syncs the npm-version with the git version tag', (done) ->
  npm = JSON.parse(fs.readFileSync('./package.json', 'utf8'))

  exec 'git describe --exact-match', (err) ->
    if err
      # Not a proper tag; no need to check it
      return done()

    exec 'git describe --tags', propagate done, (stdout, stderr) ->
      gitVersion = stdout.split('\n')[0].match(/^v(\d+\.\d+\.\d+)$/)[1]
      npm.version.should.eql gitVersion
      done()

it 'syncs the npm-version with the version in the dist-files', (done) ->
  npm = JSON.parse(fs.readFileSync('./package.json', 'utf8'))
  fs.readdir 'dist', propagate done, (files) ->
    fullFiles = files.map (file) -> 'dist/' + file
    actualFiles = fullFiles.filter((file) -> fs.statSync(file).isFile())

    fileContent = actualFiles.map (file) ->
      fs.readFileSync(file, 'utf8').split('\n')[0]

    fileContent.forEach (firstLine) ->
      firstLine.should.eql '// z-core v' + npm.version

    done()
